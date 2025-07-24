#!/bin/sh

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cd ${SRC_DIR}/python

rm -rf build
mkdir build
cd build

Python3_INCLUDE_DIR="$(python -c 'import sysconfig; print(sysconfig.get_path("include"))')"

cmake ${CMAKE_ARGS} -GNinja .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DUSE_SYSTEM_PATHS_FOR_PYTHON_INSTALLATION:BOOL=ON \
    -DPython3_EXECUTABLE:PATH=$PYTHON \
    -DPYTHON_EXECUTABLE:PATH=$PYTHON \
    -DPython3_INCLUDE_DIR:PATH=$Python3_INCLUDE_DIR \
    -DBUILD_TESTING:BOOL=ON

cmake --build . --config Release --verbose
cmake --build . --config Release --verbose --target install

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  ctest --output-on-failure -VV -C Release -E "requester_TEST|pubSub_TEST"
fi
