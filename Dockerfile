FROM python:3.8-slim-buster


ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN apt-get update -y
RUN apt install libgl1-mesa-glx -y
RUN apt-get install 'ffmpeg'\
    'libsm6'\
    'libxext6'  -y

RUN apt-get update -y
RUN apt-get install -y apt-utils build-essential git cmake
RUN apt-get install -y python3 python3-dev python3-pip
RUN apt-get install -y xorg-dev libglu1-mesa-dev
RUN apt-get install -y libblas-dev liblapack-dev liblapacke-dev
RUN apt-get install -y libsdl2-dev libc++-7-dev libc++abi-7-dev libxi-dev
RUN apt-get install -y clang-7
RUN apt-get install -y python3-virtualenv ccache
RUN git clone --recursive https://github.com/intel-isl/Open3D
RUN cd Open3D
RUN git submodule update --init --recursive
RUN mkdir build
RUN cd build
RUN cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_CUDA_MODULE=OFF \
    -DBUILD_GUI=OFF \
    -DBUILD_TENSORFLOW_OPS=OFF \
    -DBUILD_PYTORCH_OPS=OFF \
    -DBUILD_UNIT_TESTS=ON \
    -DCMAKE_INSTALL_PREFIX=~/open3d_install \
    -DPYTHON_EXECUTABLE=$(which python) \
    ..
RUN make -j$(nproc)
RUN make tests -j$(nproc)
RUN ./bin/tests --gtest_filter="-*Reduce*Sum*"
RUN make install
RUN make install-pip-package -j$(nproc)
RUN python -c "import open3d; print(open3d)"
RUN ./bin/Open3D/Open3D

RUN pip3 install --upgrade pip
RUN apt-get update -y \
  && apt-get -y install \
    xvfb \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*
COPY requirements.txt .
RUN pip install -r nano_requirements.txt


COPY . .
ENV COMMAND python -m gripper_service --GRIPPER_TYPE_RECOGNITION_SERVICE_IP 127.0.0.1:5001 --POINT_CLOUD_PUBLISHER_IP 127.0.0.1:5008 --IMAGE_PUBLISHER_IP 127.0.0.1:5012 --TRIGGER_SIGNAL three_jaw --NUMBER_OF_GRASPS 6 --OUTPUT_PORT 5558
CMD $COMMAND