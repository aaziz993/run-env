FROM ubuntu:24.04

MAINTAINER Aziz Atoev <a.atoev93@gmail.com>

USER root

# Support various rvm, nvm etc stuff which requires executing profile scripts (-l)
SHELL ["/bin/bash", "-lc"]
CMD ["/bin/bash", "-l"]

# --------------------------------------------ENVIRONMENT VARIABLES-----------------------------------------------------
# GRADLE
ENV GRADLE_VERSION=8.7 \
    GRADLE_ROOT="/usr/local/gradle" \
    PATH="$GRADLE_ROOT/$GRADLE_FILE/bin:$PATH"
ENV GRADLE_URL="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    GRADLE_FILE="gradle-$GRADLE_VERSION"

# ANDROID
ENV TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" \
    ANDROID_SDK_ROOT="/usr/local/android-sdk" \
    ANDROID_SDK_VERSION=33 \
    ANDROID_BUILD_TOOLS_VERSION=33.0.1 \
    PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/cmdline-tools/tools/bin:$PATH"
ENV ANDROID_SDK_FILE="android-sdk-$ANDROID_SDK_VERSION.zip"

# NODEJS
ENV NODEJS_VERSION="20.x" \
    YARN_URL="https://dl.yarnpkg.com/debian"
ENV NODEJS_URL="https://deb.nodesource.com/setup_$NODEJS_VERSION"

# --------------------------------------------INSTALL BASE PACKAGES-----------------------------------------------------
# Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && apt-get install -y apt-utils apt-transport-https software-properties-common

# Newest git
RUN apt-add-repository ppa:git-core/ppa -y && apt-get update

RUN apt -y install \
    # Useful utilities \
    curl unzip wget socat man-db rsync moreutils vim lsof xxd gnupg \
    bzip2 libassuan-dev libgcrypt20-dev libgpg-error-dev libksba-dev libnpth0-dev \
    # Setup Java \
    openjdk-17-jdk-headless \
    # Setup Ruby \
    # Python 3 \
    python3-matplotlib python3-numpy python3-pip python3-scipy python3-pandas python3-dev pipenv && \
    echo "BASE PACKAGES INSTALLED"

# ------------------------------------------DOWNLOAD AND INSTALL GRADLE-------------------------------------------------
RUN mkdir "$GRADLE_ROOT" &&  \
    cd "$GRADLE_ROOT" && \
    curl -o "$GRADLE_FILE.zip" "$GRADLE_URL" && \
    ls -l && \
#    unzip "$GRADLE_FILE.zip" && \
#    rm "$GRADLE_FILE.zip" && \
    echo "GRADLE $GRADLE_VERSION INSTALLED"

# ----------------------------------------------DOWNLOAD ANDROID SDK----------------------------------------------------
#RUN mkdir "$ANDROID_SDK_ROOT" .android "$ANDROID_SDK_ROOT/cmdline-tools" && \
#    cd "$ANDROID_SDK_ROOT/cmdline-tools" && \
#    curl -o "$ANDROID_SDK_FILE" "$TOOLS_URL" && \
#    unzip "$ANDROID_SDK_FILE" && \
#    rm "$ANDROID_SDK_FILE" && \
#    mv cmdline-tools tools && \
#    yes | $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager --licenses
#RUN echo "ANDROID SDK $ANDROID_SDK_VERSION INSTALLED"
#
## -------------------------------------------INSTALL ANDROID BUILD TOOLS------------------------------------------------
#RUN $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager --update
#RUN $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION" \
#"platforms;android-$ANDROID_SDK_VERSION" \
#"platform-tools"
#RUN echo "ANDROID SDK $ANDROID_BUILD_TOOLS_VERSION INSTALLED"

# --------------------------------------------------NODEJS, NPM, YARN---------------------------------------------------
#RUN set -ex -o pipefail &&  \
#    curl -fsSL "$NODEJS_URL" | bash - && \
#    curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null && \
#    echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] $YARN_URL stable main" | tee /etc/apt/sources.list.d/yarn.list && \
#    apt-get update && apt-get install -y nodejs yarn

## ------------------------------------------------------VERSIONS--------------------------------------------------------
#RUN echo "############################### Versions #####################################" && \
#    java -version &&  \
#    echo "" && \
#    gradle --version && \
#    echo "" && \
#    make --version && \
#    echo "############################### Versions #####################################"
