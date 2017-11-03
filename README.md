# Codestellation.Nova 

Codestellation.Nova is .NET core projects generator

Generator steps:
* Create empty .net core library project
* Create empty .net core library tests project ([NUnit](http://nunit.org))
* Include [Cake](https://cakebuild.net) build script with [semver](http://semver.org) versioning and nuget packaging
* Initialize git repository

# Installation

```
$ git clone https://github.com/Codestellation/Nova.git
```

# Usage

```
$ cd Nova
$ ./create.ps1
```

# How to contribute

* Use core.autocrlf=True
* Use spaces instead of tabs
* Use [Allman indent style](https://en.wikipedia.org/wiki/Indent_style#Allman_style)