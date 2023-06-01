SHELL:=/bin/bash

# Linters

.PHONY: yaml-lint
yaml-lint: gh-actions-lint

.PHONY: gh-actions-lint
gh-actions-lint:
	yamllint -c .yamllint.yaml \
		.github

.PHONY: markdown-lint
markdown-lint:
	markdownlint --config .markdownlint.jsonc \
		docs \
		collector \
		java \
		nodejs \
		python \
		tests \
		CHANGELOG.md \
		README.md

.PHONY: markdown-links-lint
markdown-links-lint:
	./ci/markdown_links_lint.sh

.PHONY: markdown-table-formatter-check
markdown-table-formatter-check:
	./ci/markdown_table_formatter.sh --check

.PHONY: shellcheck
shellcheck:
	./ci/shellcheck.sh

# Formatters

.PHONY: format
format: markdown-table-formatter-format

.PHONY: markdown-table-formatter-format
markdown-table-formatter-format:
	./ci/markdown_table_formatter.sh --format

# Builders

.PHONY: build-all
build-all: build-collector build-java build-nodejs build-python

.PHONY: build-collector
build-collector: 
	pushd collector && ./build.sh || exit

.PHONY: build-java
build-java: 
	pushd java && ./build.sh || exit

.PHONY: build-nodejs
build-nodejs: 
	pushd nodejs && ./build.sh || exit

.PHONY: build-python
build-python: 
	pushd python && ./build.sh || exit

# AWS Layers

.PHONY: create-bucket
create-bucket:
	aws s3 mb s3://${BUCKET_NAME} --region ${REGION}

.PHONY: copy-content-to-bucket
copy-content-to-bucket:
	aws s3 cp ~/artifact/${ARTIFACT_ARCHIVE_BASE_NAME}-${ARCHITECTURE}.zip s3://${BUCKET_NAME}/${BUCKET_KEY} --region ${REGION}

.PHONY: copy-local-content-to-bucket
copy-local-content-to-bucket:
	aws s3 cp ./${DIRECTORY}/${ARTIFACT_NAME} s3://${BUCKET_NAME}/${BUCKET_KEY} --region ${REGION}

.PHONY: create-dev-lambda-layer
create-dev-lambda-layer:
	source ./${DIRECTORY}/layer-data.sh && \
	aws lambda publish-layer-version --layer-name "${LAYER_NAME}" --content S3Bucket=${BUCKET_NAME},S3Key=${BUCKET_KEY} \
	--compatible-runtimes $$RUNTIMES --description "$$DESCRIPTION" --license-info "$$LICENSE" --debug

.PHONY: get-dev-latest-lambda-layer-arn
get-dev-latest-lambda-layer-arn:
	@aws lambda list-layer-versions --layer-name "${LAYER_NAME}" --region "${REGION}" --query 'LayerVersions[0].LayerVersionArn' \
	--output text | head -n 1

.PHONY: create-release-lambda-layer
create-release-lambda-layer:
	source ./${DIRECTORY}/layer-data.sh && \
	FINAL_LAYER_NAME=$$OFFICIAL_LAYER_NAME-$$LAYER_ARCH-$$VERSION && \
	aws lambda publish-layer-version --layer-name "$$FINAL_LAYER_NAME" --content S3Bucket=${BUCKET_NAME},S3Key=${BUCKET_KEY} \
	--compatible-runtimes $$RUNTIMES --description "$$DESCRIPTION" --license-info "$$LICENSE"

.PHONY: get-public-latest-lambda-layer-arn
get-public-latest-lambda-layer-arn:
	source ./${DIRECTORY}/layer-data.sh && \
	FINAL_LAYER_NAME=$$OFFICIAL_LAYER_NAME-$$LAYER_ARCH-$$VERSION && \
	aws lambda list-layer-versions --layer-name "$$FINAL_LAYER_NAME" --region "$$REGION" --query 'LayerVersions[0].LayerVersionArn' \
	--output text | head -n 1

.PHONY: publish-lambda-layer
publish-lambda-layer: 
	source ./${DIRECTORY}/layer-data.sh && \
	FINAL_LAYER_NAME=$$OFFICIAL_LAYER_NAME-$$LAYER_ARCH-$$VERSION && \
	LAYER_VERSION=$$(aws lambda list-layer-versions --layer-name "$$FINAL_LAYER_NAME" --region "$$REGION" \
	--query 'max_by(LayerVersions, &Version).Version') && \
	aws lambda add-layer-version-permission --layer-name "$$FINAL_LAYER_NAME" \
	--version-number "$$LAYER_VERSION" --statement-id allAccountsExample --principal "*" --action 'lambda:GetLayerVersion'

.PHONY: clean-s3
clean-s3: 
	aws s3 rm s3://${BUCKET_NAME} --recursive
	aws s3 rb --force s3://${BUCKET_NAME}
