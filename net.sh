#!/bin/bash
interface=$(ip r | grep ^default | cut -d' ' -f5)
echo $interface