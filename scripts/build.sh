#!/bin/bash

. ./scripts/util.sh

gradle_properties_file="./gradle.properties"

export IMAGE_GRADLE_VERSION
export IMAGE_JDK_VERSION
export IMAGE_ANDROID_SDK_VERSION
export IMAGE_ANDROID_BUILD_TOOLS_TOOLS_REVISION
export IMAGE_ANDROID_BUILD_TOOLS_VERSION
export IMAGE_NODEJS_VERSION
export IMAGE_KUBERNETES_VERSION
export IMAGE_RCLON_VERSION

if [[ -n "$(property "$gradle_properties_file" "image.gradle.version")"  ]]; then
    IMAGE_GRADLE_VERSION="$(property "$gradle_properties_file" "image.gradle.version")"
fi
if [[ -n "$(property "$gradle_properties_file" "image.jdk.version")"  ]]; then
    IMAGE_JDK_VERSION="$(property "$gradle_properties_file" "image.jdk.version")"
fi
if [[ -n "$(property "$gradle_properties_file" "image_android.sdk.version")"  ]]; then
    IMAGE_ANDROID_SDK_VERSION="$(property "$gradle_properties_file" "image_android.sdk.version")"
fi
if [[ -n "$(property "$gradle_properties_file" "image_android_build_tools.tools.revision")"  ]]; then
    IMAGE_ANDROID_BUILD_TOOLS_TOOLS_REVISION="$(property "$gradle_properties_file" "image_android_build_tools.tools.revision")"
fi
if [[ -n "$(property "$gradle_properties_file" "image_android_build.tools.version")"  ]]; then
    IMAGE_ANDROID_BUILD_TOOLS_VERSION="$(property "$gradle_properties_file" "image_android_build.tools.version")"
fi
if [[ -n "$(property "$gradle_properties_file" "image.nodejs.version")"  ]]; then
    IMAGE_NODEJS_VERSION="$(property "$gradle_properties_file" "image.nodejs.version")"
fi
if [[ -n "$(property "$gradle_properties_file" "image.kubernetes.version")"  ]]; then
    IMAGE_KUBERNETES_VERSION="$(property "$gradle_properties_file" "image.kubernetes.version")"
fi
if [[ -n "$(property "$gradle_properties_file" "image.rclon.version")"  ]]; then
    IMAGE_RCLON_VERSION="$(property "$gradle_properties_file" "image.rclon.version")"
fi

./gradlew buildDockerImage --no-configuration-cache
