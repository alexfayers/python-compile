# python-compile
Quick bash script I wrote to download and compile the latest (or a specific) version of Python on Linux. Useful when the apt repo for your dist doesn't have a super up-to-date version of Python, or you need a specific version for some reason.

Usage:

```sh
compile_python.sh [specific python version]
```

E.g. to install Python 3.9.0:

```sh
compile_python.sh 3.9.0
```

Or to just install the latest version of Python 3:


```sh
compile_python.sh
```
