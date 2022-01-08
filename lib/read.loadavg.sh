#!/usr/bin/env bash

read.loadavg() {
  jq -cR 'split(" ") | .[0:4] | .[0] = (.[0]|tonumber) | .[1] = (.[1]|tonumber) | .[2] = (.[2]|tonumber)' /proc/loadavg
}
