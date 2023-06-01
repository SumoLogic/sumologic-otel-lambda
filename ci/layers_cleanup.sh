#!/bin/bash

layer=$1

get_regions () {
  echo $(aws ssm get-parameters-by-path --region "us-east-1" --path /aws/service/global-infrastructure/services/lambda/regions --query 'Parameters[].Value' --output text | tr '[:blank:]' '\n' | grep -v -e ^cn- -e ^us-gov- | sort -r)
}
regions=$(get_regions)

get_versions () {
  echo $(aws lambda list-layer-versions --layer-name "$layer" --region "$region" --output text --query LayerVersions[].Version | tr '[:blank:]' '\n')
}

for region in $regions;
do
  versions=$(get_versions "$region")
  for version in $versions;
  do
    echo "deleting arn:aws:lambda:$region:*:layer:$layer:$version"
    aws lambda delete-layer-version --region "$region" --layer-name "$layer" --version-number "$version" > /dev/null
  done
done
