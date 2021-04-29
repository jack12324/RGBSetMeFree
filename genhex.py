import random


with open('loadfile_all.img', 'w') as f:
  for _ in range(65536):
    line = '%02x'%random.randrange(256)
    f.write(line + '\n')