#!/usr/bin/env bash

# build package and upload to private pypi index
echo "[distutils]" > ~/.pypirc
echo "index-servers = pypi" >> ~/.pypirc
echo "[pypi]" >> ~/.pypirc
echo "username=$PYPI_USER" >> ~/.pypirc
echo "password=$PYPI_PASS" >> ~/.pypirc
echo "[metadata]" >> ~/.pypirc
echo "description-file = README.md" >> ~/.pypirc

python3 setup.py sdist bdist_wheel upload -r pypi
