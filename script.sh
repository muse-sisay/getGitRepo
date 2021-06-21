#!/bin/sh
 
function usage() # [] or () or <> , which one is optional
{
  echo "Usage: $0 -t ACCESSTOKEN -u gh_username -r repo_name [ -p PROJECT TITLE ] [ -d path ]" >&2
  exit 2
}

while getopts 'st:u:r:p:d:h' args
do 
    case $args in 
        t) 
            api_token=$OPTARG
        ;;
        u) 
            user_name=$OPTARG
        ;;
        r) 
            repo_name=$OPTARG
        ;;
        p) 
           project_title=$OPTARG
        ;;
        d) 
            loc=$OPTARG
        ;;
        s) 
            private_repo=",\"private\" : true"
        ;;
        h |  *)
            usage
        ;;
    esac
done 

# Check args 
[ -z "$api_token" ] && usage
[ -z "$user_name" ] && usage
[ -z "$repo_name" ] && usage

# Assign repo name to project title, if missing 
if [ -z "$project_title" ]; then 
    project_title="$repo_name"
fi 


if [ -z "$loc" ]; then
    # Set current working directory if not set
    loc=$(pwd)
elif [ ! -d "$loc" ]; then
    # Check if exists 
    echo "$0 : $loc : No such directory"
    exit 3
fi

cd "$loc"

if [ -d "$repo_name" ]; then
    echo "$0: cannot create directory ‘${repo_name}’ in $loc : Project exists"
    exit 3
fi 

mkdir "$repo_name"
cd "$repo_name"

if [ $(curl -s -o /dev/null -w "%{http_code}" \
                -H "Authorization: token $api_token" "https://api.github.com/user/repos" \
                -d "{\"name\": \"${repo_name}\" ${private_repo}}") -ne 201 ]; then

    exit 5
fi


git init
git remote add origin git@github.com:"$user_name"/"$repo_name".git

echo "# $project_title" > README.md

git add README.md
git commit -m "intial commit"

git push -u origin master
