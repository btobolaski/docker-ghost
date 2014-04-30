#!/bin/bash
varnishd -f /etc/varnish/default.vcl -S /etc/varnish/secret -F -s malloc,100M -a 0.0.0.0:8080
