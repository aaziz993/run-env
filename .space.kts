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
    startOn {
        gitPush { enabled = true }
    }

    parameters {
        text("image.version", "1.0.0")
        text("space.repository", "aaziz93.registry.jetbrains.space/p/aaziz-93/containers")
        text("dockerhub.username", "aaziz93")
    }

    container("Spotless code format check", "gradle") {
        kotlinScript { api ->
            api.parameters["git.repository.name"] = api.gitRepositoryName()
            api.parameters["vendor"] = api.projectId()
            api.gradlew("spotlessCheck", "--no-configuration-cache")
        }
    }

    container("Sonar continuous inspection of code quality and security", "gradle") {
        env["SONAR_TOKEN"] = "{{ project:sonar.token }}"
        kotlinScript { api ->
            api.gradlew("sonar", "--no-configuration-cache")
        }
    }

    parallel {
        host("Publish to Space Packages") {

            dockerBuildPush {
                context = "."
                file = "./Dockerfile"
                // image labels
                labels["vendor"] = "{{ vendor }}"

                val spaceRepository = "{{ space.repository }}/{{ git.repository.name }}"
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
                labels["vendor"] = "{{ vendor }}"

                val dockerHubRepository = "{{ dockerhub.username }}/{{ git.repository.name }}"
                tags {
                    +"$dockerHubRepository:{{ image.version }}.${"$"}JB_SPACE_EXECUTION_NUMBER"
                    +"$dockerHubRepository:latest"
                }
            }
        }
    }
}
