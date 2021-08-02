#!/usr/bin/env bash
# Push HTML files to gh-pages automatically.

# Fill this out with the correct org/repo
ORG=yunwan1x
REPO=awesome-cn
# This probably should match an email for one of your users.
EMAIL=vs2010wy@live.cn

set -e

git remote add gh-token "https://${GH_TOKEN}@github.com/$ORG/$REPO.git";
git fetch gh-token && git fetch gh-token gh-pages:gh-pages;

# Update git configuration so I can push.
if [ "$1" != "dry" ]; then
    # Update git config.
    git config user.name "Travis Builder"
    git config user.email "$EMAIL"
fi

pythonVersion=`python -c 'import site; print(site.getsitepackages()[0])'`
cp search_index.py ${pythonVersion}/mkdocs/contrib/search/search_index.py

# 合并icopy-site的爬虫更新内容并提交
git clone --depth 1  -b master --single-branch https://github.com/icopy-site/awesome-cn.git
cp -f  awesome-cn/docs/awesome/*  ./docs/awesome/
cp awesome-cn/mkdocs.yml ./
time=`date +'%Y-%m-%d %H:%M %Z'`
sed -i 's/chenjiajia/wangyun/g' ./mkdocs.yml
sed -i 's/asmcn.icopy.site/yunwan1x.github.io/g' ./mkdocs.yml
sed -i 's/icopy-site/yunwan1x/g' ./mkdocs.yml
sed -i "s/tabs: false/tabs: true/g" ./mkdocs.yml

sed -i "s/.*本文档采用.*构建.*/**本文档采用 [mkdocs](https:\/\/github.com\/mkdocs\/mkdocs) 构建，构建时间: $time **/g" ./docs/index.md
rm -rf awesome-cn/
find ./docs -name *.md -type f|xargs sed -i  "s/<script>.*<\/script>/ /g"
git config --global user.email "512458266@qq.com"
git config --global user.name "githubAction"
git add .&&git commit -m "$time build by githubAction"
git push

mkdocs gh-deploy -v --clean --force --remote-name gh-token;
