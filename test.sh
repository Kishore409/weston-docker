#! /bin/bash

tty | grep -q '/dev/tty' || {
  echo "ERROR: Must run from tty/console" >&2
  exit 1
}

[ -z "$XDG_SEAT" ] && echo "WARNING: XDG_SEAT is empty" >&2 && seat=seat0 || seat=$XDG_SEAT
[ -e "/run/systemd/seats/$seat" ] && seat="/run/systemd/seats/$seat" || {
  echo "ERROR: $seat not found" >&2
  exit 1
}

docker run -it --rm --env XDG_RUNTIME_DIR=/tmp \
    --env XDG_VTNR=$XDG_VTNR \
    --device $(tty) --device /dev/dri --device /dev/input \
    --cap-add SYS_TTY_CONFIG --cap-add SYS_ADMIN \
    --volume=/run/udev/data:/run/udev/data:ro \
    --volume $seat:$seat:ro \
    weston2:latest \
    agetty --autologin root --login-options '' --login-program /root/wl-install/bin/weston $(tty | sed 's/dev\///')
