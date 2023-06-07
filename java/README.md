# Sumo Logic Distribution for OpenTelemetry Java Lambda Layer unreleased version

Layers for running Java applications on AWS Lambda with OpenTelemetry.

Sumo Logic lambda layers support:

- `Java8 (Corretto)` and `Java11 (Corretto)` runtimes
- `x86_64` and `arm64` architectures

## AMD64 Lambda Layers List

| Region         | ARN                                                                                          |
|----------------|----------------------------------------------------------------------------------------------|
| af-south-1     | arn:aws:lambda:af-south-1:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1     |
| ap-east-1      | arn:aws:lambda:ap-east-1:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1      |
| ap-northeast-1 | arn:aws:lambda:ap-northeast-1:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1 |
| ap-northeast-2 | arn:aws:lambda:ap-northeast-2:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1 |
| ap-northeast-3 | arn:aws:lambda:ap-northeast-3:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1 |
| ap-south-1     | arn:aws:lambda:ap-south-1:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1     |
| ap-southeast-1 | arn:aws:lambda:ap-southeast-1:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1 |
| ap-southeast-2 | arn:aws:lambda:ap-southeast-2:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1 |
| ca-central-1   | arn:aws:lambda:ca-central-1:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1   |
| eu-central-1   | arn:aws:lambda:eu-central-1:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1   |
| eu-north-1     | arn:aws:lambda:eu-north-1:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1     |
| eu-south-1     | arn:aws:lambda:eu-south-1:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1     |
| eu-west-1      | arn:aws:lambda:eu-west-1:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1      |
| eu-west-2      | arn:aws:lambda:eu-west-2:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1      |
| eu-west-3      | arn:aws:lambda:eu-west-3:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1      |
| me-south-1     | arn:aws:lambda:me-south-1:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1     |
| sa-east-1      | arn:aws:lambda:sa-east-1:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1      |
| us-east-1      | arn:aws:lambda:us-east-1:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1      |
| us-east-2      | arn:aws:lambda:us-east-2:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1      |
| us-west-1      | arn:aws:lambda:us-west-1:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1      |
| us-west-2      | arn:aws:lambda:us-west-2:663229565520:layer:sumologic-otel-lambda-java-x86_64-v1-24-0:1      |

## ARM64 Lambda Layers List

| Region         | ARN                                                                                         |
|----------------|---------------------------------------------------------------------------------------------|
| ap-northeast-1 | arn:aws:lambda:ap-northeast-1:663229565520:layer:sumologic-otel-lambda-java-arm64-v1-24-0:1 |
| ap-northeast-3 | arn:aws:lambda:ap-northeast-3:663229565520:layer:sumologic-otel-lambda-java-arm64-v1-24-0:1 |
| ap-south-1     | arn:aws:lambda:ap-south-1:663229565520:layer:sumologic-otel-lambda-java-arm64-v1-24-0:1     |
| ap-southeast-1 | arn:aws:lambda:ap-southeast-1:663229565520:layer:sumologic-otel-lambda-java-arm64-v1-24-0:1 |
| ap-southeast-2 | arn:aws:lambda:ap-southeast-2:663229565520:layer:sumologic-otel-lambda-java-arm64-v1-24-0:1 |
| eu-central-1   | arn:aws:lambda:eu-central-1:663229565520:layer:sumologic-otel-lambda-java-arm64-v1-24-0:1   |
| eu-west-1      | arn:aws:lambda:eu-west-1:663229565520:layer:sumologic-otel-lambda-java-arm64-v1-24-0:1      |
| eu-west-2      | arn:aws:lambda:eu-west-2:663229565520:layer:sumologic-otel-lambda-java-arm64-v1-24-0:1      |
| us-east-1      | arn:aws:lambda:us-east-1:663229565520:layer:sumologic-otel-lambda-java-arm64-v1-24-0:1      |
| us-east-2      | arn:aws:lambda:us-east-2:663229565520:layer:sumologic-otel-lambda-java-arm64-v1-24-0:1      |
| us-west-2      | arn:aws:lambda:us-west-2:663229565520:layer:sumologic-otel-lambda-java-arm64-v1-24-0:1      |

## Lambda Container dependencies

- [amd64 containers](https://github.com/SumoLogic/sumologic-otel-lambda/releases/download/java-v1.24.0/opentelemetry-java-wrapper-amd64.zip)
- [arm64 containers](https://github.com/SumoLogic/sumologic-otel-lambda/releases/download/java-v1.24.0/opentelemetry-java-wrapper-arm64.zip)

## Sample applications

Please see [general documentation](../docs/sample_applications.md) for more information about the sample applications deployment.
