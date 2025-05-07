#!/bin/sh

find . -iname "*.rst" -exec sed -i -f utils/contents.sed {} \;
find . -iname "*.rst" -exec sed -i -f utils/tabs.sed {} \;
find . -iname "*.rst" -exec sed -i -f utils/ident.sed {} \;
