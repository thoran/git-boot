# git-boot/README.md

## Description

Initialize a local and a remote repo in one command.

## Installation

```shell
$ brew tap thoran/tap
$ brew install thoran/tap/git-boot
```

## Usage

### 1. With no remote specified
```shell
$ cd <repo_name>
$ git boot
```

### 2. With remote specified, via ssh
```shell
$ cd <repo_name>
$ git boot <username>:<password>@<hostname>
```

### 3a. With remote specified, via Github API, and an access token specified by name, with the token being stored in encrypted storage
```shell
$ cd <repo_name>
$ git boot github.com/<username>/<repo_name> --token_name <token_name>
```

### 3b. With remote specified, via Github API, and an access token specified by name, with the token being stored in `~/.config/github/<access_token_name>.token` if none can be found in encrypted storage
```shell
$ cd <repo_name>
$ git boot github.com/<username>/<repo_name> --token_name <token_name>
```

### 4a. With remote specified, via Github API, and with an access token specified by name in ~/.config/github/config.rb, with the token being stored in encrypted storage
```shell
$ echo "ACCESS_TOKEN_NAME = 'access_token1'" >> ~/.config/github/config.rb
$ cd <repo_name>
$ git boot github.com/<username>/<repo_name>
```

### 4b. With remote specified, via Github API, and at least one access token stored in a file with a `.token` extension in ~/.config/github/, with the first one being chosen as the default if none can be found in encrypted storage
```shell
$ cd <repo_name>
$ git boot github.com/<username>/<repo_name>
```

### 5. With remote specified, via Github API, and with an existing access token supplied as a switch
```shell
$ cd <repo_name>
$ git boot github.com/<username>/<repo_name> --access_token <access_token>
```

### 6. With remote specified, via Github API, either without an existing stored or supplied token, or wanting to set up another one with a random access token name
```shell
$ cd <repo_name>
$ git boot <username>:<password>@github.com/<username>/<repo_name> --otp
```

### Github access token sources
1. Supplied via command line switch (--access_token)
2. Read from a custom encrypted password store (ApiCredentials, --token_name optional)
3. Read, unencrypted, from the filesystem (`~/.config/github/*.token`, --token_name optional)
4. Created on-the-fly via one-time token with a username and password supplied on the command line

## Contributing

1. Fork it: `https://github.com/thoran/git-boot/fork`
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Create a new pull request
