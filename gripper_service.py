import numpy as np

from communication.zmq_connector import connect_to_subscriber_socket_using_ip, subscribe_to_topic, is_trigger_received, \
    get_message, connect_to_publisher_socket_using_ip, send_message
from input_processing.process_point_cloud import raw_point_cloud_to_numpy, unorganized_point_cloud_to_open3d_format, \
    point_cloud_to_depth_image, resize_image
from ggcnn.src.ggcnn.ggcnn_torch import predict
from output_processing.gripping_point import covert_grasping_points_to_input_reference
from utils.dataset_processing.grasp import detect_grasps
import argument_parser

GRIPPER_TYPE_RECOGNITION_SERVICE_IP = argument_parser.args.GRIPPER_TYPE_RECOGNITION_SERVICE_IP
POINT_CLOUD_PUBLISHER_IP = argument_parser.args.POINT_CLOUD_PUBLISHER_IP
IMAGE_PUBLISHER_IP = argument_parser.args.IMAGE_PUBLISHER_IP
TRIGGER_SIGNAL = argument_parser.args.TRIGGER_SIGNAL
MODEL_INPUT_SIZE = (300, 300)
NUMBER_OF_GRASPS = argument_parser.args.NUMBER_OF_GRASPS
OUTPUT_PORT = argument_parser.args.OUTPUT_PORT


def main():
    gripper_type_recognition_service_socket = connect_to_subscriber_socket_using_ip(GRIPPER_TYPE_RECOGNITION_SERVICE_IP)
    subscribe_to_topic(gripper_type_recognition_service_socket)
    point_cloud_publisher_socket = connect_to_subscriber_socket_using_ip(POINT_CLOUD_PUBLISHER_IP)
    subscribe_to_topic(point_cloud_publisher_socket)
    output_socket = connect_to_publisher_socket_using_ip(OUTPUT_PORT)
    while True:
        if is_trigger_received(gripper_type_recognition_service_socket, TRIGGER_SIGNAL):
            raw_point_cloud_data = get_message(point_cloud_publisher_socket)
            unorganized_pc = raw_point_cloud_to_numpy(raw_point_cloud_data)
            open3d_pcd = unorganized_point_cloud_to_open3d_format(unorganized_pc)
            depth_image = point_cloud_to_depth_image(open3d_pcd)
            depth_image = resize_image(depth_image, MODEL_INPUT_SIZE)
            points_out, ang_out, width_out, depth_out = predict(depth=depth_image)
            out = detect_grasps(points_out, ang_out, width_img=width_out, no_grasps=NUMBER_OF_GRASPS)
            converted_grasps = covert_grasping_points_to_input_reference(out, unorganized_pc, depth_image)
            converted_grasps_stringify = np.array2string(converted_grasps)
            send_message(output_socket, 'three_jaw_out', converted_grasps_stringify)


if __name__ == "__main__":
    main()
