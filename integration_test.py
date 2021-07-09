import numpy as np
import pandas as pd
from ggcnn.src.ggcnn.ggcnn_torch import predict
import cv2
from input_processing.process_point_cloud import unorganized_point_cloud_to_open3d_format, point_cloud_to_depth_image, \
    resize_image
from output_processing.gripping_point import covert_grasping_points_to_input_reference
from utils.dataset_processing import evaluation
from utils.dataset_processing.grasp import detect_grasps
import argument_parser
import datetime
print(argument_parser.args)
print(argument_parser.args.GRIPPER_TYPE_RECOGNITION_SERVICE_IP)

MODEL_INPUT_SIZE = (300, 300)
start = datetime.datetime.now()

unorganized_pc = pd.read_csv('runtime_samples/HKR-1.1.txt', skiprows=3, delimiter=';').to_numpy()
image = cv2.imread('runtime_samples/HKR-1.1.tif')

open3d_pcd = unorganized_point_cloud_to_open3d_format(unorganized_pc)
depth_image = point_cloud_to_depth_image(open3d_pcd)

depth_image = resize_image(depth_image, MODEL_INPUT_SIZE)
image = resize_image(image, MODEL_INPUT_SIZE)
points_out, ang_out, width_out, depth_out = predict(depth=depth_image)
evaluation.plot_output(image, depth_image, points_out, ang_out, grasp_width_img=width_out, no_grasps=3)
out = detect_grasps(points_out, ang_out, width_img=width_out, no_grasps=3)
converted_grasps = covert_grasping_points_to_input_reference(out, unorganized_pc,depth_image)
print(converted_grasps)

end = datetime.datetime.now()
total_time = end - start
print(f'Total execution time: {total_time}')

