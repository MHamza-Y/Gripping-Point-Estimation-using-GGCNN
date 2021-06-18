import numpy as np
from ggcnn.src.ggcnn.ggcnn_torch import predict
import cv2
from utils.dataset_processing import evaluation


def crop_image(image, crop_size=300, crop_y_offset=0):
    try:
        imh, imw, imc = image.shape
        cropped_image = np.zeros([crop_size, crop_size, imc])
        for channel in range(imc):
            cropped_image = image[(imh - crop_size) // 2 - crop_y_offset:(
                                                                                 imh - crop_size) // 2 + crop_size - crop_y_offset,
                            (imw - crop_size) // 2:(imw - crop_size) // 2 + crop_size, channel]
    except ValueError:
        imh, imw = image.shape
        imc = 1
        cropped_image = image[(imh - crop_size) // 2 - crop_y_offset:(
                                                                             imh - crop_size) // 2 + crop_size - crop_y_offset,
                        (imw - crop_size) // 2:(imw - crop_size) // 2 + crop_size]
    print(imc)

    return cropped_image


depth_image = cv2.imread('cornell_dataset_samples/pcd0102d.tiff', cv2.IMREAD_UNCHANGED)
image = cv2.imread('cornell_dataset_samples/pcd0102r.png')
points_out, ang_out, width_out, depth = predict(depth=depth_image)
evaluation.plot_output(crop_image(image), crop_image(depth_image), points_out, ang_out)
