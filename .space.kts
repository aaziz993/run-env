/**
 * JetBrains Space Automation
 * This Kotlin-script file lets you automate build activities
 * For more info, see https://www.jetbrains.com/help/space/automation.html
 */

job("Code analysis, test, build and publish") {
    startOn {
        gitPush { enabled = true }
    }

//    container("Sonarqube continuous inspection of code quality and security", "amazoncorretto:17-alpine") {
//        env["SONAR_TOKEN"] = "{{ project:sonar_token }}"
//        kotlinScript { api ->
//            api.gradlew("sonarqube")
//        }
//    }

    host("Build artifacts and a Docker image") {
        // Before running the scripts, the host machine will log in to
        // the registries specified in connections.
        dockerRegistryConnections {
            // specify connection key
            +"docker_hub"
            // multiple connections are supported
            // +"one_more_connection"
        }

        dockerBuildPush {
            labels["vendor"] = "mycompany"
            tags {
                +"aaziz993.github.io/cicd-os:1.0.${"$"}JB_SPACE_EXECUTION_NUMBER"
            }
        }
    }
}