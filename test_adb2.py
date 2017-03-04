#!/usr/bin/env python
#
#

import subprocess

import adb


def main():
    print "test adb2"

    out = subprocess.check_output(
        ['adb', 'help'], stderr=subprocess.STDOUT)
    print out

main()
