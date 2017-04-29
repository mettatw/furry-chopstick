# furry-chopstick

[![Build Status](https://travis-ci.org/mettatw/furry-chopstick.svg?branch=master)](https://travis-ci.org/mettatw/furry-chopstick)
[![Release](https://img.shields.io/github/release/mettatw/furry-chopstick.svg)](https://github.com/mettatw/furry-chopstick/releases/latest)
[![Issues](https://img.shields.io/github/issues-raw/mettatw/furry-chopstick.svg)](https://github.com/mettatw/furry-chopstick/issues)

A pretty weird, inefficient and inconvenient code-generation helper based on Template Toolkit and perl, with main focus on shell scripts. Define a custom annotation, translate it into Template Toolkit template, then use that template to generate code.

## Installation

### From git repository

```sh
git clone https://github.com/mettatw/furry-chopstick.git
cd furry-chopstick
git submodule update --init --recursive
```

Currently, unless you want to run the test suite, you can ignore `cpanfile`.

## Basic Usage

## Built-in Modules

## Trivia

- The original intention of this project is to generate some installation scripts for my linux box. Thus the choice of perl and git-cloneable template library, in order to make it work on most linux distros out-of-box.
- This project is originally refactored out from another project called "furry-spoon", hence its name. Furry-spoon is abandoned.

## See Also

- [Documentation of Template Toolkit](http://tt2.org/docs/)

## License

This is free software; you can redistribute it and/or modify it under
the the terms of the Apache license 2.0. See `LICENSE` for details.
