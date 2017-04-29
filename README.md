# furry-chopstick

[![Build Status](https://travis-ci.org/mettatw/furry-chopstick.svg?branch=master)](https://travis-ci.org/mettatw/furry-chopstick)

A pretty weird and inconvenient code-generation helper based on Template Toolkit and perl. Define a custom annotation, translate it into Template Toolkit template, then use that template to generate code.

## Installation

### From git repository

```sh
git clone https://github.com/mettatw/furry-chopstick.git
cd furry-chopstick
git submodule update --init --recursive
```

Currently, unless you want to run the test suite, you can ignore `cpanfile`. This may change later...

## Basic Usage

## Built-in Modules

## Trivia

- The original intention of this library is to generate some installation scripts for my linux box. Thus the choice of perl and git-cloneable template library, in order to make it work on most linux distros out-of-box.

## See Also

- [Documentation of Template Toolkit](http://tt2.org/docs/)

## License

This is free software; you can redistribute it and/or modify it under
the the terms of the Apache license 2.0. See `LICENSE` for details.
