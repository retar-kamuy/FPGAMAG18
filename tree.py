import os

for root, dirs, files in os.walk(top='./src'):
    for dir in dirs:
        dirPath = os.path.join(root, dir)
        print(f'dirPath = {dirPath}')

    for file in files:
        filePath = os.path.join(root, file)
        print(f'filePath = {filePath}')