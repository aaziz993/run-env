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
import com.bmuschko.gradle.docker.tasks.container.DockerCreateContainer
import com.bmuschko.gradle.docker.tasks.container.DockerStartContainer
import com.bmuschko.gradle.docker.tasks.container.DockerStopContainer
import com.bmuschko.gradle.docker.tasks.image.DockerBuildImage
import com.bmuschko.gradle.docker.tasks.image.DockerPushImage
import com.diffplug.spotless.LineEnding
import java.util.*
import org.gradle.internal.os.OperatingSystem

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
    alias(libs.plugins.docker.remote.api)
}

val os: OperatingSystem = OperatingSystem.current()

val localProperties = project.rootProject.file("local.properties").let { file ->
    Properties().apply {
        if (file.exists()) {
            load(file.reader())
        }
    }
}

val dockerhubUsername: String = if (System.getenv().containsKey("DOCKERHUB_USERNAME")) {
    System.getenv("DOCKERHUB_USERNAME")
}
else {
    providers.gradleProperty("dockerhub.username").get()
}

val versionSplit = providers.gradleProperty("project.version").get().split("-", limit = 2)
val versionSuffix = if (versionSplit.size > 1) "-${versionSplit[1]}" else ""

allprojects {
    group = providers.gradleProperty("project.group").get()
    version = versionSplit[0]
}

spotless {
    lineEndings = LineEnding.UNIX

    val excludeSourceFileTargets = listOf(
        "**/generated-src/**",
        "**/build/**",
        "**/build-*/**",
        "**/.idea/**",
        "**/.fleet/**",
        "**/.gradle/**",
        "/spotless/**",
        "**/resources/**",
        "**/buildSrc/**",
    )

    format("kts") {
        target("**/*.kts")
        // Exclude files in the gitignore directories
        targetExclude(*excludeSourceFileTargets.toTypedArray())
        // Adds the ability to have spotless ignore specific portions of a project. The usage looks like the following
        toggleOffOn()
        // Will remove any extra whitespace at the end of lines
        trimTrailingWhitespace()
        // Will add a newline character to the end of files content
        endWithNewline()
        // Specifies license header file
        licenseHeaderFile(providers.gradleProperty("spotless.kts.license.header.file"), "(^(?![\\/ ]\\*).*$)")
    }

    format("xml") {
        target("**/*.xml")
        // Exclude files in the gitignore directories
        targetExclude(*excludeSourceFileTargets.toTypedArray())
        // Adds the ability to have spotless ignore specific portions of a project. The usage looks like the following
        toggleOffOn()
        // Will remove any extra whitespace at the end of lines
        trimTrailingWhitespace()
        // Will add a newline character to the end of files content
        endWithNewline()
        // Specifies license header file
        licenseHeaderFile(providers.gradleProperty("spotless.xml.license.header.file"), "(<[^!?])")
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
        targetExclude(*excludeSourceFileTargets.flatMap { listOf("$it.md", "$it.gitignore") }.toTypedArray())
        // Adds the ability to have spotless ignore specific portions of a project. The usage looks like the following
        toggleOffOn()
        // Will remove any extra whitespace at the beginning of lines
        indentWithSpaces()
        // Will remove any extra whitespace at the end of lines
        trimTrailingWhitespace()
        // Will add a newline character to the end of files content
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
            "${providers.gradleProperty("sonar.organization").get()}_${rootProject.name}",
        )
    }
}

docker {
    url = if (System.getenv().containsKey("DOCKER_URL")) {
        System.getenv("DOCKER_URL")
    }
    else {
        providers.gradleProperty("docker.url").getOrElse(
            if (os.isWindows) {
                providers.gradleProperty("docker.windows.url")
                    .getOrElse("tcp://127.0.0.1:2375")
            }
            else {
                providers.gradleProperty("docker.unix.url").getOrElse(
                    "unix:///var/run/docker.sock",
                )
            },
        )
    }
    certPath.set(File(System.getProperty("user.home"), "/.docker"))
    registryCredentials {
        url = providers.gradleProperty("dockerhub.url")
        username = dockerhubUsername
        password = if (System.getenv().containsKey("DOCKERHUB_PASSWORD")) {
            System.getenv("DOCKERHUB_PASSWORD")
        }
        else {
            localProperties.getProperty("dockerhub.password")
        }
        email = providers.gradleProperty("dockerhub.email")
    }
}

tasks.create("copyDockerfile", Copy::class) {
    from("Dockerfile")
    into(layout.buildDirectory)
}

tasks.create("buildDockerImage", DockerBuildImage::class) {
    doNotTrackState("")
    inputDir = layout.buildDirectory
    buildArgs = mapOf(
        "BASE_IMAGE" to providers.gradleProperty("base.image").get(),
    )
    images.add("$dockerhubUsername/${rootProject.name}:$version$versionSuffix")
    images.add("$dockerhubUsername/${rootProject.name}:latest")
    if (System.getenv().containsKey("GITHUB_REF_NAME")) {
        // The GITHUB_REF_NAME provide the release name.
        images.add("$dockerhubUsername/${rootProject.name}:$version.${System.getenv("GITHUB_REF_NAME")}$versionSuffix")
    }
    if (System.getenv().containsKey("JB_SPACE_EXECUTION_NUMBER")) {
        images.add("$dockerhubUsername/${rootProject.name}:$version.${System.getenv("JB_SPACE_EXECUTION_NUMBER")}$versionSuffix")
    }
    dependsOn("copyDockerfile")
}

tasks.create("pushDockerImage", DockerPushImage::class) {
    dependsOn("buildDockerImage")
    images.add("$dockerhubUsername/${rootProject.name}")
}

val createDockerContainer by tasks.creating(DockerCreateContainer::class) {
    dependsOn("pushDockerImage")
    image = "$dockerhubUsername/${rootProject.name}"
    portSpecs.add(providers.gradleProperty("image.container.port"))
}

val startDockerContainer by tasks.creating(DockerStartContainer::class) {
    dependsOn("createDockerContainer")
    targetContainerId(createDockerContainer.containerId)
}

val stopDockerContainer by tasks.creating(DockerStopContainer::class) {
    targetContainerId(createDockerContainer.containerId)
}

tasks.create("functionalTestDockerContainer", Test::class) {
    dependsOn(startDockerContainer)
    finalizedBy(stopDockerContainer)
}
