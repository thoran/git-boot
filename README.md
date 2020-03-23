# git-boot

## Description

Initialize a local and a remote repo in one command.

## Installation

```shell
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

### 3. With remote specified, via Github API
```shell
$ cd <repo_name>
$ git boot <username>:<password>@github.com:<username>/<repo_name>
```

### 4. With remote specified, via Github API, using OTP
```shell
$ cd <repo_name>
$ git boot <username>:<password>@github.com:<username>/<repo_name> --otp <otp>

```

## Contributing

1. Fork it: `https://github.com/thoran/git-boot/fork`
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Create a new pull request
