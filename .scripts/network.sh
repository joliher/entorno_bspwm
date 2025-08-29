#!/bin/bash

IFACE="enp42s0"

if $(ip link show "$IFACE" | grep -q "state UP"); then
	IP=$(ip addr show "$IFACE" | awk '/inet / {print $2}' | cut -d/ -f1)
	echo "$IP"
else
	echo "$IFACE %{F#707880}not connected%{F-}"
fi                     
