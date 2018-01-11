#!/bin/sh

# License: CC0 1.0 Universal
# https://creativecommons.org/publicdomain/zero/1.0/legalcode

set -e

. ./.travis/travis-doc-upload.cfg

[ "$TRAVIS_BRANCH" = master ]

[ "$TRAVIS_PULL_REQUEST" = false ]

[ "$TRAVIS_RUST_VERSION" = stable ]

[ -e target/doc ]

eval key=\$encrypted_${SSH_KEY_TRAVIS_ID}_key
eval iv=\$encrypted_${SSH_KEY_TRAVIS_ID}_iv

mkdir -p ~/.ssh
openssl aes-256-cbc -K $key -iv $iv -in .travis/id_ed25519.enc -out ~/.ssh/id_ed25519 -d
chmod 600 ~/.ssh/id_ed25519

git clone --branch gh-pages git@github.com:$DOCS_REPO deploy_docs

cd deploy_docs
git config user.name "doc upload bot"
git config user.email "nobody@example.com"
rm -rf $PROJECT_NAME
mv ../target/doc $PROJECT_NAME
git add -A $PROJECT_NAME
git commit -qm "doc upload for $PROJECT_NAME ($TRAVIS_REPO_SLUG)"
git push -q origin gh-pages
