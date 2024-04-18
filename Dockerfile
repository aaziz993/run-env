FROM gradle:8.7.0-jdk17-jammy

MAINTAINER Aziz Atoev <a.atoev93@gmail.com>

ENV SDK_HOME /usr/local

RUN apt-get --quiet update --yes
RUN apt-get --quiet install --yes wget tar unzip lib32stdc++6 lib32z1
RUN apt-get --quiet install --yes libqt5widgets5 usbutils

# Install Git and dependencies
RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y file git curl zip libncurses5:i386 libstdc++6:i386 zlib1g:i386 jq \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists /var/cache/apt

# Gradle
ENV GRADLE_VERSION 8.5
ENV GRADLE_SDK_URL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
RUN curl -sSL "${GRADLE_SDK_URL}" -o gradle-${GRADLE_VERSION}-bin.zip  \
	&& unzip gradle-${GRADLE_VERSION}-bin.zip -d ${SDK_HOME}  \
	&& rm -rf gradle-${GRADLE_VERSION}-bin.zip
ENV GRADLE_HOME ${SDK_HOME}/gradle-${GRADLE_VERSION}
ENV PATH ${GRADLE_HOME}/bin:$PATH

# android sdk|build-tools|image
ENV ANDROID_TARGET_SDK="android-34" \
    ANDROID_BUILD_TOOLS="34.0.0" \
    ANDROID_SDK_TOOLS="11076708"
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip
RUN curl -sSL "${ANDROID_SDK_URL}" -o android-sdk-linux.zip \
    && unzip android-sdk-linux.zip -d android-sdk-linux \
  && rm -rf android-sdk-linux.zip

# Set ANDROID_HOME
ENV ANDROID_HOME $PWD/android-sdk-linux
ENV PATH ${ANDROID_HOME}/bin:$PATH

# Update and install using sdkmanager
RUN echo yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --licenses
RUN echo yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --update
RUN echo yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "tools" "platform-tools" "emulator"
RUN echo yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "build-tools;${ANDROID_BUILD_TOOLS}"
RUN echo yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "platforms;${ANDROID_TARGET_SDK}"
RUN echo yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "extras;android;m2repository" "extras;google;google_play_services" "extras;google;m2repository"
RUN echo yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"
RUN echo yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2"

# Install xxd
RUN apt-get update && \
    apt-get install xxd

ENV PATH ${SDK_HOME}/bin:$PATH