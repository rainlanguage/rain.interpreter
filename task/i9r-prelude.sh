#!/usr/bin/env bash
set -euxo pipefail

# Needed by deploy script.
mkdir -p deployments/latest;

# Build metadata that is needed for deployments.
mkdir -p meta;
rain meta build \
    -i <(forge script --silent ./script/BuildAuthoringMeta.sol && cat ./meta/AuthoringMeta.rain.meta) \
    -m authoring-meta-v1 \
    -t cbor \
    -e deflate \
    -l none \
    -o meta/RainterpreterExpressionDeployerNPE2.rain.meta \
;