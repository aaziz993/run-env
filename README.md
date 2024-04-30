# What is default base image?

1. In Dockerfile: Ubuntu latest LTS version. Ubuntu latest LTS for the moment is not supported by terraform.
   See [Dockerfile](Dockerfile).
2. In Github Actions: Ubuntu Jammy. See [publish.yaml](.github/workflows/publish.yml).
3. In Jetbrains Space Automation: Ubuntu Jammy. See [.space.kts](.space.kts).

### Ubuntu latest LTS is not supported by terraform.

## What are installed?

1. Make
2. JDK 17
3. Gradle 8.7
4. AndroidSDK 33
5. Android build tools 33.0.1
6. Ruby
7. Python3
8. Pip3
9. NodeJS
10. Npm
11. Yarn
12. Docker
13. Docker Compose
14. Kubernetes (k8s)
15. Rclone
16. Terraform
17. Terraspace

## How to provide configurations

1. By environment variables. See [Dockerfile](Dockerfile) and [build.gradle.kts](build.gradle.kts).
2. By [gradle.properties](gradle.properties).

## How do I publish it manually?

1. Install docker
2. Run ```make publish-dockerhub```

## How do I publish it with CI/CD?

1. In Github Actions nothing to do.
2. In <b>Jetbrains Space Automation</b> create connection with key ```dockerhub_connection``` in Project -> Settings -> Docker
   Registry Connections. See [.space.kts](.space.kts) publish script.
