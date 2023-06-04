import subprocess
import re

# copy by ChatGPT

with subprocess.Popen(['wget', '-O', 'fonts/LXG.ttf', 'https://github.com/lxgw/LxgwWenKai/releases/latest/download/LXGWWenKai-Regular.ttf'], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True) as p:
  for line in p.stdout:
    print(line)

fontConfig = """
  fonts:
    - family: LXG
      fonts:
        - asset: fonts/LXG.ttf

"""

with open('pubspec.yaml', 'r') as f:
  file_content = f.read()
  file_content = re.sub(r'##HERE\n(.*\n)*\n', fontConfig, file_content)
  print('replace success')

with open('pubspec.yaml', 'w') as f:
  f.write(file_content)