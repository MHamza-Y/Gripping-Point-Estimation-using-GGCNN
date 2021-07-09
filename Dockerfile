FROM python:3.8-slim-buster



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
RUN pip3 install -r nano_requirements.txt

RUN apt-get update -y \
  && apt-get install make
RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*
RUN apt-get update -y \
  && apt install build-essential -y

RUN apt-get install libssl-dev

WORKDIR /dependency_build
COPY build_cmake.sh .

RUN chmod +x ./build_cmake.sh
RUN ./build_cmake.sh

COPY build_open3d.sh .
RUN chmod +x ./build_open3d.sh
#RUN ./build_open3d.sh
RUN apt-get update -y
RUN apt-get install -y apt-utils build-essential git cmake
RUN apt-get install -y xorg-dev libglu1-mesa-dev
RUN apt-get install -y libblas-dev liblapack-dev liblapacke-dev
RUN apt-get install -y libsdl2-dev libc++-7-dev libc++abi-7-dev libxi-dev
RUN apt-get install -y clang-7
RUN apt-get install -y ccache
RUN apt-get install -y python3 python3-dev python3-pip

RUN git clone --recursive https://github.com/intel-isl/Open3D
#RUN cd Open3D && git submodule update --init --recursive && mkdir build &&cd build && cmake \
#    -DCMAKE_BUILD_TYPE=Release \
#    -DBUILD_SHARED_LIBS=ON \
#    -DBUILD_CUDA_MODULE=OFF \
#    -DBUILD_GUI=OFF \
#    -DBUILD_TENSORFLOW_OPS=OFF \
#    -DBUILD_PYTORCH_OPS=OFF \
#    -DBUILD_UNIT_TESTS=OFF \
#    -DCMAKE_INSTALL_PREFIX=~/open3d_install \
#    -DPYTHON_EXECUTABLE=$(which python) \
#    -DBUILD_PYBIND11=ON \
#    -DBUILD_PYTHON_MODULE=ON \
#    .. \
#    && make -j$(nproc) \
#    && make install && ldconfig \
#    && make -j$(nproc) pip-package

RUN ./build_open3d.sh
COPY . .
ENV COMMAND python -m gripper_service --GRIPPER_TYPE_RECOGNITION_SERVICE_IP 127.0.0.1:5001 --POINT_CLOUD_PUBLISHER_IP 127.0.0.1:5008 --IMAGE_PUBLISHER_IP 127.0.0.1:5012 --TRIGGER_SIGNAL three_jaw --NUMBER_OF_GRASPS 6 --OUTPUT_PORT 5558
CMD $COMMAND