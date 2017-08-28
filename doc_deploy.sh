#!/usr/bin/env bash

# prepare the env for building docs
apt-get install -y python3-sphinx graphviz locales language-pack-en

if [ -f requirements-docs.txt ]; then
	pip3 install -r requirements.txt
fi

locale-gen --purge
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
git config --global user.email "cxflow@cognexa.com"
git config --global user.name "CircleCI"
git submodule update --init

cd docs

# update the shared templates etc.
if [ -d _base ]; then
	git submodule update --remote _base
	pip3 install -r _base/requirements.txt
fi

# build the docs
sphinx-build . build

# push the docs to the gh-pages branch
cd ..
git stash
git checkout gh-pages
find . -maxdepth 1 -not -path '*/\.*' -not -name 'docs' -not -name 'CNAME' -exec rm -rf {} \;
cp -r docs/build/* .
rm -rf docs
git add --all
git commit -m "Docs update from $CIRCLE_BRANCH : $CIRCLE_SHA1"

if [ ! -f index.html ]; then
	>&2 echo doc build failed
	exit 1
fi

git push
