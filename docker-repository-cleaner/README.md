# Docker Respository Cleaner

This scripts removes images stored in a docker registry. It can remove images based on the amount of days since creation, or a specific image tag.

## Requirements

This script was used against a private repository installed using the `yum docker-distribution` package.

`jq` tool -> https://stedolan.github.io/jq/download/

## Usage

./clean_images.sh REPO [FLAG] [ARGUMENT]

Flags available:

* --tag
  * requires an ARGUMENT for tag name
* --days_to_keep
  * requires and ARGUMENT for amount of days until the cutoff. Anything older than this number will be removed from the repository.
  
  
