# Docker Image Reaper

Remove docker images locally.

## It needs:

pip install docker-py==1.3.0
https://docker-py.readthedocs.io/en/1.3.0/

Might need to be modified if docker API differs.

## Usage:

python reaper.py [FLAGS] [DAYS_TO_KEEP]

Flags available:

* -i / --repository-contains -- Only images that contain this string in their repositories will be considered

Environment variables available:

* DOCKER_SOCKET -- Default value is 'unix://var/run/docker.sock'
