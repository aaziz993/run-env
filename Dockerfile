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

# -------------------------------------------REPOSITORIES---------------------------------------------------------------
#RUN apt-get update && apt-get install -y apt-utils apt-transport-https software-properties-common && \
#    apt-add-repository ppa:git-core/ppa -y &&  \
#    apt-add-repository ppa:openjdk-r/ppa -y &&  \
#    apt update
# ---------------------------------------------ARGUMANTS----------------------------------------------------------------

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
    YARN_URL="https://dl.yarnpkg.com/debian stable main" \
    YARN_GPG_KEY_URL="https://dl.yarnpkg.com/debian/pubkey.gpg"
ENV NODEJS_URL="https://deb.nodesource.com/setup_$NODEJS_VERSION"

## Docker
ENV DOCKER_URL="https://download.docker.com/linux/ubuntu"
ENV DOCKER_GPG_KEY_URL="$DOCKER_URL/gpg"

## Kubernetes
ENV KUBERNETES_VERSION="v1.30"
ENV KUBERNETES_URL="https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" \
    KUBERNETES_GPG_KEY_URL="https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key"

## RCLONE
ENV RCLONE_VERSION="v1.66.0"
ENV RCLONE_URL="https://downloads.rclone.org/$RCLONE_VERSION/rclone-$RCLONE_VERSION-linux-amd64.zip" \
    RCLONE_FILE="rclone-$RCLONE_VERSION-linux-amd64"
# --------------------------------------------INSTALL BASE PACKAGES-----------------------------------------------------
RUN apt update &&  apt install -y \
    # Useful utilities \
    ca-certificates curl unzip gnupg
#    xxd make wget socat man-db rsync moreutils vim lsof  \
#    bzip2 libassuan-dev libgcrypt20-dev libgpg-error-dev libksba-dev libnpth0-dev \
#    # Setup Java \
#    openjdk-17-jdk-headless \
#    # Setup Ruby \
#    ruby-full \
#    # Python 3 \
#    python3-matplotlib python3-numpy python3-pip python3-scipy python3-pandas python3-dev pipenv
#
## ------------------------------------------DOWNLOAD AND INSTALL GRADLE-------------------------------------------------
#RUN mkdir -p "$GRADLE_ROOT" &&  \
#    cd "$GRADLE_ROOT" && \
#    curl -fsSL "$GRADLE_URL" -o "$GRADLE_FILE.zip" && \
#    unzip "$GRADLE_FILE.zip" && \
#    rm "$GRADLE_FILE.zip"
#
## ----------------------------------------------DOWNLOAD ANDROID SDK----------------------------------------------------
#RUN mkdir -p "$ANDROID_SDK_ROOT" .android "$ANDROID_SDK_ROOT/cmdline-tools" && \
#    cd "$ANDROID_SDK_ROOT/cmdline-tools" && \
#    curl -fsSL "$TOOLS_URL" -o "$ANDROID_SDK_FILE"  && \
#    unzip "$ANDROID_SDK_FILE" && \
#    rm "$ANDROID_SDK_FILE" && \
#    mv cmdline-tools tools && \
#    yes | $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager --licenses
#
## -------------------------------------------INSTALL ANDROID BUILD TOOLS------------------------------------------------
#RUN $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager --update
#RUN $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION" \
#"platforms;android-$ANDROID_SDK_VERSION" \
#"platform-tools"
#
## --------------------------------------------------NODEJS, NPM, YARN---------------------------------------------------
#RUN set -ex -o pipefail &&  \
#    curl -fsSL "$NODEJS_URL" | bash - && \
#    curl -fsSL "$YARN_GPG_KEY_URL" | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null && \
#    echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] $YARN_URL" | tee /etc/apt/sources.list.d/yarn.list && \
#    apt update && apt install -y nodejs yarn

# -----------------------------------------------------CLOUD TOOLS------------------------------------------------------
RUN set -ex -o pipefail && \
    # Docker \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL "$DOCKER_GPG_KEY_URL" -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] $DOCKER_URL \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt update && \
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
    docker --version && \
    # Docker compose \
    apt update && \
    apt install -y docker-compose-plugin && \
    docker compose version && \
    # Kubernetes \
    curl -fsSL "$KUBERNETES_GPG_KEY_URL" | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] $KUBERNETES_URL" | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt update && apt install -y kubectl && \
    kubectl version --client && \
    # RClone \
    cd /usr/local && \
    curl -fsSL "$RCLONE_URL" -o "$RCLONE_FILE.zip" && \
    unzip "$RCLONE_FILE.zip" && \
    rm "$RCLONE_FILE.zip" && \
    cp "$RCLONE_FILE/rclone" /usr/bin/ && \
    chown root:root /usr/bin/rclone && \
    chmod 755 /usr/bin/rclone && \
    rclone --version

# -------------------------------------------------------SUMMARY--------------------------------------------------------
#RUN echo "############################### Versions #####################################" && \
#    make --version && \
#    echo "" && \
#    java -version &&  \
#    echo "" && \
#    gradle --version && \
#    echo "" && \
#    ruby --version && \
#    python3 --version &&  \
#    python2 --version &&  \
#    pip3 --version && \
#    echo "" && \
#    echo "Nodejs: $(node --version)" &&  \
#    echo "Npm: $(npm --version)" &&  \
#    echo "Yarn: $(yarn --version)" && \
#    echo "" && \
#    docker --version &&  \
#    docker-compose --version && \
#    echo "" && \
#    echo "Kubectl: $(kubectl version --client)" && \
#    echo "" && \
#    rclone --version && \
#    echo "############################### Versions #####################################"
