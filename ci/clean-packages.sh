#!/usr/bin/env bash
if command -v yum >/dev/null; then
  sudo yum erase cfbuild*
  sudo yum erase cfengine*
fi
if command -v apt >/dev/null; then
  sudo apt remove cfbuild*
  sudo apt remove cfengine*
fi
