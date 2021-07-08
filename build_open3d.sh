
apt-get update -y
apt-get install -y apt-utils build-essential git cmake
apt-get install -y xorg-dev libglu1-mesa-dev
apt-get install -y libblas-dev liblapack-dev liblapacke-dev
apt-get install -y libsdl2-dev libc++-7-dev libc++abi-7-dev libxi-dev
apt-get install -y clang-7
apt-get install -y ccache
git clone --recursive https://github.com/intel-isl/Open3D
cd Open3D && git submodule update --init --recursive && mkdir build &&cd build && cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_CUDA_MODULE=OFF \
    -DBUILD_GUI=OFF \
    -DBUILD_TENSORFLOW_OPS=OFF \
    -DBUILD_PYTORCH_OPS=OFF \
    -DBUILD_UNIT_TESTS=ON \
    -DCMAKE_INSTALL_PREFIX=~/open3d_install \
    -DPYTHON_EXECUTABLE=$(which python) \
    -DBUILD_PYBIND11=ON \
    -DBUILD_PYTHON_MODULE=ON \
    -DGLIBCXX_USE_CXX11_ABI=OFF \
    ..

# Build C++ library
make -j$(nproc)

# Install Open3D python package (optional)
make install-pip-package -j$(nproc)
python -c "import open3d; print(open3d)"
