# coding=utf-8
import numpy as np
from PIL import Image


def separate_pixel_array(pixels):
    red = []
    green = []
    blue = []
    for pixel in pixels:
        red.append(pixel[0])
        green.append(pixel[1])
        blue.append(pixel[2])
    return red, green, blue


def assemble(red, green, blue, width, pad_width, height):
    row_width = (width + pad_width + 2) * 3
    pixels = []
    for i in range(row_width):
        pixels.append(0)

    for i in range(height):
        pixels.append(0)
        for j in range(width):
            pixels.append(red[i * width + j])
        pixels.append(0)
        pixels.append(0)
        for j in range(width):
            pixels.append(green[i * width + j])
        pixels.append(0)
        pixels.append(0)
        for j in range(width):
            pixels.append(blue[i * width + j])
        pixels.append(0)
        for j in range(pad_width * 3):
            pixels.append(0)

    for i in range(row_width):
        pixels.append(0)

    return pixels


def write_to_file(assembled_pixels, width, height):
    f = open("RGB.txt", "w")
    total_width = 3 * (width + 2)
    for i in range(height + 2):
        for j in range(total_width - 1):
            f.write('{:02x}'.format(assembled_pixels[i * total_width + j]) + " ")
        f.write('{:02x}'.format(assembled_pixels[(i + 1) * total_width - 1]) + "\n")
    f.close()


def write_config(image_width, height, filter, true_width):
    f = open("config.txt", "w")
    f.write(str(image_width))
    f.write('\n'+str(height))
    for i in range(9):
        f.write('\n'+str(filter[i]))
    f.write('\n'+str(true_width))
    f.close()


def create_pixel_array(image_name):
    img = Image.open(image_name)
    a = np.asarray(img)
    height = len(a)
    width = len(a[0])

    pixels = list(img.getdata())
    red, green, blue = separate_pixel_array(pixels)

    pad_width = 64 - ((width - 20) % 64)
    if pad_width < 0:
        pad_width = 0

    assembled_pixels = assemble(red, green, blue, width, pad_width, height)
    write_to_file(assembled_pixels, width + pad_width, height)

    filter = [-1,-1,-1,-1,8,-1,-1,-1,-1]
    write_config(width+pad_width, height, filter, width)

if __name__ == '__main__':
    create_pixel_array('test.jpeg')

# See PyCharm help at https://www.jetbrains.com/help/pycharm/
