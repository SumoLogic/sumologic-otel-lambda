# Changelog

All notable changes to this project will be documented in this file.

## [nodejs-v2.0.0]

### Released 2025-09-02

### Changed

- feat: upgrade to OpenTelemetry JavaScript SDK 2.0.0 [#50]
- feat: update nodejs lambda layer compatible runtimes to 18.x, 20.x, 22.x (removed 16.x) [#50]
- feat: improve type safety and error handling in wrapper initialization [#50]
- chore: update all OpenTelemetry dependencies to latest stable versions [#50]

[#50]: https://github.com/SumoLogic/sumologic-otel-lambda/pull/50
[nodejs-v2.0.0]: https://github.com/SumoLogic/sumologic-otel-lambda/releases/tag/nodejs-v2.0.0

## [java-v2.15.0]

### Released 2025-06-09

### Changed

- Update collector and instrumentation to latest upstream version

[java-v2.15.0]: https://github.com/SumoLogic/sumologic-otel-lambda/releases/tag/java-v2.15.0

## [python-v1.32.0]

### Released 2025-06-06

### Changed

- Update collector and instrumentation to latest upstream version

[python-v1.32.0]: https://github.com/SumoLogic/sumologic-otel-lambda/releases/tag/python-v1.32.0

## [nodejs-v1.17.2]

### Released 2024-07-24

### Changed

- refactor(node.js): converted es format file to cjs, update supported runtimes [#35]

[#35]: https://github.com/SumoLogic/sumologic-otel-lambda/pull/35
[nodejs-v1.17.2]: https://github.com/SumoLogic/sumologic-otel-lambda/releases/tag/nodejs-v1.17.2

## [java-v1.30.1]

### Released 2023-10-31

### Changed

- chore(java): update collector and instrumentation to latest upstream version [#19]
- chore(collector): deprecate `SUMOLOGIC_HTTP_TRACES_ENDPOINT_URL` in favor of `SUMO_OTLP_HTTP_ENDPOINT_URL`. [#19]

### Fixed

- chore(collector): fix `listenerAPI` available port association [#19]

[java-v1.30.1]: https://github.com/SumoLogic/sumologic-otel-lambda/releases/tag/java-v1.30.1

## [python-v1.20.0]

### Released 2023-10-30

### Changed

- chore(python): update collector and instrumentation to latest upstream version [#19]
- chore(collector): deprecate `SUMOLOGIC_HTTP_TRACES_ENDPOINT_URL` in favor of `SUMO_OTLP_HTTP_ENDPOINT_URL`. [#19]

### Fixed

- chore(collector): fix `listenerAPI` available port association [#19]

[python-v1.20.0]: https://github.com/SumoLogic/sumologic-otel-lambda/releases/tag/python-v1.20.0

## [nodejs-v1.17.1]

### Released 2023-10-30

### Changed

- chore(nodejs): update collector and instrumentation to latest upstream version [#19]
- chore(collector): deprecate `SUMOLOGIC_HTTP_TRACES_ENDPOINT_URL` in favor of `SUMO_OTLP_HTTP_ENDPOINT_URL`. [#19]
- chore(nodejs): update instrumentation dependencies [#20]

### Fixed

- chore(collector): fix `listenerAPI` available port association [#19]

[#19]: https://github.com/SumoLogic/sumologic-otel-lambda/pull/19
[#20]: https://github.com/SumoLogic/sumologic-otel-lambda/pull/20
[nodejs-v1.17.1]: https://github.com/SumoLogic/sumologic-otel-lambda/releases/tag/nodejs-v1.17.1

## [java-v1.24.0]

### Released 2023-06-02

### Added

- feat(sumolambda): initial sumologic-otel-java lambda layer v1.24.0 [#1]

[java-v1.24.0]: https://github.com/SumoLogic/sumologic-otel-lambda/releases/tag/java-v1.24.0

## [nodejs-v1.12.0]

### Released 2023-06-02

### Added

- feat(sumolambda): initial sumologic-otel-nodejs lambda layer v1.12.0 [#1]

[nodejs-v1.12.0]: https://github.com/SumoLogic/sumologic-otel-lambda/releases/tag/nodejs-v1.12.0

## [python-v1.17.0]

### Released 2023-06-01

### Added

- feat(sumolambda): initial sumologic-otel-python lambda layer v1.17.0 [#1]

[#1]: https://github.com/SumoLogic/sumologic-otel-lambda/pull/1
[python-v1.17.0]: https://github.com/SumoLogic/sumologic-otel-lambda/releases/tag/python-v1.17.0
