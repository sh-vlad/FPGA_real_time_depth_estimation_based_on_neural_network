from __future__ import print_function
import keyboard
import os
import numpy as np
import matplotlib.pyplot as plt
from skimage.io import imsave, imread, imshow
import sys, msvcrt, time

data_path = 'C:/Users/tomil/Documents/Python_progs/NN/Complex probllems/twoCameraProcessing/i_need_an_order/data24k/'


button_delay = 0.2


image_rows = 224
image_cols = 224


mask_data_path = os.path.join(data_path, 'impr_result/')
left_frame_path = os.path.join(data_path, 'original_l/')
right_frame_path = os.path.join(data_path, 'original_r/')

mask_images = os.listdir(mask_data_path)
left_frame_images = os.listdir(left_frame_path)
right_frame_images = os.listdir(right_frame_path)
list_IDs_temp = [mask_images[k] for k in list(mask_images)]
mask_images.sort()
left_frame_images.sort()
right_frame_images.sort()

total_mask = len(mask_images) 
total_left = len(left_frame_images) 
to_del = []

imgs_m = np.ndarray((total_mask, image_rows, image_cols), dtype=np.uint8)
imgs_l = np.ndarray((total_left, image_rows, image_cols,3), dtype=np.uint8)

keyboard.add_hotkey('page up, page down', lambda: keyboard.write('foobar'))

i = 5176
print('-'*30)
print('Opening files...')

print('-'*30)
font = {'family': 'serif',
        'color':  'darkred',
        'weight': 'normal',
        'size': 16,
        }

while True:
    char = msvcrt.getch()
    
    if (char == b"p"):
        print("Stop!")
        break
    if (char == b"a"):
        print("Left pressed")
        #time.sleep(button_delay)   
        i += 1 
        fig = plt.figure(1)
        #plt.switch_backend('QT5Agg')
        ax=fig.add_subplot(131)
        ax.imshow(imread(mask_data_path+left_frame_images[i]))   

        ax=fig.add_subplot(132)
        ax.imshow(imread(left_frame_path+left_frame_images[i]))  
        ax=fig.add_subplot(133)
        ax.imshow(imread(right_frame_path+left_frame_images[i]))
        fig.suptitle('Picture name - ' + left_frame_images[i] + '. Current iterator: ' + str(i) + '. Length to delete - ' + str(len(to_del)))
        mng = plt.get_current_fig_manager()
        mng.window.showFullScreen()
        plt.show()
    if (char == b"e"):
        to_del.append(i)
    if i % 1000 == 0:
        print('Done: {0}/{1} images'.format(i, total_mask))

print('Loading done.')
for i in to_del:
    os.remove(mask_data_path+left_frame_images[i])
    os.remove(left_frame_path+left_frame_images[i])
    os.remove(right_frame_path+left_frame_images[i])
print('Deleting done.')
