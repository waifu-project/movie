#!/usr/bin/env node

import fs from 'fs'
import path from 'path'
import ts from 'typescript';
import parser from '@babel/parser';
import traverse from '@babel/traverse'
import generator from '@babel/generator';
import { Command } from 'commander';

// Fix @babel/traverse and @babel/generator import issues
const babelTraverse = traverse.default || traverse;
const babelGenerator = generator.default || generator;

/** @type {(rawCode: string) => string} */
function parseWithStr(rawCode) {
  // Step 1: Transpile TS to JS
  const jsCode = ts.transpileModule(rawCode, {
    compilerOptions: {
      target: ts.ScriptTarget.ES2020,
      module: ts.ModuleKind.CommonJS,
      removeComments: false
    }
  }).outputText;

  // Step 2: Parse JS to AST
  const ast = parser.parse(jsCode, {
    sourceType: 'module',
    plugins: ['classProperties']
  });


  /** @type {Iconfig} */
  const config = {}

  // Store compressed code for all methods
  const methodCodes = {};

  // Step 3: Find exported class name (supports default and named exports)
  let targetClassName = null;

  // Find exports.default = ClassName pattern (default export)
  babelTraverse(ast, {
    AssignmentExpression(path) {
      if (path.node.left.type === 'MemberExpression' &&
        path.node.left.object.name === 'exports' &&
        path.node.left.property.name === 'default' &&
        path.node.right.type === 'Identifier') {
        targetClassName = path.node.right.name;
      }
    }
  });

  // If no default export found, look for named export classes
  if (!targetClassName) {
    babelTraverse(ast, {
      ClassDeclaration(path) {
        // Check if class implements Handle interface
        if (path.node.implements && path.node.implements.some(impl => impl.expression?.name === 'Handle')) {
          targetClassName = path.node.id?.name;
        }
      }
    });
  }

  // Step 4: Extract configuration and compress return statements
  babelTraverse(ast, {
    ClassDeclaration(path) {
      if (path.node.id?.name === targetClassName) {
        path.get('body').get('body').forEach(methodPath => {
          // Parse getConfig method
          if (methodPath.node.key?.name === 'getConfig') {
            methodPath.traverse({
              ReturnStatement(returnPath) {

                // Handle ObjectExpression directly (type assertions removed after TypeScript transpilation)
                if (returnPath.node.argument.type === 'ObjectExpression') {
                  const expression = returnPath.node.argument;
                  expression.properties.forEach(prop => {
                    if (prop.type === 'ObjectProperty' && prop.key.type === 'Identifier') {
                      const key = prop.key.name;
                      let value;
                      if (prop.value.type === 'StringLiteral') {
                        value = prop.value.value;
                      } else if (prop.value.type === 'NumericLiteral') {
                        value = prop.value.value;
                      } else if (prop.value.type === 'BooleanLiteral') {
                        value = prop.value.value;
                      } else if (prop.value.type === 'Identifier') {
                        // Handle identifier type, but this usually means syntax error
                        // We log a warning here but don't process it
                        console.warn(`Warning: Found identifier '${prop.value.name}' as value for key '${key}'. This might be a syntax error. Use quotes for strings.`);
                        value = undefined; // Don't process identifier type
                      } else if (prop.value.type === 'ObjectExpression' && key === 'extra') {
                        // Handle extra object
                        value = {};
                        prop.value.properties.forEach(extraProp => {
                          if (extraProp.type === 'ObjectProperty' && extraProp.key.type === 'Identifier') {
                            const extraKey = extraProp.key.name;
                            let extraValue;
                            if (extraProp.value.type === 'StringLiteral') {
                              extraValue = extraProp.value.value;
                            } else if (extraProp.value.type === 'NumericLiteral') {
                              extraValue = extraProp.value.value;
                            } else if (extraProp.value.type === 'BooleanLiteral') {
                              extraValue = extraProp.value.value;
                            } else if (extraProp.value.type === 'Identifier') {
                              console.warn(`Warning: Found identifier '${extraProp.value.name}' as value for extra key '${extraKey}'. Use quotes for strings.`);
                              extraValue = undefined;
                            }
                            if (extraValue !== undefined) {
                              value[extraKey] = extraValue;
                            }
                          }
                        });
                      }
                      if (value !== undefined) {
                        config[key] = value;
                      }
                    }
                  });
                }
                returnPath.stop();
              }
            });
          }
          // Parse all related methods
          const methodName = methodPath.node.key?.name;
          if (['getCategory', 'getHome', 'getDetail', 'getSearch', 'parseIframe'].includes(methodName)) {
            // Map method names to configuration fields
            const methodMapping = {
              'getCategory': 'category',
              'getHome': 'home',
              'getDetail': 'detail',
              'getSearch': 'search',
              'parseIframe': 'parseIframe'
            };

            const configKey = methodMapping[methodName];
            if (!configKey) return;

            // Special handling for getCategory - check if it directly returns an array
            if (methodName === 'getCategory') {
              // Find return statements
              methodPath.traverse({
                ReturnStatement(returnPath) {
                  const returnArg = returnPath.node.argument;

                  // Check if directly returning an array
                  if (returnArg && (returnArg.type === 'ArrayExpression' ||
                    (returnArg.type === 'TSTypeAssertion' && returnArg.expression.type === 'ArrayExpression') ||
                    (returnArg.type === 'TSAsExpression' && returnArg.expression.type === 'ArrayExpression'))) {

                    // Extract array expression
                    let arrayExpr = returnArg;
                    if (returnArg.type === 'TSTypeAssertion' || returnArg.type === 'TSAsExpression') {
                      arrayExpr = returnArg.expression;
                    }

                    // Convert array to actual JavaScript object
                    try {
                      const { code: arrayCode } = babelGenerator(arrayExpr, {
                        compact: true,
                        minified: true,
                        comments: false
                      });

                      // Use eval to parse array (in safe environment)
                      const categoryArray = eval(arrayCode);
                      methodCodes[configKey] = categoryArray;
                    } catch (error) {
                      // If parsing fails, fallback to function body code
                      const { code } = babelGenerator(methodPath.node.body, {
                        compact: true,
                        minified: true,
                        comments: false
                      });
                      methodCodes[configKey] = code.replace(/^\{/, '').replace(/\}$/, '');
                    }
                  } else {
                    // Not directly returning array, use function body code
                    const { code } = babelGenerator(methodPath.node.body, {
                      compact: true,
                      minified: true,
                      comments: false
                    });
                    methodCodes[configKey] = code.replace(/^\{/, '').replace(/\}$/, '');
                  }
                  returnPath.stop();
                }
              });
            } else {
              // Handle other methods normally
              if (methodPath.node.body && methodPath.node.body.type === 'BlockStatement') {
                const { code } = babelGenerator(methodPath.node.body, {
                  compact: true,
                  minified: true,
                  comments: false
                });

                // Remove outer braces, keep only function body content
                let cleanCode = code.replace(/^\{/, '').replace(/\}$/, '');
                methodCodes[configKey] = cleanCode;
              }
            }
          }
        });
      }
    }
  });

  // Merge method code into config.extra.js
  if (Object.keys(methodCodes).length > 0) {
    config.extra = config.extra || {};
    config.extra.js = methodCodes;
  }

  return config
}

/** @type {(file: string) => Iconfig | null} */
function parseWithFile(file) {
  try {
    const rawCode = fs.readFileSync(file, 'utf-8')
    const result = parseWithStr(rawCode)
    // Only return valid configuration (must have at least id)
    return result.id ? result : null
  } catch (error) {
    console.warn(`Failed to parse file: ${file}`, error.message)
    return null
  }
}

/** @type {(dir: string) => string[]} */
function scanTsFiles(dir) {
  const tsFiles = []
  function scanDirectory(currentDir, one = true) {
    try {
      const items = fs.readdirSync(currentDir)

      for (const item of items) {
        const fullPath = path.join(currentDir, item)
        const stat = fs.statSync(fullPath)

        if (stat.isDirectory()) {
          if (!['node_modules', '.git', '.vscode', 'dist', 'build'].includes(item)) {
            scanDirectory(fullPath, false)
          }
        } else if (stat.isFile() && item.endsWith('.ts') && !one) {
          tsFiles.push(fullPath)
        }
      }
    } catch (error) {
      console.warn(`Failed to scan directory: ${currentDir}`, error.message)
    }
  }
  scanDirectory(dir)
  return tsFiles
}

/** @type {(dir: string, verbose?: boolean) => Iconfig[]} */
function parseAllTsFiles(dir, verbose = true) {
  const tsFiles = scanTsFiles(dir)
  const configs = []
  if (verbose) {
    console.log(`Found ${tsFiles.length} TypeScript files`)
  }

  for (const file of tsFiles) {
    if (verbose) {
      console.log(`Parsing: ${file}`)
    }
    const config = parseWithFile(file)
    if (config) {
      configs.push(config)
      if (verbose) {
        console.log(`✓ Successfully parsed: ${config.name || config.id}`)
      }
    }
  }

  return configs
}

// Setup command line interface
const program = new Command();

program
  .name('kitty-parse')
  .description('Parse TypeScript files and extract configurations')
  .version('1.0.0')
  .option('-o, --output <file>', 'output JSON file', 'result.json')
  .option('-d, --directory <dir>', 'directory to scan', process.cwd())
  .option('-v, --verbose', 'verbose output', false)
  .parse();

const options = program.opts();

const currentDir = options.directory;
const outputFile = options.output;
const verbose = options.verbose;

const allConfigs = parseAllTsFiles(currentDir, verbose);

if (outputFile) {
  try {
    fs.writeFileSync(outputFile, JSON.stringify(allConfigs, null, 2), 'utf-8');
    console.log(`✓ Successfully wrote ${allConfigs.length} configurations to ${outputFile}`);
  } catch (error) {
    console.error(`✗ Failed to write file: ${error.message}`);
    process.exit(1);
  }
} else {
  console.log('\n=== Scan Results ===');
  console.log(`Total parsed ${allConfigs.length} valid configurations`);
  console.log(JSON.stringify(allConfigs, null, 2));
}