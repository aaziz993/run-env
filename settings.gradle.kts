/*
 * Copyright 2024 Aziz Atoev
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
@file:Suppress("UnstableApiUsage")

enableFeaturePreview("TYPESAFE_PROJECT_ACCESSORS")

pluginManagement {
    repositories {
        mavenCentral()
        google()
        gradlePluginPortal()
        maven("https://maven.pkg.jetbrains.space/public/p/amper/amper")
        maven("https://www.jetbrains.com/intellij-repository/releases")
        maven("https://packages.jetbrains.team/maven/p/ij/intellij-dependencies")
    }
}

dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        // Space Packages releases
        maven { url = uri("https://maven.pkg.jetbrains.space/aaziz93/p/aaziz-93/releases") }
        // Space Packages snapshots
        maven { url = uri("https://maven.pkg.jetbrains.space/aaziz93/p/aaziz-93/snapshots") }
        // Github Packages
        maven { url = uri("https://maven.pkg.github.com/aaziz993") }
    }
}

plugins {
    id("org.jetbrains.amper.settings.plugin").version("0.2.3-dev-473")
}

rootProject.name = providers.gradleProperty("image.name").get()
