.PHONY: chmod-gradlew format format-check quality-check build publish create start stop test clean

chmod-gradlew: # Give permission to execute gradlew
	git update-index --chmod=+x gradlew

format: # Format code with spotless
	chmod 777 -R scripts/ && ./scripts/format.sh

format-check: # Check code format with spotless
	chmod 777 -R scripts/ && ./scripts/format.sh

quality-check: # Check code quality with sonar
	chmod 777 -R scripts/ && ./scripts/quality-check.sh

build: # Build docker image
	chmod 777 -R scripts/ && ./scripts/build.sh

publish-dockerhub: # Publish docker image to DockerHub
	chmod 777 -R scripts/ && ./scripts/publish.sh

create: # Create docker image
	chmod 777 -R scripts/ && ./scripts/create.sh

start: # Start docker image
	chmod 777 -R scripts/ && ./scripts/start.sh

stop: # Stop docker image
	chmod 777 -R scripts/ && ./scripts/stop.sh

test: # Functional test docker image
	chmod 777 -R scripts/ && ./scripts/test.sh


cover-report: # Generate code coverage report
	chmod 777 -R scripts/ && ./scripts/test.sh

clean: # Clean all
	chmod 777 -R scripts/ && ./scripts/clean.sh
