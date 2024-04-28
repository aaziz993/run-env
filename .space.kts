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

    // To get a parameter in a job, specify its name in a string inside double curly braces: "{{ my-param }}".
    // You can do this in any string inside any DSL block excluding startOn, git, and kotlinScript.
    // Users will be able to redefine these parameters in custom job run.
    // See the 'Customize job run' section
    parameters {
        text("branch", "{{ run:trigger.git-push.ref }}")
        text("env.os", "gradle")
        text("image.name", "{{ run:trigger.git-push.repository }}")
        text("image.version", "1.0.0.${"$"}JB_SPACE_EXECUTION_NUMBER")
        text("vendor", "{{ run:project.key }}")
        text("space.repository", "aaziz93.registry.jetbrains.space/p/aaziz-93/containers")
    }

    container("Spotless code format check", "{{ env.os }}") {
        shellScript {
            content = """
                add-apt-repository ppa:chris-lea/munin-plugins
                apt update
                apt install -y make
                make format-check
            """.trimIndent()
        }
    }

    container("Sonar continuous inspection of code quality and security", "{{ env.os }}") {
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
            env["BASE_IMAGE"] = "ubuntu:mantic"
            dockerBuildPush {
                context = "."
                file = "./Dockerfile"
                // image labels
                labels["vendor"] = "{{ vendor }}"

                val spaceRepository = "{{ space.repository }}/{{ image.name }}"
                // image tags
                tags {
                    // use current job run number as a tag - '0.0.run_number'
                    +"$spaceRepository:{{ image.version }}"
                    +"$spaceRepository:latest"
                }
            }
        }

        host("Publish to DockerHub") {
            env["BASE_IMAGE"] = "ubuntu:mantic"
            // Before running the scripts, the host machine will log in to
            // the registries specified in connections.
            dockerRegistryConnections {
                // specify connection key
                +"docker_hub"
                // multiple connections are supported
                // +"one_more_connection"
            }

            dockerBuildPush {
                context = "."
                file = "./Dockerfile"
                labels["vendor"] = "{{ vendor }}"

                val dockerHubRepository = "{{ project:dockerhub.username }}/{{ image.name }}"
                tags {
                    +"$dockerHubRepository:{{ image.version }}"
                    +"$dockerHubRepository:latest"
                }
            }
        }
    }
}
