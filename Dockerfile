FROM ubuntu:24.04 as base

MAINTAINER Aziz Atoev <a.atoev93@gmail.com>

USER root

# Install base packages
RUN apt update && \
    apt -y openjdk-17-jdk  \
    install build-essential bzip2 libassuan-dev libgcrypt20-dev libgpg-error-dev libksba-dev libnpth0-dev \
    xxd \
    gnupg

# Download and install Gradle
ENV GRADLE_VERSION=8.7 \
GRADLE_URL="https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip" \
GRADLE_ROOT="/usr/local" \
GRADLE_FILE="gradle-$GRADLE_VERSION"
RUN \
    cd "$GRADLE_ROOT" && \
    curl -o "$GRADLE_FILE.zip"  $GRADLE_URL && \
    unzip "$GRADLE_FILE.zip" && \
    rm "$GRADLE_FILE.zip" \
PATH="$GRADLE_ROOT/$GRADLE_FILE/bin:$PATH"

ENV TOOLS_VERSION="11076708" \
TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-$TOOLS_VERSION_latest.zip" \
ANDROID_SDK_ROOT="/usr/local/android-sdk" \
ANDROID_SDK=33 \
ANDROID_BUILD_TOOLS=33.0.1 \
PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/cmdline-tools/tools/bin:$PATH"

# Download Android SDK
RUN mkdir "$ANDROID_SDK_ROOT" .android "$ANDROID_SDK_ROOT/cmdline-tools" && \
    cd "$ANDROID_SDK_ROOT/cmdline-tools" && \
    curl -o sdk.zip $TOOLS_URL && \
    unzip sdk.zip && \
    rm sdk.zip && \
    mv cmdline-tools tools && \
    yes | $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager --licenses

# Install Android Build Tools
RUN $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager --update
RUN $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager "build-tools;$ANDROID_BUILD_TOOLS" \
"platforms;android-$ANDROID_SDK" \
"platform-tools"
