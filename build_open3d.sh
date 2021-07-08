sudo apt-get update -y
sudo apt-get install -y apt-utils build-essential git cmake
sudo apt-get install -y python3-dev python3-pip
sudo apt-get install -y xorg-dev libglu1-mesa-dev
sudo apt-get install -y libblas-dev liblapack-dev liblapacke-dev
sudo apt-get install -y libsdl2-dev libc++-7-dev libc++abi-7-dev libxi-dev
sudo apt-get install -y clang-7
sudo apt-get install -y python3-virtualenv ccache
git clone --recursive https://github.com/intel-isl/Open3D
cd Open3D
git submodule update --init --recursive
mkdir build
cd build

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_CUDA_MODULE=ON \
    -DBUILD_GUI=ON \
    -DBUILD_TENSORFLOW_OPS=OFF \
    -DBUILD_PYTORCH_OPS=OFF \
    -DBUILD_UNIT_TESTS=ON \
    -DCMAKE_INSTALL_PREFIX=~/open3d_install \
    -DPYTHON_EXECUTABLE=$(which python)

# Build C++ library
make -j$(nproc)

# Run tests (optional)
make tests -j$(nproc)
./bin/tests --gtest_filter="-*Reduce*Sum*"

# Install C++ package (optional)
make install

# Install Open3D python package (optional)
make install-pip-package -j$(nproc)
python -c "import open3d; print(open3d)"
