#!/bin/bash

if [ -z "$NDK_PATH" ]; then
    echo "NDK_PATH is not defined or is empty" >&2
    exit -1
fi

NDK_PATH=$( cd "$NDK_PATH" && pwd ) # get the absoulte path of ndk 

if [ -z "$ANDROID_ARCH_ABI" ]; then
    ANDROID_ARCH_ABI="arm64-v8a"
fi

if [ -z "$ANDROID_API_LEVEL" ]; then
    ANDROID_API_LEVEL=23
fi

if [ "$ANDROID_ARCH_ABI" != "arm64-v8a" ] \
    && [ "$ANDROID_ARCH_ABI" != "armeabi-v7a" ] \
    && [ "$ANDROID_ARCH_ABI" != "x86" ] \
    && [ "$ANDROID_ARCH_ABI" != "x86_64" ] \
    && [ "$ANDROID_ARCH_ABI" != "riscv64" ]; then
    echo "Not supported abi: $ANDROID_ARCH_ABI" >&2
    exit -1
fi
if [[ ! "$ANDROID_API_LEVEL" =~ [0-9]+ ]] || [ ! $ANDROID_API_LEVEL -ge 21 ]; then
    echo "Not supported api level: $ANDROID_API_LEVEL" >&2
    exit -1
fi

echo "NDK PATH: $NDK_PATH"
echo "Android API: $ANDROID_API_LEVEL"
echo "Android ABI: $ANDROID_ARCH_ABI"

SOURCE_DIR=$(cd $(dirname $0) && pwd)
COMMON_BUILD_PLUGIN_OPTIONS=(\
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_CXX_FLAGS="-Os" \
    -DCMAKE_INSTALL_PREFIX="$SOURCE_DIR" \
    -DCMAKE_TOOLCHAIN_FILE="$NDK_PATH/build/cmake/android.toolchain.cmake" \
    -DANDROID_USE_LEGACY_TOOLCHAIN_FILE=ON \
    -DANDROID_NATIVE_API_LEVEL="$ANDROID_API_LEVEL" \
    -DANDROID_NDK="$NDK_PATH" \
    -DANDROID_ABI="$ANDROID_ARCH_ABI"
)


build_and_install_boost() {
    echo "Would you like to build boost ?(y/n)"
    read -r choice
    if [ $choice = "y" ]; then
        echo "Start to build boost..."
        boost_dir=$(find "$SOURCE_DIR/deps" -maxdepth 1 -type d -name boost*)
        if [ -z $boost_dir ]; then
            $SOURCE_DIR/install-boost.sh --download
            boost_dir=$(find "$SOURCE_DIR/deps" -maxdepth 1 -type d -name boost*)
        fi
        cd $boost_dir
        cp -r boost $SOURCE_DIR/include
    fi
}

build_and_install_glog() {
    glog_dir=$(find "$SOURCE_DIR/deps" -maxdepth 1 -type d -name glog)
    if [ -z $glog_dir ]; then
        echo "Can not find glog." >&2
        exit -1
    fi
    echo "Would you like to build glog ?(y/n)"
    read -r choice
    if [ $choice = "y" ]; then
        cd $glog_dir
        echo "Start to build glog..."
        rm -rf build
        cmake . -Bbuild ${COMMON_BUILD_PLUGIN_OPTIONS[@]} \
            -DWITH_GFLAGS=OFF \
            -DWITH_GTEST=OFF \
            -DWITH_SYMBOLIZE=OFF \
            -DWITH_PKGCONFIG=ON
        cmake --build build -j16
        cmake --install build
    fi
}

build_and_install_gtest() {
    gtest_dir=$(find "$SOURCE_DIR/deps" -maxdepth 1 -type d -name googletest)
    if [ -z $gtest_dir ]; then
        echo "Can not find googletest." >&2
        exit -1
    fi
    echo "Would you like to build googletest ?(y/n)"
    read -r choice
    if [ $choice = "y" ]; then
        cd $gtest_dir
        echo "Start to build googletest..."
        rm -rf build
        cmake . -Bbuild ${COMMON_BUILD_PLUGIN_OPTIONS[@]} \
            -DBUILD_GMOCK=OFF \
            -DINSTALL_GTEST=ON \
            -DGTEST_HAS_ABSL=OFF
        cmake --build build -j16
        cmake --install build
    fi
}

build_and_install_leveldb() {
    leveldb_dir=$(find "$SOURCE_DIR/deps" -maxdepth 1 -type d -name leveldb)
    if [ -z $leveldb_dir ]; then
        echo "Can not find leveldb." >&2
        exit -1
    fi
    echo "Would you like to build leveldb ?(y/n)"
    read -r choice
    if [ $choice = "y" ]; then
        cd $leveldb_dir
        echo "Start to build leveldb..."
        rm -rf build
        cmake . -Bbuild ${COMMON_BUILD_PLUGIN_OPTIONS[@]} \
            -DLEVELDB_BUILD_TESTS=OFF \
            -DLEVELDB_BUILD_BENCHMARKS=OFF \
            -DLEVELDB_INSTALL=ON
        cmake --build build -j16
        cmake --install build
    fi
}

build_and_install_marisa_trie() {
    marisa_trie_dir=$(find "$SOURCE_DIR/deps" -maxdepth 1 -type d -name marisa-trie)
    if [ -z $marisa_trie_dir ]; then
        echo "Can not find marisa-trie." >&2
        exit -1
    fi
    echo "Would you like to build marisa-trie ?(y/n)"
    read -r choice
    if [ $choice = "y" ]; then
        cd $marisa_trie_dir
        echo "Start to build marisa-trie..."
        rm -rf build
        cmake . -Bbuild ${COMMON_BUILD_PLUGIN_OPTIONS[@]}
        cmake --build build -j16
        cmake --install build
    fi
}

build_and_install_opencc() {
    opencc_dir=$(find "$SOURCE_DIR/deps" -maxdepth 1 -type d -name opencc)
    if [ -z $opencc_dir ]; then
        echo "Can not find opencc." >&2
        exit -1
    fi
    echo "Would you like to build opencc ?(y/n)"
    read -r choice
    if [ $choice = "y" ]; then
        cd $opencc_dir
        echo "Start to build opencc..."
        rm -rf build
        cmake . -Bbuild ${COMMON_BUILD_PLUGIN_OPTIONS[@]} \
            -DBUILD_DOCUMENTATION=OFF \
            -DENABLE_GTEST=OFF \
            -DENABLE_BENCHMARK=OFF \
            -DENABLE_DARTS=OFF
        cmake --build build -j16
        cmake --install build
    fi
}

build_and_install_yaml_cpp() {
    yaml_cpp_dir=$(find "$SOURCE_DIR/deps" -maxdepth 1 -type d -name yaml-cpp)
    if [ -z $yaml_cpp_dir ]; then
        echo "Can not find yaml-cpp." >&2
        exit -1
    fi
    echo "Would you like to build yaml-cpp ?(y/n)"
    read -r choice
    if [ $choice = "y" ]; then
        cd $yaml_cpp_dir
        echo "Start to build yaml-cpp..."
        rm -rf build
        cmake . -Bbuild ${COMMON_BUILD_PLUGIN_OPTIONS[@]} \
            -DYAML_CPP_BUILD_CONTRIB=OFF \
            -DYAML_CPP_BUILD_TOOLS=OFF \
            -DYAML_CPP_FORMAT_SOURCE=OFF
        cmake --build build -j16
        cmake --install build
    fi
}

build_librime() {
    echo "Would you like to build librime ?(y/n)"
    read -r choice
    if [ $choice = "y" ]; then
        cd "$SOURCE_DIR"
        echo "Start to build librime..."
        BUILD_DIR="build/$ANDROID_ARCH_ABI"
        rm -rf "$BUILD_DIR"
        cmake . -B"$BUILD_DIR" \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_FIND_ROOT_PATH="$SOURCE_DIR" \
            -DCMAKE_SHARED_LINKER_FLAGS="-llog -s" \
            -DCMAKE_EXE_LINKER_FLAGS="-llog -s" \
            -DCMAKE_CXX_FLAGS="-Os" \
            -DBUILD_SHARED_LIBS=ON \
            -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
            -DCMAKE_TOOLCHAIN_FILE="$NDK_PATH/build/cmake/android.toolchain.cmake" \
            -DENABLE_LOGGING=OFF \
            -DANDROID_USE_LEGACY_TOOLCHAIN_FILE=ON \
            -DANDROID_NATIVE_API_LEVEL="$ANDROID_API_LEVEL" \
            -DANDROID_NDK="$NDK_PATH" \
            -DANDROID_ABI="$ANDROID_ARCH_ABI" \
            -DBUILD_MERGED_PLUGINS=ON \
            -DENABLE_EXTERNAL_PLUGINS=OFF \
            -DBUILD_STATIC=ON \
            -DBUILD_DATA=ON \
            -DBUILD_TEST=OFF
        cmake --build "$BUILD_DIR" -j16
    fi
}

build_and_install_boost
build_and_install_glog
build_and_install_gtest
build_and_install_leveldb
build_and_install_marisa_trie
build_and_install_opencc
build_and_install_yaml_cpp
build_librime