#!/usr/bin/env sh
set -i
set -x
asciidoctor README.adoc
exit 0
command -v parallel >/dev/null || brew install parallel
command -v fswatch >/dev/null || brew install fswatch
#command -v asciidoctor >/dev/null || brew install asciidoctor
command -v md2html >/dev/null || brew install md4c
#asciidoctor *.adoc
fswatch *.md | parallel "md2html {} > {}.html"
# then manually refresh in browser window already open
# TODO add bits like hugo to auto-refresh on file change?
# https://github.com/livereload/livereload-js is what hugo uses. so need a server. Make a small one in C! :O
# https://github.com/lepture/python-livereload
#open *.html
