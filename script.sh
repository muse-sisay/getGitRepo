#!/bin/sh
 
LICENSES=("agpl-3.0" "apache-2.0" "bsd-2-clause" "bsd-3-clause" \
        "bsl-1.0" "cc0-1.0" "epl-2.0" "gpl-2.0" "gpl-3.0" "lgpl-2.1" \
         "mit" "mpl-2.0" "unlicense" )

USAGE="Syntax: gitinit  [-s] [-u GH_USERNAME] [-p PROJECT TITLE] [-l LICENSE] [-d PATH] \"Repository-name\""

function usage()
{
    echo $USAGE
    exit 2
}

function help(){

    echo
    echo "gitinit is tool for intialize a git repo and push an inital commit to Github."
    echo
    echo $USAGE
    echo
    echo " options:"
    echo "  - h    Print this Help."
    echo "  - u    git USERNAME "
    echo "  - p    PROJECT TITLE  heading displayed on README.md. Defaults to repository-name"
    echo "  - s    set as a private repository."
    echo
    exit 2

}

function read_global_git_config(){
    # Reads username from  git config 
    global_git_user=$(awk '/name/ {print $3}' ~/.gitconfig 2> /dev/null)
    
    if [ "$?"  -eq 2 ] && [ -z "$git_user" ]; then 
        echo "Missing global git config. Add using "
        echo "    git config --global user.name"
        echo "    git config --global user.email"
        exit 
    fi
}

function set_username(){
   
    read_global_git_config

    if [ -z "$git_user" ]; then
        git_user=$global_git_user
    fi

    # Only create a local git config  
    # if git_user is diffrent  global_git_user
    if [ $git_user != $global_git_user ]; then
        # Prompt for git email
        read -p "Git email: " git_email
        set_local_repo="true"
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
    set_username

    # API
    # (read) Access/api token
    api_token=$(cat ~/.ssh/ghAccessToken) # TODO : check if file exists
    repo_name=$1

    #  PROJECT TITLE
    [ -z "$project_title" ] && project_title="$repo_name"

    # REPO DIRECTORY
    [ -z "$loc" ] && loc=$(pwd)

}

function create_local_repo_path(){
    
    cd "$loc"

    if [ -e "$repo_name" ]; then
        echo "$0: cannot create directory ‘${repo_name}’ in $loc : Project exists"
        exit 3
    fi 

    mkdir "$repo_name"
    cd "$repo_name"

}

function create_project_files(){

    echo "# $project_title" > README.md

    if [ ! -z $license ]; then 
        curl -s -H "Accept: application/vnd.github.v3+json" \
            https://api.github.com/licenses/$license | jq -r .body > LICENSE
    fi 
}

function intialize_repo(){
    
    git init

    if [ ! -z $set_local_repo ]; then 
        git config user.name $git_user
        git config user.email $git_email
    fi

    git remote add origin git@"github-${git_user}":"$git_user"/"$repo_name".git

    git add README.md LICENSE
    git commit -m "intial commit"
}

# /////////////////////////////////////////////
# ////////////////////////////////////////////

while getopts 'sl:u:p:d:h' args "${@:1:$#-1}" ;do 
    case $args in 
        u) 
            git_user=$OPTARG
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
            help
        ;;
    esac
done 

setup_args ${@: -1}

# LOCAL REPO
create_local_repo_path
create_project_files
intialize_repo 

# REMOTE REPO
if [ $(curl -s -o /dev/null -w "%{http_code}" \
                -H "Authorization: token $api_token" "https://api.github.com/user/repos" \
                -d "{\"name\": \"${repo_name}\" ${private_repo}}") -ne 201 ]; then
    
    echo "Unable to create remote repo."
    exit 5
fi

git push -u origin master
