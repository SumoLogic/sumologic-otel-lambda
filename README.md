# Sumo Logic Distribution for OpenTelemetry Lambda Layers

`sumologic-otel-lambda` publishes preconfigured [OpenTelemetry Lambda](https://github.com/open-telemetry/opentelemetry-lambda) layers which provide instrumentation for AWS Lambda functions.
Released `sumologic-otel-lambda` layers are available:

- Java wrapper layer contains OpenTelemetry Java `v1.24.0` and OpenTelemetry Collector `v0.75.0`. Please see list of [lambda layers](https://github.com/SumoLogic-Labs/sumo-opentelemetry-lambda/tree/release-java-v1.24.0).

- NodeJS layer contains OpenTelemetry JavaScript SDK `v1.12.0` and OpenTelemetry Collector `v0.75.0`. Please see list of [lambda layers](./nodejs/README.md).

- Python layer contains OpenTelemetry Python SDK `v1.17.0` with instrumentation `v0.38b0` and OpenTelemetry Collector `v0.75.0`. Please see list of [lambda layers](./python/README.md).

## Sample applications

Please see [general documentation](./docs/sample_applications.md) for more information about the sample applications deployment.

## License

This project is licensed under the Apache-2.0 License.
