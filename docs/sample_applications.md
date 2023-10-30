# Sample applications deployment

Every Sumo Logic Lambda Layer can be tested with the following sample applications provided by OpenTelemetry Lambda.

## Requirements

- configured [AWS credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- [AWS SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html)
- [Sumo Logic OTLP/HTTP Source](https://help.sumologic.com/docs/send-data/hosted-collectors/http-source/otlp/)

## Deployment

1. Checkout repository

    ```bash
    git clone --recurse-submodules https://github.com/SumoLogic/sumologic-otel-lambda.git
    ```

1. Download sample application function code

    - `java`

        ```bash
        wget https://github.com/SumoLogic/sumologic-otel-lambda/releases/download/java-v1.24.0/java-sample-app.jar -o java/sample-apps/java-sample-app.jar
        ```

    - `nodejs`

        ```bash
        wget https://github.com/SumoLogic/sumologic-otel-lambda/releases/download/nodejs-v1.12.0/nodejs-sample-app.zip -o nodejs/sample.zip
        unzip nodejs/sample.zip -d nodejs/sample-apps
        ```

    - `python`

        ```bash
        wget https://github.com/SumoLogic/sumologic-otel-lambda/releases/download/python-v1.20.0/python-sample-app.zip -o python/sample.zip
        unzip python/sample.zip -d python/sample-apps
        ```

1. Unzip downloaded code

    In one of the directories `nodejs` or `python` unzip the sample application running. Note: omit step if `java`.

    ```bash
    cd sample-apps
    unzip function.zip -d sample_function
    ```

1. Set Sumo Logic OTLP/HTTP Source URL and AWS Region

    ```bash
    export SUMO_OTLP_HTTP_ENDPOINT_URL=https://YOUR_HTTP_TRACES_SOURCE_URL
    export AWS_REGION=YOUR_AWS_REGION
    ```

1. Deploy sample application lambda function

    For `nodejs` and `python` execute:

    ```bash
    sam build -u && sam deploy --stack-name sumo-logic-example-function \
    --template template.yaml \
    --parameter-overrides ParameterKey=SumoHttpTracesSourceUrl,ParameterValue=${SUMO_OTLP_HTTP_ENDPOINT_URL} \
    --capabilities CAPABILITY_IAM \
    --region ${AWS_REGION} \
    --resolve-s3
    ```

    For `java` execute:

    ```bash
    sam deploy --stack-name sumo-logic-example-function \
    --template template.yaml \
    --parameter-overrides ParameterKey=SumoHttpTracesSourceUrl,ParameterValue=${SUMO_HTTP_TRACES_SOURCE_URL} \
    --capabilities CAPABILITY_IAM \
    --region ${AWS_REGION} \
    --resolve-s3
    ```

1. Invoke function

    After successful deployment of the sample lambda function, the `SampleAppApiEndpoint` should be displayed. Please use its value as URL.

    ```bash
    curl SampleAppApiEndpointValue
    ```
