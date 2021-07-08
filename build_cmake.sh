apt remove cmake
apt purge --auto-remove cmake

mkdir ~/temp
cd ~/temp
wget https://cmake.org/files/v3.21/cmake-3.21.0-rc1.tar.gz
tar -xzvf cmake-3.21.0-rc1.tar.gz
cd cmake-3.21.0-rc1/
./bootstrap
make -j4
make install
cp ./bin/cmake /usr/bin/
cmake --version
