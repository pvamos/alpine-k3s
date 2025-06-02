#!/bin/sh
awk '
  BEGIN { skip = 0 }
  /- name: CSI_SNAPSHOTTER_REPLICA_COUNT/ {
    print
    skip = 1
    next
  }
  skip == 1 && /^[[:space:]]*value: "2"/ {
    print
    print "          - name: CSI_NODE_SELECTOR"
    print "            value: \"{\\\"node-role.kubernetes.io/control-plane\\\":\\\"true\\\"}\""
    skip = 0
    next
  }
  { print }
'
