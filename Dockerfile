FROM ubuntu:24.04 as base

MAINTAINER Aziz Atoev <a.atoev93@gmail.com>

USER root

RUN echo "$(java --version)"

# --------------------------------------------ENVIRONMENT VARIABLES-----------------------------------------------------
# GRADLE
ENV GRADLE_VERSION=8.7 \
GRADLE_URL="https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip" \
GRADLE_ROOT="/usr/local" \
GRADLE_FILE="gradle-$GRADLE_VERSION" \
PATH="$GRADLE_ROOT/$GRADLE_FILE/bin:$PATH"

# ANDROID
ENV TOOLS_VERSION="11076708" \
TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-$TOOLS_VERSION_latest.zip" \
ANDROID_SDK_ROOT="/usr/local/android-sdk" \
ANDROID_SDK=33 \
ANDROID_BUILD_TOOLS=33.0.1 \
PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/cmdline-tools/tools/bin:$PATH"

# --------------------------------------------INSTALL BASE PACKAGES-----------------------------------------------------
RUN apt update && \
    apt -y install curl build-essential bzip2 libassuan-dev libgcrypt20-dev libgpg-error-dev libksba-dev libnpth0-dev openjdk-17-jdk openjdk-17-jdk xxd gnupg
RUN echo "BASE PACKAGES INSTALLED"

# ------------------------------------------DOWNLOAD AND INSTALL GRADLE-------------------------------------------------
RUN cd "$GRADLE_ROOT" && \
    curl -o "$GRADLE_FILE.zip"  $GRADLE_URL && \
    unzip "$GRADLE_FILE.zip" && \
    rm "$GRADLE_FILE.zip"
RUN echo "GRADLE $GRADLE_VERSION INSTALLED"

# ----------------------------------------------DOWNLOAD ANDROID SDK----------------------------------------------------
RUN mkdir "$ANDROID_SDK_ROOT" .android "$ANDROID_SDK_ROOT/cmdline-tools" && \
    cd "$ANDROID_SDK_ROOT/cmdline-tools" && \
    curl -o sdk.zip $TOOLS_URL && \
    unzip sdk.zip && \
    rm sdk.zip && \
    mv cmdline-tools tools && \
    yes | $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager --licenses
RUN echo "ANDROID SDK $ANDROID_SDK INSTALLED"

# -------------------------------------------INSTALL ANDROID BUILD TOOLS------------------------------------------------
RUN $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager --update
RUN $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager "build-tools;$ANDROID_BUILD_TOOLS" \
"platforms;android-$ANDROID_SDK" \
"platform-tools"
RUN echo "ANDROID SDK $ANDROID_BUILD_TOOLS INSTALLED"
