#!/bin/bash 

script_path=$(realpath "$(dirname "$0")")

cd ${script_path}

mocko -p 3000 --watch endpoints
