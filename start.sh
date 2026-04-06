#!/bin/sh
# Retry loop - Ruby 0.49 APE binary has non-deterministic startup crashes on x86_64
while true; do
  ruby-0.49 app.rb
  echo "sinatra049 crashed (exit $?), restarting..." >&2
  sleep 1
done
