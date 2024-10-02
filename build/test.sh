#!/bin/sh
set -e

printf "\n"
echo "============================================"
echo "Docker Build and Sanity Check Run"
echo "============================================"
docker build -t pgtd9109 .
echo "Expecting help output with client-ca-roots-path line:"
docker run -t pgtd9109 --help | grep client-ca-roots-path
echo "============================================"
echo "Docker Build and Sanity Check Passed"
echo "============================================"
printf "\n\n\n\n\n"
echo "Sanity check passed. Congratulations. Bye!"