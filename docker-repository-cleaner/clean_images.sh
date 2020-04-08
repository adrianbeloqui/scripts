#!/bin/bash

# requires jq cli tool

main () {
    REGISTRY=http://localhost:5000
    REPO="$1"
    
    case $2 in

        '--tag')
            remove_image $3
            ;;
        '--days_to_keep')
            delete_by_timeframe $3
            ;;
        *)
            echo "wrongly called script"
            ;;
    esac
}

delete_by_timeframe() {
    DAYS_TO_KEEP=$1

    curl -s -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X GET $REGISTRY/v2/$REPO/tags/list 2>&1 | jq -r '.tags' | while read REPO_TAG; do
        REPO_TAG=${REPO_TAG//\"}
        REPO_TAG=${REPO_TAG//,}
        REPO_TAG=${REPO_TAG//[}
        REPO_TAG=${REPO_TAG//]}
        if [ "$REPO_TAG" != "" ]; then
            IMAGE_DATE=$(get_tag_date $REPO_TAG)
            TODAYS_DATE=`date +%s`
            DIFF=`expr $TODAYS_DATE - $IMAGE_DATE`
            DIFF=`expr $DIFF / 86400`

            if [ $DIFF -gt $DAYS_TO_KEEP ]; then
                remove_image $REPO_TAG
            fi
        fi
    done

    registry garbage-collect /etc/docker-distribution/registry/config.yml

}

get_tag_date () {
    TAG="$1"
    IMAGE_DATE=$(curl -s -H "Accept: application/vnd.docker.distribution.manifest.v1+json" -X GET $REGISTRY/v2/$REPO/manifests/$TAG 2>&1 | jq -r '.history[].v1Compatibility' | jq -r '.created' | sort | tail -n1)
    
    date -d "$IMAGE_DATE" +%s
}

remove_image() {
    TAG=`echo $1 | sed 's/^[[:space:]]*//'`
    
    echo "Trying to remove ${TAG}..."

    TAG_URL=$REGISTRY/v2/$REPO/manifests/$TAG
    TAG_URL=${TAG_URL%$'\r'}
    echo $TAG_URL

    SHA256=$(curl -v -s -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X GET $TAG_URL 2>&1 | grep Docker-Content-Digest | awk '{print ($3)}')

    DELETE_URL=$REGISTRY/v2/$REPO/manifests/$SHA256
    DELETE_URL=${DELETE_URL%$'\r'}
    DELETED=$(curl -s -o /dev/null -w "%{http_code}" -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X DELETE $DELETE_URL)

    echo $DELETED
}

main "$@"
