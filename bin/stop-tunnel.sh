#!/bin/bash 

source $OPENSHIFT_CARTRIDGE_SDK_BASH

pid=`ps -C ssh -o pid --no-headers`
client_result "stop tunnel using PID $pid  "

kill `ps -C ssh -o pid --no-headers`

