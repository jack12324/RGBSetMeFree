# coding=utf-8
import numpy as np
from PIL import Image

# Press the green button in the gutter to run the script.
def deassemble(lines, width, actual_width, height):
    red = []
    green = []
    blue = []
    total_width = (actual_width*3)+4;
    for i in range(height):
        for j in range(width):
            red.append(lines[i*total_width +j])
        for j in range(width):
            green.append(lines[i*total_width + width + 2 +j])
        for j in range(width):
            blue.append(lines[i*total_width + 2 * (width + 2) +j])
    return red, green, blue


def combine_rgb_arrays(red, green, blue, width, height):
    pixels = []
    pixels_org = []
    for i in range(len(red)):
        pixels.append(np.array([int(red[i]), int(green[i]), int(blue[i])]).astype(np.uint8))

    for i in range(height):
        row = []
        for j in range(width):
            row.append(pixels[i*width + j])
        pixels_org.append(np.array(row))

    return np.array(pixels_org)

def rebuild_image(image_name):
    text_file = open("output.txt", "r")
    lines = text_file.read().split('\n')
    print(len(lines))
    text_file.close()
    text_file = open("config.txt", "r")
    config = text_file.read().split('\n')
    text_file.close()
    width = int(config[11])
    height = int(config[1])
    actual_width = int(config[0])

    lines.pop()
    red, green, blue = deassemble(lines, width, actual_width, height)
    pixels = combine_rgb_arrays(red, green, blue, width, height)
    im = Image.fromarray(pixels, "RGB")
    im.save(image_name)
    im.show()

def read_image(output_img_fpath, pad_width, height, width):
    # read image data back from output file
    with open(output_img_fpath, 'rb') as f:
        # number of bytes in memory
        output_length = (((width + pad_width)*3)+4) * height
        output = np.frombuffer(f.read()[:output_length], dtype=np.uint8)
        red, green, blue = deassemble(lines=output, width=width, actual_width=width+pad_width, height=height)
        pixels = combine_rgb_arrays(red, green, blue, width=width, height=height)
        im = Image.fromarray(pixels, "RGB")
        im.save('output.jpeg')
        im.show()


if __name__ == '__main__':
    rebuild_image('rebuilt.jpg');

