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
import java.io.File
import java.util.*

job("Code format check, quality check and publish") {
    startOn {
        // Run on every commit...
        gitPush {
            enabled = true
            // Only to the main branch
            anyRefMatching {
                +"refs/heads/main"
            }
        }
    }

    container("Read gradle.properties", "gradle") {
        kotlinScript { api ->
            // Do not use workDir to get the path to the working directory in a shellScript or kotlinScript.
            // Instead, use the JB_SPACE_WORK_DIR_PATH environment variable.
            File("${System.getenv("JB_SPACE_WORK_DIR_PATH")}/gradle.properties").let { file ->
                Properties().apply {
                    if (file.exists()) {
                        load(file.reader())
                    }
                }.entries.forEach {
                    println("${it.key}=${it.value}")
                    api.parameters[it.key.toString()] = it.value.toString()
                }
            }

            val imageVersion = api.parameters["image.version"]!!
            val imageVersionSnapshotSuffix = api.parameters["image.version.snapshot.suffix"]!!

            // Define image.tag depend on jetbrains.space.automation.versioning.run.number is true or false
            // by adding JB_SPACE_EXECUTION_NUMBER
            val imageVersionSuffix = if (api.parameters["jetbrains.space.automation.versioning.run.number"].toBoolean()) {
                ".${api.executionNumber()}"
            }
            else {
                ""
            }

            // Define jetbrains.space.packages.url depend on snapshot suffix in image.tag
            api.parameters["image.tag"] = if (imageVersion.endsWith(imageVersionSnapshotSuffix)) {
                api.parameters["jetbrains.space.packages.url"] = api.parameters["jetbrains.space.packages.snapshots.url"]!!
                "${imageVersion.removeSuffix(imageVersionSnapshotSuffix)}$imageVersionSuffix$imageVersionSnapshotSuffix"
            }
            else {
                api.parameters["jetbrains.space.packages.url"] = api.parameters["jetbrains.space.packages.releases.url"]!!
                "$imageVersion$imageVersionSuffix"
            }
        }
    }

    container("Spotless code format check", "gradle") {
        shellScript {
            content = """
                add-apt-repository ppa:chris-lea/munin-plugins
                apt update
                apt install -y make
                make format-check
            """.trimIndent()
        }
    }

    container("Sonar continuous inspection of code quality and security", "gradle") {
        env["SONAR_TOKEN"] = "{{ project:sonar.token }}"
        shellScript {
            content = """
                add-apt-repository ppa:chris-lea/munin-plugins
                apt update
                apt install -y make
                make quality-check
            """.trimIndent()
        }
    }

    parallel {
        host("Publish to Space Packages") {
            dockerBuildPush {
                val spacePackage = "{{ jetbrains.space.packages.url }}/{{ image.name }}"

                // Working directory
                context = "."

                // Docker file path
                file = "./Dockerfile"

                // Arguments passed to Dockerfile
                args["BASE_IMAGE"] = "{{ image.base.image }}"
                args["DEVELOPER_NAME"] = "{{ developer.name }}"
                args["DEVELOPER_EMAIL"] = "{{ developer.email }}"

                // Image labels
                labels["vendor"] = "{{ developer.name }}"

                // Image tags
                tags {
                    +"$spacePackage:{{ image.tag }}"
                    +"$spacePackage:latest"
                }
            }
        }

        host("Publish to DockerHub") {
            // Before running the scripts, the host machine will log in to
            // the registries specified in connections.
            dockerRegistryConnections {
                // specify connection key
                +"dockerhub_connection"
                // multiple connections are supported
                // +"one_more_connection"
            }

            dockerBuildPush {
                val dockerHubRepository = "{{ dockerhub.username }}/{{ image.name }}"

                // Working directory
                context = "."

                // Docker file path
                file = "./Dockerfile"

                // Arguments passed to Dockerfile
                args["BASE_IMAGE"] = "{{ image.base.image }}"
                args["DEVELOPER_NAME"] = "{{ developer.name }}"
                args["DEVELOPER_EMAIL"] = "{{ developer.email }}"

                // Image labels
                labels["vendor"] = "{{ developer.name }}"

                // Image tags
                tags {
                    +"$dockerHubRepository:{{ image.tag }}"
                    +"$dockerHubRepository:latest"
                }
            }
        }
    }
}
