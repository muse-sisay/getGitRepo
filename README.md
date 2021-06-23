<sub>*I don't understand why you would use this instead of https://cli.github.com/manual/*</sub>

# Git-init 

<p align="center"> <strong>gitinit</strong> is a bash script for creating an empty repo and pushing an intial commit to github.</p>

## Feature

- create private repository
- save license file
- configure git config on repository basis
- password-less operation

[Installation](#installation) | [Setup](#setup) | [Usage](#usage)

## Installation 

Setting gitinit is as simple cloning the repo, saving your SSH key on github, generating "Personal Access Token" and running the script.  

Install jq, cli json parser
```sh
$ sudo apt instal jq
```

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
$ ssh-keygen -f github-muse-sisay
```

Follow the [Github guide](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) to add your public key to your github account.

### Edit ssh config

Add this to your `~/.ssh/config`. Replace IdentityFile with the one you created. This will allow you to push commits with out providing a password. `Host` directive should be github- plus your username `github-{username}`.

```text
Host github-muse-sisay
    Hostname github.com
    IdentityFile ~/.ssh/github-muse-sisay
    IdentitiesOnly yes
    Port 22
```

### Get Personal Access Token

You can get a "personal access token in GitHub" by going to `Settings->Developer Settings-> Personal Access Tokens->Generate new token`. (select repo scope, or it won't work). # Edit this

#### Save Access Token

Create `ghAccessToken` in `~/.ssh` and place your access token inside `ghAccessToken`. Change permission to 600 so that only your user account has read and write access.  

```sh
$ cd ~/.ssh
$ touch ghAccessToken
$ chmod 600 ghAccessToken
```

## Usage


```sh 
$ gitinit -l mit sampleRepo
```
This will create a `sampleRepo` with `MIT` License on Github.


```sh
$ gitinit -l gpl-3.0 -u abebe workRepo
```

Will create `workRepo` with `gpl-3.0` License on `abebe's` Github. If you haven't setup an ssh key-pair and made an edit to ~/.ssh/config .... go ahead folllow [setup](#setup) do it. The Hostname directive in this case would be github-abebe.

```sh
$ cd ~/.ssh
$ ssh-keygen -f github-abebe
```

```text
Host github-abebe
    Hostname github.com
    IdentityFile ~/.ssh/github-abebe
    IdentitiesOnly yes
    Port 22
```

## TODO 
- [x] Securely store Access Token (hopefully it's secure)
