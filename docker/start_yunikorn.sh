#!/bin/bash
declare -r DOCKER_FOLDER=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $DOCKER_FOLDER/docker_build_common.sh

# ===============================[global variables]===============================

declare -r CONFIGMAP=queues.yaml

declare -r VERSION=${REVISION:-${VERSION:-latest}}
declare -r REPO=${REPO:-ghcr.io/skiptests/astraea/yunikorn}
declare -r IMAGE_NAME="$REPO:$VERSION"
declare -r DOCKERFILE=$DOCKER_FOLDER/yuniorn.dockerfile
declare -r DATE=$(date +"%d-%m-%Y")


# ===================================[functions]===================================
function showHelp() {
  echo "Usage: [ENV] start_broker.sh [ ARGUMENTS ]"
  echo "ENV: "
  echo "    REPO=astraea/yunikorn                      set the docker repo"
  echo "    BUILD=false                              set true if you want to build image locally"
  echo "    RUN=false                                set false if you want to build/pull image only"
}
function generateDockerfile() {
cat > $DOCKERFILE << EOF
# this dockerfile is generate dynamically
FROM golang:latest as build
RUN git clone https://github.com/apache/incubator-yunikorn-k8shim.git /tmp/yunikorn
WORKDIR /tmp/yunikorn
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
        go build -a -o=k8s_yunikorn_scheduler -ldflags \
        '-extldflags "-static" -X main.version=latest -X main.date=${DATE}' \
        -tags netgo -installsuffix netgo \
        ./pkg/cmd/shim/

FROM alpine:latest
COPY --from=build /tmp/yunikorn/k8s_yunikorn_scheduler /k8s_yunikorn_scheduler
WORKDIR /
ENV CLUSTER_ID "mycluster"
ENV CLUSTER_VERSION "latest"
ENV POLICY_GROUP "queues"
ENV SCHEDULING_INTERVAL "1s"
ENV LOG_LEVEL "0"
ENV LOG_ENCODING "console"
ENV VOLUME_BINDING_TIMEOUT "10s"
ENV EVENT_CHANNEL_CAPACITY "1048576"
ENV DISPATCHER_TIMEOUT "300s"
ENV KUBE_CLIENT_QPS "1000"
ENV KUBE_CLIENT_BURST "1000"
ENV OPERATOR_PLUGINS "general"
ENV ENABLE_CONFIG_HOT_REFRESH "true"
ENV DISABLE_GANG_SCHEDULING "false"
ENV USER_LABEL_KEY "yunikorn.apache.org/username"
ENTRYPOINT ["sh", "-c", "/k8s_yunikorn_scheduler \
-clusterId=mycluster \
-clusterVersion=latest \
-policyGroup=queues \
-interval=1s \
-logLevel=0 \
-logEncoding=console \
-volumeBindTimeout=10s \
-eventChannelCapacity=1048576 \
-dispatchTimeout=300s \
-kubeQPS=1000 \
-kubeBurst=1000 \
-operatorPlugins=general \
-enableConfigHotRefresh=false \
-disableGangScheduling=false \
-userLabelKey=yunikorn.apache.org/username"]
EOF
}
# ===================================[main]===================================

generateDockerfile
buildImageIfNeed "$IMAGE_NAME"
