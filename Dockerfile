FROM pinto0309/open3d-build:l4t-r32.5.0



RUN apt-get update -y
RUN apt install libgl1-mesa-glx -y
RUN apt-get install 'ffmpeg'\
    'libsm6'\
    'libxext6'  -y

RUN pip3 install --upgrade pip
RUN apt-get update -y \
  && apt-get -y install \
    xvfb \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*


RUN apt-get install -y build-essential libatlas-base-dev
COPY nano_requirements.txt .
RUN export OPENBLAS_CORETYPE=ARMV8 \
 && pip install -r nano_requirements.txt



COPY . .
ENV COMMAND python -m gripper_service --GRIPPER_TYPE_RECOGNITION_SERVICE_IP 127.0.0.1:5001 --POINT_CLOUD_PUBLISHER_IP 127.0.0.1:5008 --IMAGE_PUBLISHER_IP 127.0.0.1:5012 --TRIGGER_SIGNAL three_jaw --NUMBER_OF_GRASPS 6 --OUTPUT_PORT 5558
CMD $COMMAND