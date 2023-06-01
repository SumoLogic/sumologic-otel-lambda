#!/bin/bash

declare -a layers=("YOUR_LAYER_NAME")

for layer in "${layers[@]}"
do
      ./layers_cleanup.sh ${layer} &
done
