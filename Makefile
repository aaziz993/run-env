.PHONY: chmod-gradlew format format-check quality-check cl

chmod-gradlew:
	git update-index --chmod=+x gradlew

format:
	gradlew spotlessApply --no-configuration-cache

format-check:
	gradlew spotlessCheck --no-configuration-cache

quality-check:
	gradlew sonar --no-configuration-cache

clean:
	gradlew clean
