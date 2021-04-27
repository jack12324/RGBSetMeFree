import os
import shutil
import numpy as np
import cv2

# these file will be loaded to/from shared host memory
input_img_fpath = 'input.txt' # input image
img_size_fpath = 'size.txt' # image size
input_filter_fpath = 'filter.txt' # input filter
output_img_fpath = 'output.txt' # output image

input_filter = np.array([
  [1, 2, 3],
  [4, 5, 6],
  [7, 8, 9],
])

img = cv2.imread('test.jpeg')

# add zero padding
img = np.pad(img, ((1, 1), (1,1), (0, 0)))
shape = img.shape
height, width, _ = shape
print(height, width)

# save image data as bytes
with open(input_img_fpath, 'wb') as f:
  f.write(img.flatten().tobytes())

# save image size
with open (img_size_fpath, 'wb') as f:
  # convert height, width to 2 bytes big endian each
  data = height.to_bytes(2, 'little') + width.to_bytes(2, 'little')
  f.write(data)

# save filter data as bytes
with open(input_filter_fpath, 'wb') as f:
  f.write(input_filter.flatten().tobytes())

# interact with fpga
# shutil.copy(input_img_fpath, output_img_fpath) # mock fpga interface
os.system('../bin/cload_sim')
print('finish')

# read image data back from output file
with open(output_img_fpath, 'rb') as f:
  # read back as unsigned byte array
  output = np.frombuffer(f.read()[:height*width*3], dtype='B')
  print(output.shape)
  # reshape to original image shape
  output = np.reshape(output, shape)
  cv2.imshow('output', output)
  cv2.waitKey()