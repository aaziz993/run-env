FROM ubuntu:24.04 as base

MAINTAINER Aziz Atoev <a.atoev93@gmail.com>

USER root

# --------------------------------------------ENVIRONMENT VARIABLES-----------------------------------------------------
# GRADLE
ENV GRADLE_VERSION=8.7 \
GRADLE_URL="https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip" \
GRADLE_ROOT="/opt/gradle" \
GRADLE_FILE="gradle-$GRADLE_VERSION" \
PATH="$GRADLE_ROOT/$GRADLE_FILE/bin:$PATH"

# ANDROID
ENV TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" \
ANDROID_SDK_ROOT="/usr/local/android-sdk" \
ANDROID_SDK_VERSION=33 \
ANDROID_BUILD_TOOLS_VERSION=33.0.1 \
ANDROID_SDK_FILE="android-sdk-$ANDROID_SDK_VERSION.zip" \
PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/cmdline-tools/tools/bin:$PATH"

# --------------------------------------------INSTALL BASE PACKAGES-----------------------------------------------------
RUN apt update && \
    apt -y install curl build-essential bzip2 libassuan-dev libgcrypt20-dev libgpg-error-dev libksba-dev libnpth0-dev openjdk-17-jdk openjdk-17-jdk xxd gnupg
RUN echo "BASE PACKAGES INSTALLED"

# ------------------------------------------DOWNLOAD AND INSTALL GRADLE-------------------------------------------------
RUN mkdir "$GRADLE_ROOT" &&  \
    cd "$GRADLE_ROOT" && \
    curl -o "$GRADLE_FILE.zip" "$GRADLE_URL" && \
    unzip "$GRADLE_FILE.zip" && \
    rm "$GRADLE_FILE.zip"
RUN echo "GRADLE $GRADLE_VERSION INSTALLED"

# ----------------------------------------------DOWNLOAD ANDROID SDK----------------------------------------------------
RUN mkdir "$ANDROID_SDK_ROOT" .android "$ANDROID_SDK_ROOT/cmdline-tools" && \
    cd "$ANDROID_SDK_ROOT/cmdline-tools" && \
    curl -o "$ANDROID_SDK_FILE" "$TOOLS_URL" && \
    unzip "$ANDROID_SDK_FILE" && \
    rm "$ANDROID_SDK_FILE" && \
    mv cmdline-tools tools && \
    yes | $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager --licenses
RUN echo "ANDROID SDK $ANDROID_SDK_VERSION INSTALLED"

# -------------------------------------------INSTALL ANDROID BUILD TOOLS------------------------------------------------
RUN $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager --update
RUN $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION" \
"platforms;android-$ANDROID_SDK_VERSION" \
"platform-tools"
RUN echo "ANDROID SDK $ANDROID_BUILD_TOOLS_VERSION INSTALLED"
