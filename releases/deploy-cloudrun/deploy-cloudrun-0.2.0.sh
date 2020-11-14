#!/bin/bash

# Enable KANICO to speedup docker builds
# https://cloud.google.com/cloud-build/docs/kaniko-cache#kaniko-build
# gcloud config set builds/use_kaniko True
# gcloud config set builds/kaniko_cache_ttl 168

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace # show variable assignment

# REGION
REGISTRY=${REGISTRY:-us.gcr.io}
GCP_REGION=${GCP_REGION:-us-east4}
DOCKER_IMAGE_NAME=${DOCKER_IMAGE_NAME:-docker-image}
TAG=${TAG:-latest}
APPLICATION_NAME=${APPLICATION_NAME:-application-name}
PROJECT_ID=${PROJECT_ID}
MEMORY=${MEMORY:-384Mi}
MAX_INSTANCES=${MAX_INSTANCES:-2}
PORT=${PORT:-8000}
CONCURRENCY=${CONCURRENCY:-20}
TIMEOUT=${TIMEOUT:-20}
GCP_BUILD_ENABLED=${GCP_BUILD_ENABLED:-true}
DOCKERFILE_PATH=${DOCKERFILE_PATH:-true}

if [ "$GCP_BUILD_ENABLED" == "true" ]; then
    cp $DOCKERFILE_PATH Dockerfile
    gcloud builds submit --project "${PROJECT_ID}" \
    --tag "${REGISTRY}/${PROJECT_ID}/${DOCKER_IMAGE_NAME}:${TAG}" .
    rm ./Dockerfile
fi

gcloud run deploy "${APPLICATION_NAME}" \
  --project "${PROJECT_ID}" \
  --platform "managed" \
  --region "${GCP_REGION}" \
  --image "${REGISTRY}/${PROJECT_ID}/${DOCKER_IMAGE_NAME}:${TAG}" \
  --port "$PORT" \
  --concurrency "$CONCURRENCY" \
  --max-instances "$MAX_INSTANCES" \
  --memory "${MEMORY}" \
  --timeout "$TIMEOUT" \
  --allow-unauthenticated
