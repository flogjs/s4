#!/bin/bash

set -x

if [ ! -d test262 ]; then
    git clone https://github.com/tc39/test262.git test262
fi

touch test262-errors.txt
./zig-out/bin/test262-runner -m -c test262.conf -a
