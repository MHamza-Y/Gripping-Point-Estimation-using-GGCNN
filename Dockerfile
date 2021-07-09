FROM pinto0309/l4t-base:r32.5.0



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


RUN apt-get update -y \
  && apt-get install make
RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*
RUN apt-get update -y \
  && apt install build-essential -y

RUN apt-get install libssl-dev -y

COPY nano_requirements.txt .
RUN pip install -r nano_requirements.txt

WORKDIR /dependency_build
COPY build_cmake.sh .

RUN chmod +x ./build_cmake.sh
RUN ./build_cmake.sh

#COPY build_open3d.sh .
#RUN chmod +x ./build_open3d.sh
##RUN ./build_open3d.sh
RUN apt-get update -y
RUN apt-get install -y apt-utils build-essential git cmake
RUN apt-get install -y xorg-dev libglu1-mesa-dev
RUN apt-get install -y libblas-dev liblapack-dev liblapacke-dev
RUN apt-get install -y libsdl2-dev libc++-7-dev libc++abi-7-dev libxi-dev
RUN apt-get install -y clang-7
RUN apt-get install -y ccache
#
#RUN git clone --recursive https://github.com/intel-isl/Open3D
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

RUN git clone --recursive https://github.com/intel-isl/Open3D \
    && cd Open3D \
    && git submodule update --init --recursive \
    && git clone -b master https://github.com/intel-isl/Open3D-ML \
    && chmod +x util/install_deps_ubuntu.sh \
    && sed -i 's/SUDO=${SUDO:=sudo}/SUDO=${SUDO:=}/g' \
              util/install_deps_ubuntu.sh \
    && util/install_deps_ubuntu.sh assume-yes \
    # https://github.com/intel-isl/Open3D/issues/2468
    # x86_64 : #include "/usr/include/x86_64-linux-gnu/cblas-netlib.h"
    # aarch64: #include "/usr/include/aarch64-linux-gnu/cblas-netlib.h"
    && sed -i -e "/^#include \"open3d\/core\/linalg\/LinalgHeadersCPU.h\"/i #include \"\/usr\/include\/aarch64-linux-gnu\/cblas-netlib.h\"" \
                 cpp/open3d/core/linalg/BlasWrapper.h

RUN cd Open3D \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/open3d \
             -DPYTHON_EXECUTABLE=$(which python3) \
             -DBUILD_PYTHON_MODULE=ON \
             -DBUILD_SHARED_LIBS=ON \
             -DBUILD_EXAMPLES=OFF \
             -DBUILD_UNIT_TESTS=OFF \
             -DBUILD_BENCHMARKS=ON \
             -DBUILD_CUDA_MODULE=ON \
             -DBUILD_CACHED_CUDA_MANAGER=ON \
             -DBUILD_GUI=ON \
             -DBUILD_JUPYTER_EXTENSION=OFF \
             -DWITH_OPENMP=ON \
             -DWITH_IPPICV=ON \
             -DENABLE_HEADLESS_RENDERING=OFF \
             -DSTATIC_WINDOWS_RUNTIME=ON \
             -DGLIBCXX_USE_CXX11_ABI=ON \
             -DBUILD_RPC_INTERFACE=ON \
             -DUSE_BLAS=ON \
             -DBUILD_FILAMENT_FROM_SOURCE=ON \
             -DWITH_FAISS=OFF \
             -DBUILD_LIBREALSENSE=ON \
             -DUSE_SYSTEM_LIBREALSENSE=OFF \
             -DBUILD_AZURE_KINECT=OFF \
             -DBUILD_TENSORFLOW_OPS=OFF \
             -DBUILD_PYTORCH_OPS=OFF \
             -DBUNDLE_OPEN3D_ML=OFF \
             -DOPEN3D_ML_ROOT=../Open3D-ML \
            #  -DCMAKE_FIND_DEBUG_MODE=ON \
             .. \
    && make -j$(nproc) \
    # Only one of each of the following lines can be selected.
    #   (1) install -> Build and install the C++ shared library
    #   (2) install-pip-package -> Install pip-package
    #   (3) python-package -> Build the Python package
    #   (4) conda-package -> Building the conda package
    #   (5) pip-package -> Build the pip wheel file
    && make install && ldconfig \
    # && make -j$(nproc) install-pip-package
    # && make -j$(nproc) python-package
    # && make -j$(nproc) conda-package
    && make -j$(nproc) pip-package
COPY . .
ENV COMMAND python -m gripper_service --GRIPPER_TYPE_RECOGNITION_SERVICE_IP 127.0.0.1:5001 --POINT_CLOUD_PUBLISHER_IP 127.0.0.1:5008 --IMAGE_PUBLISHER_IP 127.0.0.1:5012 --TRIGGER_SIGNAL three_jaw --NUMBER_OF_GRASPS 6 --OUTPUT_PORT 5558
CMD $COMMAND