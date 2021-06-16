<sub>*I don't understand why you would use this instead of https://cli.github.com/manual/*</sub>

# Git-init 

<p align="center"> <strong>gitinit</strong> is a bash script for creating an empty repo and pushing an intial commit to github.</p>

[Installation](#installation) | [Setup](#setup) | [Usage](#usage)

## Installation 

Clone the repo to your local machine 
```sh
$ git clone https://github.com/muse-sisay/getGitRepo.git 
```

create an alias (in `~/.bashrc` if you are using BASH)
```bash
alias gitinit="bash /path/to/script/script.sh
```

## Setup

### Generate SSH key 

replace `muse-sisay` with your Github username. Only used for identification purpose. 

```sh
$ cd ~/.ssh
$ ssh-keygen -f github-musesisay
```

[Github guide](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

### Edit ssh config

Add this to your `~/.ssh/config`. Replace IdentityFile with the one you created. This will allow you to push commits with out providing a password.

```text
Host github.com
    IdentityFile ~/.ssh/github-musesisay
    IdentitiesOnly yes
    Port 22
```

### Get Personal Access Token

You can get a "personal access token in GitHub" by going to `Settings->Developer Settings-> Personal Access Tokens->Generate new token`. (select repo scope, or it won't work). # Edit this

Save your Access Token!!

## Usage

```sh 
$ gitinit -t token -u muse-sisay -r sampleRepo
```

This will create a `sampleRepo` repository on github.

## TODO 
- [ ] Securely store Access Token

## Disclaimer 
**Your Access Token with appear in your shell history!**