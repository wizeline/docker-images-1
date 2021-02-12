#!/bin/bash

set -eo pipefail

#
# Parameter 1: image name
# Parameter 2: path to component (if different)
#
build_docker_image () {
    IMAGE_NAME=$1;
    IMAGE_PATH=$2;
    
    if [ -z "$IMAGE_PATH" ]; then
        IMAGE_PATH=${IMAGE_NAME};
    fi
    
    IMAGE_PATH="${IMAGE_PATH}/${DEBEZIUM_VERSION}"

    echo ""
    echo "****************************************************************"
    echo "** Validating  debezium/${IMAGE_NAME}"
    echo "****************************************************************"
    echo ""
    docker run --rm -i hadolint/hadolint:latest < "${IMAGE_PATH}"

    echo "****************************************************************"
    echo "** Building    ${IMAGE_NAME}:${DEBEZIUM_VERSION}"
    echo "****************************************************************"
    docker build -t "${IMAGE_NAME}:latest" "${IMAGE_PATH}"

    echo "****************************************************************"
    echo "** Tag         ${IMAGE_NAME}:${DEBEZIUM_VERSION}"
    echo "****************************************************************"
    docker tag "${IMAGE_NAME}:latest" "${IMAGE_NAME}:${DEBEZIUM_VERSION}"
}


if [[ -z "$1" ]]; then
    echo ""
    echo "A version must be specified."
    echo ""
    echo "Usage:  build-wizeline <version>";
    echo ""
    exit 1;
fi

DEBEZIUM_VERSION="$1"

build_docker_image example-wizeline-postgres examples/postgres-orders
build_docker_image example-wizeline-mysql examples/mysql-orders

echo ""
echo "**********************************"
echo "Successfully created Docker images"
echo "**********************************"
echo ""
