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


    container("Gradle test, build and publish to maven registry", "amazoncorretto:17-alpine") {
        kotlinScript { api ->
            api.gradlew("test", "publish")
        }
    }
}