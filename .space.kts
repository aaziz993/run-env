import java.io.File
import java.util.*

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

job("Publish") {
    startOn {
        gitPush { enabled = true }
    }

    container("Spotless code format", "gradle") {
        kotlinScript { api ->
            api.gradlew("spotlessApply")
        }
    }

    container("Sonar continuous inspection of code quality and security", "gradle") {
        env["SONAR_TOKEN"] = "{{ project:sonar_token }}"
        kotlinScript { api ->
            api.gradlew("sonar")
        }
    }

    // Get project name from gradle.properties
    val projectName = File("gradle.properties").let { file ->
        Properties().apply {
            if (file.exists()) {
                load(file.reader())
            }
        }.getProperty("project.name").get()
    }

    parallel {
        host("Publish to Space Packages") {
            dockerBuildPush {
                context = "."
                file = "./Dockerfile"
                // image labels
                labels["vendor"] = "aaziz93"

                val spaceRepository = "aaziz93.registry.jetbrains.space/p/aaziz-93/containers/$projectName"
                // image tags
                tags {
                    // use current job run number as a tag - '0.0.run_number'
                    +"$spaceRepository:1.0.${"$"}JB_SPACE_EXECUTION_NUMBER"
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
                labels["vendor"] = "aaziz93"

                val dockerHubRepository = "aaziz93/$projectName"
                tags {
                    +"$dockerHubRepository:1.0.${"$"}JB_SPACE_EXECUTION_NUMBER"
                    +"$dockerHubRepository:latest"
                }
            }
        }
    }
}
