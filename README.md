# weston-docker

Note: validated on Ubuntu 16.04

# Setup and build docker

1) clone the source
2) Set proxy and update id_rsa
3) sudo docker build -t "weston2" .

# Run weston on docker build

1) Switch to VT console on the host (C-M_F{x})
2) cd to the clone and run test.sh
this will run weston


Issues:
Switching the tty after Weston launch is resulting in black screen and needs a restart of host
