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

job("Code format check, analysis and publish") {
    // Users will be able to redefine these parameters in custom job run.
    // See the 'Customize job run' section
    parameters {
        text("env.os", value = "gradle")
        text("gradlew.option", value = "--no-configuration-cache")
        text("image.version", "1.0.0")
        text("space.repository", "aaziz93.registry.jetbrains.space/p/aaziz-93/containers")

    }

    startOn {
        gitPush { enabled = true }
    }

    container("Spotless code format check", "{{ env.os }}") {
        kotlinScript { api ->
            api.gradlew("spotlessCheck", "{{ gradlew.option }}")
        }
    }

    container("Sonar continuous inspection of code quality and security", "{{ env.os }}") {
        env["SONAR_TOKEN"] = "{{ project:sonar.token }}"
        kotlinScript { api ->
            api.gradlew("sonar", "{{ gradlew.option }}")
        }
    }

    parallel {
        host("Publish to Space Packages") {

            dockerBuildPush {
                context = "."
                file = "./Dockerfile"
                // image labels
                labels["vendor"] = "{{ run:project.key }}"

                val spaceRepository = "{{ space.repository }}/{{ run:trigger.git-push.repository }}"
                // image tags
                tags {
                    // use current job run number as a tag - '0.0.run_number'
                    +"$spaceRepository:{{ image.version }}.${"$"}JB_SPACE_EXECUTION_NUMBER"
                    +"$spaceRepository:latest"
                }
            }
        }

        host("Publish to DockerHub") {
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
                labels["vendor"] = "{{ run:project.key }}"

                val dockerHubRepository = "{{ project:dockerhub.username }}/{{ run:trigger.git-push.repository }}"
                tags {
                    +"$dockerHubRepository:{{ image.version }}.${"$"}JB_SPACE_EXECUTION_NUMBER"
                    +"$dockerHubRepository:latest"
                }
            }
        }
    }
}
