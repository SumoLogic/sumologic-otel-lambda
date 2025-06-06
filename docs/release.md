# Releasing guide

Perform the following steps in order to release new versions:

1. Prepare and merge PR with following changes:

    - update [changelog](../CHANGELOG.md)
    - in [README.md](../README.md) update version of the latest lambda layers
    - update `<language>/layer-data.sh`
    - update `<language>/sample-apps/template.yaml`

1. Create and push new tag:

    Pushing new tag will trigger job which will create a pre-release draft.

    ```bash
    export LANGUAGE= # Possible values: java, nodejs, or python
    export TAG=${LANGUAGE}-vx.y.z
    git checkout main
    git pull
    git tag -sm "${TAG}" "${TAG}"
    git push origin "${TAG}"
    ```

1. Prepare release branch

    - branch out:

     ```bash
     git checkout -b "release-${TAG}"
     ```

    - in specific language README.md (e.g. python/README.md)
        - set a version as `x.y.z` (`unreleased version` in title)
        - update Layer ARNs tables (look at pre-release draft)
        - update Container Layer links with dependencies (look at pre-release draft)
    - in [README.md](../README.md) update version of the latest lambda layers
    - push branch:

     ```bash
     git push -u origin "release-${TAG}"
     ```

1. Create [new release][releases] based on generated pre-release draft.

[releases]: https://github.com/SumoLogic/sumologic-otel-lambda/releases
