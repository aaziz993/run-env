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

// Top-level build file where you can add configuration options common to all subprojects/modules.
@Suppress("DSL_SCOPE_VIOLATION")
plugins {
    alias(libs.plugins.spotless)
    alias(libs.plugins.sonarqube)
}

spotless {
    val excludeSourceFileTargets = listOf(
        "${layout.buildDirectory}/**/*",
        "/idea/**/*",
        "/fleet/**/*",
        ".gradle/**/*",
    )

    format("kts") {
        target("**/*.kts")
        // Exclude files in the gitignore directories
        targetExclude(*(excludeSourceFileTargets.map { "$it.kts" } + "spotless/copyright.kts").toTypedArray())
        // Look for the first line that doesn't have a block comment (assumed to be the license)
        licenseHeaderFile(providers.gradleProperty("spotless.kts.license.header.file"), "(^(?![\\/ ]\\*).*$)")
    }

    // Additional configuration for Kotlin Gradle scripts
    kotlinGradle {
        target("*.gradle.kts")
        // Apply ktlint to Gradle Kotlin scripts
        ktlint("1.2.1")
    }

    format("misc") {
        target("**/*.md", "**/.gitignore")
        // Exclude files in the gitignore directories
        targetExclude(
            *(
                excludeSourceFileTargets.map {
                    "$it.md"
                } + excludeSourceFileTargets.map { "$it.gitignore" }
                ).toTypedArray(),
        )
        indentWithSpaces()
        trimTrailingWhitespace()
        endWithNewline()
    }
}

// Project code analysis
// To analyze a project hierarchy, apply the SonarQube plugin to the root project of the hierarchy.
// Typically (but not necessarily) this will be the root project of the Gradle build.
// Information pertaining to the analysis as a whole has to be configured in the sonar block of this project.
// Any properties set on the command line also apply to this project.
sonarqube {
    properties {
        property("sonar.host.url", providers.gradleProperty("sonar.host.url").get())
        property("sonar.organization", providers.gradleProperty("sonar.organization").get())
        property(
            "sonar.projectKey",
            "${providers.gradleProperty("sonar.organization").get()}_$name",
        )
    }
}
