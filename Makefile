chmod-gradlew:
	git update-index --chmod=+x gradlew

format:
	gradlew spotlessApply --no-configuration-cache

format-check:
	gradlew spotlessCheck --no-configuration-cache
