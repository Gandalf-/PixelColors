#!/bin/bash

# Author: leaf@anardil.net
# colors.sh

source colors.list

shutdown() {
  : ' none -> IO
  reset the light bar when shutting down
  '
  echo -n "Shutting down... "
  echo "4 00 00 00" > led_rgb
  sleep 1
  echo run  > sequence
  echo 255 > brightness
  echo "Done"
  exit
}

startup() {
  : ' none -> IO
  reset the light bar when shutting down
  '
  trap shutdown INT
  cd /sys/devices/platform/cros_ec_lpc.0/cros-ec-dev.0/chromeos/cros_ec/lightbar
  echo stop > sequence
  echo "4 00 00 00" > led_rgb
}

random3() {
  : ' none -> string
  generate a random color using three random RGB values
  '
  a="$(echo $RANDOM % 200 + 1 | bc)"
  b="$(echo $RANDOM % 254 + 1 | bc)"
  c="$(echo $RANDOM % 254 + 1 | bc)"
  echo "$a" "$b" "$c"
}

lrandom3() {
  : ' none -> string
  pull a random color from the full list of colors in colors.list
  '
  echo "${all_colors[$RANDOM % ${#all_colors[@]} ]}"
}

lbrandom3() {
  : ' none -> string
  pull a random color from the smaller list of basic colors in colors.list
  '
  echo "${basic_colors[$RANDOM % ${#basic_colors[@]} ]}"
}

do_pulse_random() {
  : ' optional string -> IO
  pulse 4 random colors by increasing and decreasing the brightness. spend less
  time with low brightness and more time with high brightness because it looks
  nicer
  '
  while true; do

    if test "$1" == "" || test "$1" == "basic"; then
      a=$(lbrandom3); b=$(lbrandom3); c=$(lbrandom3); d=$(lbrandom3)
    else
      a=$(lrandom3); b=$(lrandom3); c=$(lrandom3); d=$(lrandom3)
    fi

    echo "0 $a 1 $b 2 $c 3 $d" >> led_rgb

    for i in {10..100..10}; do
      echo "$i" >> brightness
      sleep 0.05
    done

    for i in {100..255..5}; do
      echo "$i" >> brightness
      sleep 0.05
    done
    
    sleep 0.3

    for i in {255..100..5}; do
      echo "$i" >> brightness
      sleep 0.05
    done

    for i in {100..10..10}; do
      echo "$i" >> brightness
      sleep 0.05
    done
  done
}

do_random_sequence() {
  : ' none -> IO
  occilates through 4 random colors
  '
  a=$(random3); b=$(random3); c=$(random3); d=$(random3)
  while true; do
    echo "0 $a 1 $b 2 $c 3 $d" >> led_rgb
    sleep 0.2
    a=$b; b=$c; c=$d; d=$(random3)
  done
}

startup

do_pulse_random

shutdown
