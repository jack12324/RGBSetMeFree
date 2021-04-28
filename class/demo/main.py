import os
import sys
import shutil
import numpy as np
from PIL import Image

from buildRGB import write_image, write_filter, write_img_size, recover_filter, recover_img_size
from buildImage import read_image 

def main(debug=False):
	# these file will be loaded to/from shared host memory
	input_img_fpath = 'input_bytes.txt' # input image
	img_size_fpath = 'size.txt' # image size
	input_filter_fpath = 'filter.txt' # input filter
	output_img_fpath = 'output_bytes.txt' # output image

	input_filter = np.array([
	  [-1,-1,-1],
	  [-1,8,-1],
	  [-1,-1,-1],
	], np.int8)

	pad_width, height, width = write_image('test.jpeg', input_img_fpath)
	write_filter(input_filter, input_filter_fpath)
	write_img_size(img_size_fpath, height, width)

	if debug:
		actual_filter = recover_filter(input_filter_fpath)
		assert np.array_equal(input_filter, actual_filter)
		actual_size = recover_img_size(img_size_fpath)
		assert (height + 2, width + 2) == actual_size
		print('Test passed!')
		
	# interact with fpga
	# shutil.copy(input_img_fpath, output_img_fpath) # mock fpga interface
	os.system('../bin/cload_sim')

	output_length = (((width + pad_width)*3)+4) * height
	read_image('test_out.jpeg', pad_width=pad_width, height=height, width=width)

if __name__ == '__main__':
	if len(sys.argv) > 1 and sys.argv[1] == 'debug':
		debug = True
		print('***Debug mode***')
	else:
		debug = False
		print('***Normal mode***')
	main(debug)
