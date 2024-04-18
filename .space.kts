/**
 * JetBrains Space Automation
 * This Kotlin-script file lets you automate build activities
 * For more info, see https://www.jetbrains.com/help/space/automation.html
 */

job("Code analysis, test, build and publish") {
    startOn {
        gitPush { enabled = true }
    }

    parallel {
//        host("Build and push a Docker image to Space Packages") {
//            dockerBuildPush {
//                // image labels
//                labels["vendor"] = "aaziz993.github.io"
//
//                val spaceRepository = "aaziz93.registry.jetbrains.space/p/aaziz-93/containers/cicd-os"
//                // image tags
//                tags {
//                    // use current job run number as a tag - '0.0.run_number'
//                    +"$spaceRepository:1.0.${"$"}JB_SPACE_EXECUTION_NUMBER"
//                    +"$spaceRepository:latest"
//                }
//            }
//        }

        host("Build and push a Docker image to DockerHub") {
            // Before running the scripts, the host machine will log in to
            // the registries specified in connections.
            dockerRegistryConnections {
                // specify connection key
                +"docker_hub"
                // multiple connections are supported
                // +"one_more_connection"
            }

            dockerBuildPush {
                labels["vendor"] = "aaziz93"

                val dockerHubRepository = "cicd-os"
                tags {
                    +"aaziz93/$dockerHubRepository:1.0.${"$"}JB_SPACE_EXECUTION_NUMBER"
                    +"$dockerHubRepository:1.0.${"$"}JB_SPACE_EXECUTION_NUMBER"
                    +"aaziz93/$dockerHubRepository:latest"
                    +"$dockerHubRepository:latest"
                }
            }
        }
    }
}