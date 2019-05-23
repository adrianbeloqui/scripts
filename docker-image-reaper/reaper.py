# pip install docker-py==1.3.0
# https://docker-py.readthedocs.io/en/1.3.0/

import sys
import os
from docker import Client
from datetime import datetime

CLIENT = Client(base_url=os.environ.get('DOCKER_SOCKET', 'unix://var/run/docker.sock'))


def main(days_to_keep, repo_contains):

    images = CLIENT.images()
    today = datetime.now()

    for image in images:
        if repo_contains:
            if not is_repository(image, repo_contains):
                continue

        created_on = datetime.fromtimestamp(image.get("Created"))
        days_since_creation = abs((today - created_on).days)
        if days_since_creation > days_to_keep:
            try:
                CLIENT.remove_image(image.get("Id"))
            except Exception as e:
                print("Failed to delete: {}. Exception {}".format(image.get("Id"), e))
            else:
                print("Deleted: {}. Was {} days old!".format(image.get("Id"), days_since_creation))


def is_repository(image, repo_contains):
    matches = False
    for repo in image.get("RepoTags"):
        if repo_contains in repo:
            matches = True
            break
    return matches


def _validate_args():
    flag = None
    repository_contains = None
    try:
        flag = sys.argv[1]
    except IndexError as e:
        pass
    else:
        if flag == '--help':
            return None, flag, repository_contains
        elif flag == '-i' or flag == '--repository-contains':
            try:
                repository_contains = sys.argv[2]
            except IndexError as e:
                raise IndexError("You forgot to define a string to match against repositories")
        try:
            days = sys.argv[-1]
        except IndexError as e:
            raise IndexError("Try running it like this -> python remove_images [FLAGS] [DAYS_TO_KEEP]")
        else:
            try:
                days = int(days)
            except ValueError as e:
                raise ValueError("DAYS_TO_KEEP must be an integer")
    return days, flag, repository_contains


def print_help():
    print("Remove docker images older than DAYS_TO_KEEP")
    print("    python remove_images.py [FLAGS] [DAYS_TO_KEEP]")
    print()
    print("Flags available:")
    print("    -i --repository-contains    "
          "Only images that contain this string in their repositories will be considered")
    print("Environment variables available:")
    print("    DOCKER_SOCKET    "
          "Path to the Docker socket. Otherwise 'unix://var/run/docker.sock' is used as default")


if __name__ == '__main__':
    days, flag, repository_contains = _validate_args()
    if flag == '--help':
        print_help()
    elif days:
        main(days, repository_contains)
