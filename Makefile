.PHONY: chmod-gradlew format format-check quality-check cl

chmod-gradlew: # Give permission to execute gradlew
	git update-index --chmod=+x gradlew

format: # Format code with spotless
	chmod 777 -R scripts/ && ./scripts/format.sh

format-check: # Check code format with spotless
	chmod 777 -R scripts/ && ./scripts/format.sh

quality-check: # Check code quality with sonar
	chmod 777 -R scripts/ && ./scripts/quality-check.sh

clean: # Clean all
	chmod 777 -R scripts/ && ./scripts/clean.sh
