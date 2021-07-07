from communication.zmq_connector import connect_to_socket_using_ip, subscribe_to_topic, is_trigger_received, get_message
from input_processing.process_point_cloud import raw_point_cloud_to_numpy, unorganized_point_cloud_to_open3d_format, \
    point_cloud_to_depth_image, resize_image
from ggcnn.src.ggcnn.ggcnn_torch import predict
from utils.dataset_processing.grasp import detect_grasps
import sys


GRIPPER_TYPE_RECOGNITION_SERVICE_IP = '127.0.0.1:5001'
POINT_CLOUD_PUBLISHER_IP = '127.0.0.1:5008'
IMAGE_PUBLISHER_IP = '127.0.0.1:5012'
TRIGGER_SIGNAL = 'three_jaw'
MODEL_INPUT_SIZE = (300, 300)
NUMBER_OF_GRASPS = 20

def main():

    gripper_type_recognition_service_socket = connect_to_socket_using_ip(GRIPPER_TYPE_RECOGNITION_SERVICE_IP)
    subscribe_to_topic(gripper_type_recognition_service_socket)
    point_cloud_publisher_socket = connect_to_socket_using_ip(POINT_CLOUD_PUBLISHER_IP)
    subscribe_to_topic(point_cloud_publisher_socket)
    while True:
        if is_trigger_received(gripper_type_recognition_service_socket, TRIGGER_SIGNAL):
            raw_point_cloud_data = get_message(point_cloud_publisher_socket)
            unorganized_pc = raw_point_cloud_to_numpy(raw_point_cloud_data)
            open3d_pcd = unorganized_point_cloud_to_open3d_format(unorganized_pc)
            depth_image = point_cloud_to_depth_image(open3d_pcd)
            depth_image = resize_image(depth_image, MODEL_INPUT_SIZE)
            points_out, ang_out, width_out, depth_out = predict(depth=depth_image)
            detect_grasps(points_out, ang_out, width_img=width_out, no_grasps=NUMBER_OF_GRASPS)

if __name__ == "__main__":
    main()
