#!/bin/bash

# usage: ./docker_build.sh 20.04-cu11.0 zhangxin:20.04-cu11.0
if [[ $# != 2 ]]; then
    echo "Wrong parameters number"
    echo "usage example: ./docker_build.sh 20.04-cu11.0 user_name:20.04-cu11.0"
    exit -2
fi

# echo "argv: $1"
UBUNTU_VERSION=`echo $1 | awk -F '-cu' '{print $1}'`
CUDA_VERSION=`echo $1 | awk -F '-cu' '{print $2}'`
echo "ubuntu version:${UBUNTU_VERSION},cuda version:${CUDA_VERSION}"

# echo "argc: $2"
DOCKER_TAG=$2
echo "docker tag:${DOCKER_TAG}"

# check ubuntu version
if [[(${UBUNTU_VERSION} != "18.04") && (${UBUNTU_VERSION} != "20.04") && (${UBUNTU_VERSION} != "22.04")]];then
    echo "Invalid ubuntu version:${UBUNTU_VERSION}"
    exit -1
fi

# pull base image (cudagl)
if [[("${CUDA_VERSION}" == "")]];then
    BASE_IMAGE=nvidia/opengl:1.2-glvnd-devel-ubuntu${UBUNTU_VERSION}
else
    BASE_IMAGE=nvidia/cudagl:${CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION}
fi
echo ${BASE_IMAGE}

docker pull ${BASE_IMAGE}
if [[ $? != 0 ]]; then
    echo "Failed to pull docker image '${BASE_IMAGE}'"
    exit -2
fi

# build ubuntu-desktop image
# if [[("${CUDA_VERSION}" == "")]];then
#     DOCKER_TAG=${UBUNTU_VERSION}
# else
#     DOCKER_TAG=${UBUNTU_VERSION}-cu${CUDA_VERSION}
# fi

docker build ubuntu-desktop --file ubuntu-desktop/${UBUNTU_VERSION}/Dockerfile \
             --build-arg BASE_IMAGE=${BASE_IMAGE} \
             --tag ${DOCKER_TAG}
if [[ $? != 0 ]]; then
    echo "Failed to build docker image '${DOCKER_TAG}'"
    exit -3
fi

exit 0