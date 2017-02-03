if [ $1 -eq 0 ]; then
  /sbin/service spinnaker-example stop >/dev/null 2>&1 || true
fi
