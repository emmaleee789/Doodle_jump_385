import binascii
from PIL import Image

im = Image.open("./Final/img/OIP.jpg")
print(im.format, im.size, im.mode)

hex_string = []
for i in range(0, im.size[0]):
    hex_string.append([])
    for j in range(0, im.size[1]):
        hex_string[i].append([
            str(bin(int(im.getpixel((i,j))[0]/16)))[2:6],
            str(bin(int(im.getpixel((i,j))[1]/16)))[2:6],
            str(bin(int(im.getpixel((i,j))[2]/16)))[2:6]
        ])

#print(hex_string)

with open("./Final/img/hexfile.txt", "w") as hexfile:
    hexfile.write(str(hex_string))
hexfile.close()


# img = "./OIP.jpg"  # Replace with your image file path
# with open(img, 'rb') as f:
#     content = f.read()
#     hex_string = binascii.hexlify(content).decode('utf-8')


# print(hex_string)

# hexfile = open("hexfile.txt", "w")
# hexfile.write(hex_string)
# hexfile.close()
