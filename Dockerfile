ARG AVDEPS_VERSION
ARG CUDA_VERSION=9.0
ARG OS_VERSION=7
ARG NPROC=1
FROM alicevision/alicevision-deps:${AVDEPS_VERSION}-centos${OS_VERSION}-cuda${CUDA_VERSION}
LABEL maintainer="AliceVision Team alicevision-team@googlegroups.com"

# use CUDA_TAG to select the image version to use
# see https://hub.docker.com/r/nvidia/cuda/
#
# CUDA_TAG=8.0-devel
# docker build --build-arg CUDA_TAG=$CUDA_TAG --tag alicevision:$CUDA_TAG .
#
# then execute with nvidia docker (https://github.com/nvidia/nvidia-docker/wiki/Installation-(version-2.0))
# docker run -it --runtime=nvidia alicevision

ENV AV_DEV=/opt/AliceVision_git \
    AV_BUILD=/tmp/AliceVision_build \
    AV_INSTALL=/opt/AliceVision_install \
    AV_BUNDLE=/opt/AliceVision_bundle \
    PATH="${PATH}:${AV_BUNDLE}" \
    VERBOSE=1

COPY . "${AV_DEV}"

WORKDIR "${AV_BUILD}"
RUN cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS:BOOL=ON -DTARGET_ARCHITECTURE=core \
      -DALICEVISION_BUILD_DEPENDENCIES:BOOL=OFF \
      -DCMAKE_PREFIX_PATH:PATH="${AV_INSTALL}" \
      -DCMAKE_INSTALL_PREFIX:PATH="${AV_INSTALL}" -DALICEVISION_BUNDLE_PREFIX="${AV_BUNDLE}" \
      -DALICEVISION_USE_ALEMBIC=ON -DMINIGLOG=ON -DALICEVISION_USE_CCTAG=ON -DALICEVISION_USE_OPENCV=ON -DALICEVISION_USE_OPENGV=ON \
      -DALICEVISION_USE_POPSIFT=ON -DALICEVISION_USE_CUDA=ON -DALICEVISION_BUILD_DOC=OFF -DALICEVISION_BUILD_EXAMPLES=OFF \
      "${AV_DEV}"

RUN make install && make bundle
# && cd /opt && rm -rf "${AV_BUILD}"

