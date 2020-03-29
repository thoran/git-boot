# git-boot

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

### 3. With remote specified, via Github API, and with an existing access specified by name with the token being stored in a file in ~/.config/github/<token_note>.token
```shell
$ cd <repo_name>
$ git boot github.com/<username>/<repo_name> --token_note <token_note>
```

### 4. With remote specified, via Github API, and with at least one existing access token stored in a file in ~/.config/github/ with the first one being chosen as the default
```shell
$ cd <repo_name>
$ git boot github.com/<username>/<repo_name>
```

### 5. With remote specified, via Github API, and with an existing access token supplied as a switch
```shell
$ cd <repo_name>
$ git boot github.com/<username>/<repo_name> --access_token <access_token>
```

# 6. With remote specified, via Github API, either without an existing stored or supplied token, or wanting to set up another one with a random access token note name
```shell
$ cd <repo_name>
$ git boot <username>:<password>@github.com/<username>/<repo_name> --otp <otp>

```

## Contributing

1. Fork it: `https://github.com/thoran/git-boot/fork`
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Create a new pull request
