#!/bin/bash

curl -sL "${fileurl:?}" -o "${filename:?}"
sha256sum "${filename}"


if [ "${hash:?}  -" = "$(sha256sum < "$filename")" ]; then
    echo "The hash value is correct"
    exit 0
else
    echo "The hash value is incorrect and should be updated in the Dockerfile"
    echo "Expected ${hash}"
    exit 1
fi