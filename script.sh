#!/bin/sh
 
LICENSES=("agpl-3.0" "apache-2.0" \
        "bsd-2-clause" "bsd-3-clause"\
        "bsl-1.0" "cc0-1.0" "epl-2.0" \
        "gpl-2.0" "gpl-3.0" "lgpl-2.1"\
         "mit" "mpl-2.0" "unlicense" )

function usage() # [] or () or <> , which one is optional
{
    echo "Syntax: gitinit -t ACCESSTOKEN -u gh_username -r repo_name [ -p PROJECT TITLE ] [ -d path ]"
    echo
    echo "   A tool to intialize a git repo and push inital commit to github."
    echo
    echo "   options:"
    echo "   s     Setup Private Repository."
    echo "   h     Print this Help."
    echo
    echo "   arguments:"
    echo "   -u USERNAME "
    echo "   -r REPO NAME "
    echo -e "   -p PROJECT TITLE  h1 displayed on README.md. Default is REPO NAME"
    exit 2
}

while getopts 'sl::u:r:p:d:h' args
do 
    case $args in 
        u) 
            user_name=$OPTARG
        ;;
        r) 
            repo_name=$OPTARG
        ;;
        p) 
           project_title=$OPTARG
        ;;
        l)
            license=$OPTARG
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
# repo name is setup
[ -z "$repo_name" ] && usage

# username is setup
if [ -z "$user_name" ]; then 
    # Read  git username from git config
    user_name=$(awk '/name/ {print $3}' ~/.gitconfig)

    if [ -z "$user_name" ]; then 
        echo "user_name is missing"
        usage
    fi
fi 

# valid license is passed
if [ ! -z $license ] && [[ ! " ${LICENSES[@]} " =~ " ${license} " ]]; then
    echo "Invalid license \"$license\""
    echo "License should be one of the following [${LICENSES[*]}]"
    exit 2
fi

# (read) Access/api token
 api_token=$(cat ~/.ssh/ghAccessToken)



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
    
    echo "Unable to create remote repo."
    exit 5
fi


git init
git remote add origin git@github.com:"$user_name"/"$repo_name".git


echo "# $project_title" > README.md
if [ ! -z $license ]; then 
    curl -s -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/licenses/$license | jq -r .body > LICENSE
fi 

git add README.md LICENSE
git commit -m "intial commit"

git push -u origin master
