#!/usr/bin/env bash

# prepare the env for building docs
apt-get install -y python3-sphinx graphviz locales language-pack-en openssh-client

ssh /root/.ssh
chmod 600 -R /root/.ssh
ssh-keyscan -H github.com >> /root/.ssh/known_hosts

if [ -f requirements-docs.txt ]; then
	pip3 install -r requirements.txt
fi

locale-gen --purge
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
git config --global user.email "cxflow@cognexa.com"
git config --global user.name "CircleCI"
git submodule update --init
git submodule sync

cd docs

# update the shared templates etc.
if [ -d _base ]; then
	cd _base
	git pull
	cd ../
	git submodule update --remote _base
	pip3 install -r _base/requirements.txt
fi

# build the docs
sphinx-build . build -vvv

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
