FROM gradle:8.7.0-jdk17

MAINTAINER Aziz Atoev <a.atoev93@gmail.com>

USER root
ENV TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" \
ANDROID_SDK_ROOT="/usr/local/android-sdk" \
ANDROID_SDK=33 \
ANDROID_BUILD_TOOLS=33.0.1 \
PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin:${PATH}"

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
RUN $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}" \
"platforms;android-${ANDROID_SDK}" \
"platform-tools"

# Install common
RUN apt-get update && \
    apt-get install build-essential bzip2 libassuan-dev libgcrypt20-dev libgpg-error-dev libksba-dev libnpth0-dev

# Install xxd
RUN apt-get update && \
    apt-get install xxd

# Install gnupg2
RUN apt-get update && \
    apt-get install gnupg2