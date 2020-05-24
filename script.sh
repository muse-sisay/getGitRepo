#!/bin/sh

echo "enter repo name : "
read repo_name


test -z $repo_name && echo "Repo name required." 1>&2 && exit 1
#AbrahamTerfie is my git username replace yours with your own 
curl -u 'AbrahamTerfie' https://api.github.com/user/repos -d "{\"name\":\"$repo_name\"}"

echo "repo created sucesfully "
touch README.md
git init
git add README.md
git add .
git commit -m "first commit"
git remote add origin https://github.com/AbrahamTerfie/$repo_name.git
git push -u origin master
