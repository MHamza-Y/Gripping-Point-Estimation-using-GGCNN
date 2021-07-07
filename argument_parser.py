import argparse

parser = argparse.ArgumentParser(
    description='Trigger IP, Point Cloud Publisher IP, Image Publisher IP, Trigger signal and Number of Grasps '
                'information')
parser.add_argument('--GRIPPER_TYPE_RECOGNITION_SERVICE_IP', dest='GRIPPER_TYPE_RECOGNITION_SERVICE_IP', type=str,
                    help='Gripper type recognition service ip')

parser.add_argument('--POINT_CLOUD_PUBLISHER_IP', dest='POINT_CLOUD_PUBLISHER_IP', type=str,
                    help='Point cloud publisher ip')

parser.add_argument('--IMAGE_PUBLISHER_IP', dest='IMAGE_PUBLISHER_IP', type=str,
                    help='Image publisher ip')

parser.add_argument('--TRIGGER_SIGNAL', dest='TRIGGER_SIGNAL', type=str,
                    help='Trigger signal')

parser.add_argument('--NUMBER_OF_GRASPS', dest='NUMBER_OF_GRASPS', type=int,
                    help='Number of grasps')

parser.add_argument('--OUTPUT_PORT', dest='OUTPUT_PORT', type=int,
                    help='Output data port')

args = parser.parse_args()

# python integration_test.py --GRIPPER_TYPE_RECOGNITION_SERVICE_IP 127.0.0.1:5001 --POINT_CLOUD_PUBLISHER_IP 127.0.0.1:5008 --IMAGE_PUBLISHER_IP 127.0.0.1:5012 --TRIGGER_SIGNAL three_jaw --NUMBER_OF_GRASPS 6 --OUTPUT_PORT 5558
