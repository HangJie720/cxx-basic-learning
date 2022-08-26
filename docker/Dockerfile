ARG BASE=nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04
FROM $BASE

RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get install -y \
    automake \
    bison \
    clang-10 \
    cmake \
    flex \
    git \
    kmod \
    libboost-all-dev \
    libedit-dev \
    libfftw3-3 \
    libfftw3-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libz3-dev \
    libz-dev \
    nano \
    netcat-openbsd \
    openssh-server \
    python3-dev \
    python3-pip \
    sudo \
    swig \
    tcl \
    unzip \
    valgrind \
    vim \
    wget \
    libgoogle-glog-dev \
    libgtest-dev \
    liblmdb-dev \
    libopencv-dev \
    libopenmpi-dev \
    protobuf-compiler \
    libsnappy-dev \
    libprotobuf-dev \
    openmpi-bin \
    openmpi-doc \
    libleveldb-dev \
    libgflags-dev

 RUN apt remove -y libz3-dev; \
      if timeout 3 nc -vz 10.201.40.22 80 2> /dev/null; then \
        echo Downloading z3 from internal server...; \
        wget -q http://10.201.40.22/files/sw_home/z3-4.8.8-x64-ubuntu-16.04.zip; \
        echo Downloading cmake from internal server...; \
        wget -q http://10.201.40.22/files/sw_home/cmake-3.18.4.tar.gz; \
      else \
        echo Downloading z3 from external server...; \
        https://github.com/Z3Prover/z3/releases/download/z3-4.8.8/z3-4.8.8-x64-ubuntu-16.04.zip; \
        echo Downloading cmake from external server...; \
        wget https://github.com/Kitware/CMake/releases/download/v3.18.4/cmake-3.18.4.tar.gz; \
      fi; \
      unzip z3-4.8.8-x64-ubuntu-16.04.zip; \
      cp z3-4.8.8-x64-ubuntu-16.04/include/* /usr/include/; \
      cp z3-4.8.8-x64-ubuntu-16.04/bin/libz3.so /lib/x86_64-linux-gnu/; \
      rm -rf z3-4.8.8-x64-ubuntu-16.04*; \
      apt-get remove -y cmake; \
      tar -zxvf cmake-3.18.4.tar.gz; \
      cd cmake-3.18.4; \
      ./bootstrap --prefix=/usr/local/cmake && make -j && make install; \
      ln -s /usr/local/cmake/bin/cmake /usr/bin/cmake; \
      rm -rf ../cmake-3.18.4*; \
      rm -f /usr/bin/python; ln -s /usr/bin/python3 /usr/bin/python; 

RUN pip3 install --upgrade pip
RUN pip3 install absl-py clang cpplint "numpy<1.19.0" Keras-Preprocessing pyyaml pillow scipy

RUN cd /usr/local && \
    if timeout 3 nc -vz 10.201.40.22 80 2> /dev/null; then \
      echo Downloading bazel from internal server...; \
      wget -q http://10.201.40.22/files/sw_home/bazel-0.24.1-installer-linux-x86_64.sh; \
    else \
      echo Downloading bazel from external server...; \
      wget -q https://github.com/bazelbuild/bazel/releases/download/0.24.1/bazel-0.24.1-installer-linux-x86_64.sh; \
    fi && \
    bash bazel-0.24.1-installer-linux-x86_64.sh && \
    bazel version && \
    rm bazel-0.24.1-installer-linux-x86_64.sh
