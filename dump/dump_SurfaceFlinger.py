#!/usr/bin/env python

#
# Author yuxiang
#

import subprocess
import sys
import optparse
import time
import os

def parse_options(argv):
    """Parses and checks the command-line options."""

    usage = 'Usage: python %prog [options] or --[options]'
    desc = 'Example: python %prog -n 15 -o dump_sf_20170305120255'

    parser = optparse.OptionParser(usage=usage, description=desc)
    parser.add_option('-o', dest='output_file', help='write dump output to FILE',
                    default=None, metavar='FILE')

    parser.add_option('-n', dest='dump_count', type='int',
                    help='dump SurfaceFlinger for N times', metavar='N')

    parser.add_option('--list', action="store_false", dest='dump_SF_list',
                    help='dumpsys SurfaceFlinger --list')

    parser.add_option('--dispsync', action="store_false", dest='dump_SF_dispsync',
                    help='dumpsys SurfaceFlinger --dispsync')

    parser.add_option('--static-screen', action="store_false", dest='dump_SF_static_screen',
                    help='dumpsys SurfaceFlinger --static-screen')

    parser.add_option('--fences', action="store_false", dest='dump_SF_fences',
                    help='dumpsys SurfaceFlinger --fences')

    options, categories = parser.parse_args(argv[1:])

    if options.dump_SF_list is not None:
        dump_sf('--list')
        os._exit(0)

    if options.dump_SF_dispsync is not None:
        dump_sf('--dispsync')
        os._exit(0)

    if options.dump_SF_static_screen is not None:
        dump_sf('--static-screen')
        os._exit(0)

    if options.dump_SF_fences is not None:
        dump_sf('--fences')
        os._exit(0)

    if options.output_file is None:
        options.output_file = 'dump_sf_' + time.strftime('%Y%m%d%H%M%S')

    if options.dump_count is None:
        options.dump_count = 1

    if options.dump_count and options.dump_count <= 0:
        parser.error('the dump count must be a non-negative number')

    return (options, categories)

def dump_sf(args):
    out = subprocess.check_output(
        ['adb', 'shell', 'dumpsys', 'SurfaceFlinger', args], stderr=subprocess.STDOUT)
    print out
    return  out

def start_dump(N):
    print 'start_dump'
    print N
    out = time.strftime('%Y%m%d%H%M%S') + "\n"
    for n in range(0, N):
        out += "\n------      " + str(n+1) + "      ------\n"
        out += dump_sf("")
    # print out
    return out


def stop_dump(output, data):
    print 'stop_dump'
    # print output
    # print data
    fo = open(output, "wb")
    fo.write(data)
    fo.close()


def main():
    # print "adb shell dumpsys SurfaceFlinger"
    options, categories = parse_options(sys.argv)
    print options
    print categories
    out = start_dump(options.dump_count)
    print('    dump completed. Collecting output...')
    stop_dump(options.output_file, out)

main()
