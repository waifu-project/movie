import { defineConfig } from 'vite';
import path from 'path';

export default defineConfig({
  build: {
    outDir: 'dist',
    lib: {
      entry: path.resolve(__dirname, 'src/main.js'),
      name: 'kitty',
      fileName: (format) => `kitty.${format}.js`,
      formats: ['es', 'umd', 'cjs']
    },
    rollupOptions: {
      external: [],
      output: {
        exports: 'named',
        inlineDynamicImports: true
      }
    }
  },
  define: {
    'process.env': {}
  }
});