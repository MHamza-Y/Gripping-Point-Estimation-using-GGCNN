FROM python:3.8-slim-buster


ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

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
COPY nano_requirements.txt .
RUN pip install -r nano_requirements.txt

RUN apt-get update -y \
  && apt-get install make
RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*
RUN apt-get update -y \
  && apt install build-essential -y

WORKDIR /dependency_build
COPY . .

RUN chmod +x ./build_cmake.sh
RUN ./build_cmake.sh
RUN chmod +x ./build_open3d.sh
RUN ./build_open3d.sh



ENV COMMAND python -m gripper_service --GRIPPER_TYPE_RECOGNITION_SERVICE_IP 127.0.0.1:5001 --POINT_CLOUD_PUBLISHER_IP 127.0.0.1:5008 --IMAGE_PUBLISHER_IP 127.0.0.1:5012 --TRIGGER_SIGNAL three_jaw --NUMBER_OF_GRASPS 6 --OUTPUT_PORT 5558
CMD $COMMAND