FROM ubuntu:24.04

ENV LANG=C.UTF-8

MAINTAINER Aziz Atoev <a.atoev93@gmail.com>

USER root

# -----------------------------------------CONFIGURATIONS---------------------------------------------------------------
## Support various rvm, nvm etc stuff which requires executing profile scripts (-l)
SHELL ["/bin/bash", "-lc"]
CMD ["/bin/bash", "-l"]

## Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

## -------------------------------------------REPOSITORIES---------------------------------------------------------------
#RUN apt-get update && apt-get install -y apt-utils apt-transport-https software-properties-common && \
#    apt-add-repository ppa:git-core/ppa -y &&  \
#    apt-add-repository ppa:openjdk-r/ppa -y &&  \
#    apt update
## ---------------------------------------------ARGUMANTS----------------------------------------------------------------
#ARG TARGETARCH

# --------------------------------------------ENVIRONMENT VARIABLES-----------------------------------------------------
## GRADLE
ENV GRADLE_VERSION=8.7 \
    GRADLE_ROOT="/usr/local/gradle"
ENV GRADLE_URL="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    GRADLE_FILE="gradle-$GRADLE_VERSION"
ENV PATH="$GRADLE_ROOT/$GRADLE_FILE/bin:$PATH"

## ANDROID
ENV TOOLS_REVISION="11076708"
ENV ANDROID_SDK_VERSION=33 \
    ANDROID_BUILD_TOOLS_VERSION=33.0.1 \
    TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-${TOOLS_REVISION}_latest.zip" \
    ANDROID_SDK_ROOT="/usr/local/android-sdk"
ENV ANDROID_SDK_FILE="android-sdk-$ANDROID_SDK_VERSION.zip" \
    PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/cmdline-tools/tools/bin:$PATH"

## NODEJS
ENV NODEJS_VERSION="20.x" \
    YARN_URL="https://dl.yarnpkg.com/debian"
ENV NODEJS_URL="https://deb.nodesource.com/setup_$NODEJS_VERSION"

# --------------------------------------------INSTALL BASE PACKAGES-----------------------------------------------------
RUN apt update &&  apt install -y \
    # Useful utilities \
    curl unzip
#     wget socat man-db rsync moreutils vim lsof xxd gnupg \
#    bzip2 libassuan-dev libgcrypt20-dev libgpg-error-dev libksba-dev libnpth0-dev \
#    # Setup Java \
#    openjdk-17-jdk-headless \
#    # Setup Ruby \
#    ruby-full \
#    # Python 3 \
#    python3-matplotlib python3-numpy python3-pip python3-scipy python3-pandas python3-dev pipenv

# ------------------------------------------DOWNLOAD AND INSTALL GRADLE-------------------------------------------------
RUN mkdir -p "$GRADLE_ROOT" &&  \
    cd "$GRADLE_ROOT" && \
    curl -L "$GRADLE_URL" -o "$GRADLE_FILE.zip" && \
    unzip "$GRADLE_FILE.zip" && \
    rm "$GRADLE_FILE.zip"

# ----------------------------------------------DOWNLOAD ANDROID SDK----------------------------------------------------
RUN mkdir -p "$ANDROID_SDK_ROOT" .android "$ANDROID_SDK_ROOT/cmdline-tools" && \
    cd "$ANDROID_SDK_ROOT/cmdline-tools" && \
    curl -L "$TOOLS_URL" -o "$ANDROID_SDK_FILE"  && \
    unzip "$ANDROID_SDK_FILE" && \
    rm "$ANDROID_SDK_FILE" && \
    mv cmdline-tools tools && \
    yes | $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager --licenses

# -------------------------------------------INSTALL ANDROID BUILD TOOLS------------------------------------------------
RUN $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager --update
RUN $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION" \
"platforms;android-$ANDROID_SDK_VERSION" \
"platform-tools"

# --------------------------------------------------NODEJS, NPM, YARN---------------------------------------------------
RUN set -ex -o pipefail &&  \
    curl -fsSL "$NODEJS_URL" | bash - && \
    curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] $YARN_URL stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt update && apt install -y nodejs yarn

# -----------------------------------------------------CLOUD TOOLS------------------------------------------------------
RUN set -ex -o pipefail && \
    # Docker \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list && \
    apt install -y docker.io && \
    docker --version && \
    # Kubernetes \
    curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt update && apt install -y kubectl && \
    kubectl version --client && \
    # rclone \
    curl -fsSL https://downloads.rclone.org/v1.56.2/rclone-v1.56.2-linux-$TARGETARCH.zip -o /tmp/rclone.zip && \
    mkdir -p /tmp/rclone.extracted && unzip -q /tmp/rclone.zip -d /tmp/rclone.extraced && \
    install -g root -o root -m 0755 -v /tmp/rclone.extraced/*/rclone /usr/local/bin && \
    rm -rf /tmp/rclone.extraced /tmp/rclone.zip && \
    rclone --version

## Docker compose (https://docs.docker.com/compose/install/)
## There are no arm64 builds of docker-compose for version 1.x.x, so version 2.x.x is used
RUN if [ "$TARGETARCH" == "arm64" ] ; \
      then DOCKER_COMPOSE_VERSION=v2.14.0 ; \
      else DOCKER_COMPOSE_VERSION=1.29.2 ; \
    fi && \
    set -ex -o pipefail && \
    curl -fsSL "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    rm -f /usr/bin/docker-compose && \
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# -------------------------------------------------------SUMMARY--------------------------------------------------------
RUN echo "############################### Versions #####################################" && \
    make --version && \
    echo "" && \
    java -version &&  \
    echo "" && \
    gradle --version && \
    echo "" && \
    ruby --version && \
    python3 --version &&  \
    python2 --version &&  \
    pip3 --version && \
    echo "" && \
    echo "Nodejs: $(node --version)" &&  \
    echo "Npm: $(npm --version)" &&  \
    echo "Yarn: $(yarn --version)" && \
    echo "" && \
    docker --version &&  \
    docker-compose --version && \
    echo "" && \
    echo "Kubectl: $(kubectl version --client)" && \
    echo "" && \
    rclone --version && \
    echo "############################### Versions #####################################"
