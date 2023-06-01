# Building and Testing - Sumo Logic Distribution for OpenTelemetry Lambda Layers

## Build artifacts

Depends on the lambda layer you want to build you will need:

- golang 1.18
- nodejs 14.x+
- java 8+
- python 3.7+

1. Set `GOARCH` environment variable:

    ```bash
    export GOARCH=amd64 # Possible values, amd64 or arm64
    ```

1. In root directory run:

    ```bash
    make build-java # To build java layer artifacts
    make build-nodejs # To build nodejs layer artifacts
    make build-python # To build python layer artifacts
    ```

## Create lambda layer

You will need to configure [AWS credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html), install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and configure few environment variables.

1. Configure environment variables

    ```bash
    # Name of s3 bucket where build artifacts will be send
    export BUCKET_NAME=YOUR_BUCKET_NAME

    # Name of s3 bucket key name
    export BUCKET_KEY=BUCKET_KEY_NAME

    # AWS Region in which lambda layer will be created
    export REGION=eu-central-1
    export AWS_REGION=eu-central-1

    # Directory of the layer, possible values: java, nodejs, python
    export DIRECTORY=java

    # Architecture, possible values: x86_64, arm64
    export ARCHITECTURE=x86_64

    # Name of the layer
    export LAYER_NAME=YOUR_LAYER_NAME
    ```

1. Create s3 bucket

    ```bash
    make create-bucket
    ```

1. Copy artifacts to s3 bucket

    Set artifact name:
    - java: `opentelemetry-java-wrapper.zip`
    - nodejs: `opentelemetry-nodejs.zip`
    - python: `opentelemetry-python.zip`

    ```bash
    ARTIFACT_NAME=opentelemetry-java-wrapper.zip make copy-local-content-to-bucket
    ```

1. Create development lambda layer

    ```bash
    source ./${DIRECTORY}/layer-data.sh
    aws lambda publish-layer-version --layer-name "${LAYER_NAME}" --content S3Bucket=${BUCKET_NAME},S3Key=${BUCKET_KEY} \
    --compatible-runtimes ${RUNTIMES} --description "${DESCRIPTION}" --license-info "${LICENSE}"
    ```

1. Get latest version of the development lambda layer

    ```bash
    export TF_VAR_layer_arn=$(make get-dev-latest-lambda-layer-arn)
    ```

## Deploy receiver-mock

You will need to install [terraform](https://developer.hashicorp.com/terraform/downloads).

1. Go to `utils/receiver-mock/deploy` directory and execute:

    ```bash
    terraform init
    terraform apply --auto-approve
    ```

1. Get recevier-mock endpoint

    ```bash
    export TF_VAR_collector_endpoint=$(terraform output -raw loadbalancer_ip)
    export RECEIVER_ENDPOINT=${TF_VAR_collector_endpoint}
    ```

## Deploy lambda test function

1. Go to one of directories `java, nodejs or python` and then `tests/deploy` directory.

1. Deploy lambda test function

    ```bash
    terraform init
    terrafrom apply --auto-approve
    ```

1. Get function name

    ```bash
    export LAMBDA_FUNCTION_NAME=$(terraform output -raw service-name)
    ```

1. Get lambda api gateway url

    ```bash
    export LAMBDA_API_GW=$(terraform output -raw api-gateway-url)
    ```

1. Invoke lambda function

    ```bash
    curl -sS ${LAMBDA_API_GW}/%7Bproxy+%7D
    ```

## Run tests

1. Go to `tests/lambdalayer` directory

1. Execute tests

    ```bash
    # Set one of the lambda layers languages to test. Possible values: java, nodejs, python
    export LANGUAGE=java
    go test -v -run TestSpans${LANGUAGE}
    ```
