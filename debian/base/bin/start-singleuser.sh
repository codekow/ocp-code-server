#!/bin/bash

dumb-init fixuid -q  \
    code-server --bind-addr 0.0.0.0:8080 . \
    --disable-telemetry \
    --auth=none -vvv
