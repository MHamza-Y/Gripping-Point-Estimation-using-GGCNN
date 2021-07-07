import zmq
import time

SUBSCRIPTION_SLEEP_TIME = 3


def connect_to_socket_using_ip(ip):
    context = zmq.Context()
    socket = context.socket(zmq.SUB)
    connection_command = "tcp://{}".format(ip)
    socket.connect(connection_command)
    print(f'Connected using {connection_command}')
    return socket


def subscribe_to_topic(socket, topic=""):
    socket.subscribe(topic)
    time.sleep(SUBSCRIPTION_SLEEP_TIME)
    topic_names = 'All' if topic == "" else topic
    print(f'Subscribed to {topic_names}')


def is_trigger_received(socket, trigger_signal):
    msg = socket.recv_string()
    trigger_received = False
    if msg == trigger_signal:
        trigger_received = True

    return trigger_received


def get_message(socket):
    msg = socket.recv_string()
    return msg
