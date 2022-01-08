#!/usr/bin/env bash

read.uptime() {
  cat /proc/uptime | awk '{print $1}'
}
