#! /bin/bash

if (( $# != 1 )); then
    echo "Usage: $0 <docker_image_tag>"
    exit 1
fi
docker_tag="$1"
dockerdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
fn="myapp.tar.gz"
path="$dockerdir/$fn"
# Need to be in the same directory as .git folder
cd "$dockerdir/.."
# create a tar.gz archive of the current git HEAD that respects .gitignore
git archive -o "$path" --format=tar.gz HEAD
# pass the archive file to docker build as a build argument
docker build --build-arg "GIT_ARCH=$fn" -t "$docker_tag" "$dockerdir"
rm "$path" # remove the archive file
