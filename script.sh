#!/bin/sh
 
LICENSES=("agpl-3.0" "apache-2.0" "bsd-2-clause" "bsd-3-clause"\
        "bsl-1.0" "cc0-1.0" "epl-2.0" "gpl-2.0" "gpl-3.0" "lgpl-2.1"\
         "mit" "mpl-2.0" "unlicense" )

USAGE="Syntax: gitinit  [-s] [-u GH_USERNAME] [-p PROJECT TITLE] [-l LICENSE] [-d PATH] \"Repository-name\""

function usage()
{
    echo $USAGE
    exit 2
}

function help(){

    echo "gitinit is tool for intialize a git repo and push an inital commit to github."
    echo
    echo $USAGE
    echo "options:"
    echo "h     Print this Help."
    echo "-u    USERNAME "
    echo "-p    PROJECT TITLE  h1 displayed on README.md. Defaults to repository-name"
    echo "s     set as a private repository."
    exit 2

}

function set_username(){
    # Reads username from  git config 
    user_name=$(awk '/name/ {print $3}' ~/.gitconfig)
}
function check_username(){

    if [ -z "$user_name" ]; then 
            echo "Missing username, can't find username in ~/.gitconfig"
            usage
    fi

}

function check_license(){ # ALT : check_valid_license
    # valid license is passed
    if [ ! -z $license ] && [[ ! " ${LICENSES[@]} " =~ " ${license} " ]]; then
        echo "Invalid license \"$license\""
        echo "License should be one of the following [${LICENSES[*]}]"
        exit 2
    fi
}

function directory_exists(){ # Check if directory exitsts

    if [ ! -d "$loc" ]; then
        echo "$0 : $loc : No such directory"
        exit 3
    fi
}



function setup_args(){

    # USERNAME
    [ -z "$user_name" ] && set_username
    check_username

    # API
    # (read) Access/api token
    api_token=$(cat ~/.ssh/ghAccessToken) # TODO : check if file exists
    repo_name=${@: -1}

    #  PROJECT TITLE
    [ -z "$project_title" ] && project_title="$repo_name"

    # REPO DIRECTORY
    [ -z "$loc" ] && loc=$(pwd)

}

function create_local_repo_path(){
    
    cd "$loc"

    if [ -d "$repo_name" ]; then
        echo "$0: cannot create directory ‘${repo_name}’ in $loc : Project exists"
        exit 3
    fi 

    mkdir "$repo_name"
    cd "$repo_name"

}

function create_repo_files(){

    echo "# $project_title" > README.md

    if [ ! -z $license ]; then 
        curl -s -H "Accept: application/vnd.github.v3+json" \
            https://api.github.com/licenses/$license | jq -r .body > LICENSE
    fi 
}
while getopts 'sl::u:p:d:h' args ;do 
    case $args in 
        u) 
            user_name=$OPTARG
        ;;
        p) 
           project_title=$OPTARG
        ;;
        l)
            license=$OPTARG
            check_license
        ;;
        d) 
            loc=$OPTARG
            directory_exists
        ;;
        s) 
            private_repo=",\"private\" : true" #BUG : passing this without any arguments breaks the script
        ;;
        h |  *)
            usage
        ;;
    esac
done 

setup_args

# LOCAL REPO
create_local_repo_path
create_repo_files

# REMOTE REPO
if [ $(curl -s -o /dev/null -w "%{http_code}" \
                -H "Authorization: token $api_token" "https://api.github.com/user/repos" \
                -d "{\"name\": \"${repo_name}\" ${private_repo}}") -ne 201 ]; then
    
    echo "Unable to create remote repo."
    exit 5
fi

git init
git remote add origin git@github.com:"$user_name"/"$repo_name".git

git add README.md LICENSE
git commit -m "intial commit"

git push -u origin master
