#!/bin/bash

upgradable_packages=$(apt list --upgradable 2>/dev/null | tail -n+2 | wc -l)

if [ $upgradable_packages -gt 0 ]; then
	echo "󰇚 $upgradable_packages"
fi

