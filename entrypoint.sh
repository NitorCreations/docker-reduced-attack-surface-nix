#!/bin/sh
echo "Hello as root from entrypoint!"
exec "$@"