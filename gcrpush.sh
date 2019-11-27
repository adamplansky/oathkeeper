#!/usr/bin/env bash
set -eux

NAME=oathkeeper
PROJECT_ID=endevel-001
NAMESPACE=default

function IncVersion()
{
  local version=$1
  [[ "$version" =~ (.*[^0-9])([0-9]+)$ ]] && version="${BASH_REMATCH[1]}$((${BASH_REMATCH[2]} + 1))";
  if [ -z ${BASH_REMATCH[2]} ]
  then
    # if regex is not matched
    echo $(($version + 1))
  else
    # if regex is matched use new version
    echo $version
  fi
}

function LatestVersion()
{
    local versions=$1
    VERSIONS_ARRAY=($(echo ${versions} | tr "," "\n"))
    if [[ "$(declare -p VERSIONS_ARRAY)" =~ "declare -a" ]]; then
        LATEST_ARRAY=${VERSIONS_ARRAY[-1]}
        echo $LATEST_ARRAY
    else
        echo ${versions}
    fi
}


docker build -t $NAME -f Dockerfile.prod .
OLD_TAG=$(gcloud container images list-tags gcr.io/endevel-001/${NAME} | awk  'FNR == 2 { print $2 }')
OLD_TAG=${OLD_TAG:-"v0.0.0"}
OLD_TAG=$(LatestVersion ${OLD_TAG})
echo increasing version of tag $OLD_TAG
TAG=$(IncVersion ${OLD_TAG})
echo "$OLD_TAG -> $TAG"
GCR_URL=gcr.io/${PROJECT_ID}/${NAME}:${TAG}

docker tag $NAME $GCR_URL
docker push $GCR_URL
echo 'pushed...' $NAME $GCR_URL


#NAME=hydra-alpine
#docker build -t $NAME -f Dockerfile-alpine.prod .
#OLD_TAG=$(gcloud container images list-tags gcr.io/endevel-001/${NAME} | awk  'FNR == 2 { print $2 }')
#OLD_TAG=${OLD_TAG:-"v0.0.0"}
#OLD_TAG=$(LatestVersion ${OLD_TAG})
#echo increasing version of tag $OLD_TAG
#TAG=$(IncVersion ${OLD_TAG})
#echo "$OLD_TAG -> $TAG"
#GCR_URL=gcr.io/${PROJECT_ID}/${NAME}:${TAG}
#
#docker tag $NAME $GCR_URL
#docker push $GCR_URL
#echo 'pushed...' $NAME $GCR_URL






