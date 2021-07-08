apt remove cmake
apt purge --auto-remove cmake
version=3.19
build=7
mkdir ~/temp
cd ~/temp
wget https://cmake.org/files/v$version/cmake-$version.$build.tar.gz
tar -xzvf cmake-$version.$build.tar.gz
cd cmake-$version.$build/
./bootstrap
make -j4
make install
cp ./bin/cmake /usr/bin/
cmake --version
