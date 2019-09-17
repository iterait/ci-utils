#!/usr/bin/env bash
set -e

# prepare the env for building docs
export DEBIAN_FRONTEND=noninteractive
apt-get install -y --force-yes python3-sphinx graphviz locales language-pack-en openssh-client

mkdir -p /root/.ssh
chmod 600 -R /root/.ssh
ssh-keyscan -H github.com >> /root/.ssh/known_hosts

if [ -f requirements-docs.txt ]; then
	pip3 install -r requirements.txt
fi

locale-gen --purge
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
git config --global user.email "hello@iterait.com"
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
git_root="$(git rev-parse --show-toplevel)"
cp -r docs/build/* "${git_root}"
rm -rf docs
git checkout origin/master -- .circleci/config.yml
git add .circleci/config.yml
git add --all
git commit -m "Docs update from $CIRCLE_BRANCH : $CIRCLE_SHA1"

if [ ! -f "${git_root}"/index.html ]; then
	>&2 echo doc build failed
	exit 1
fi

git push
