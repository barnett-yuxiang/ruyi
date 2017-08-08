#!/usr/bin/env python
# _*_ coding: utf-8 _*_

import sys

expect_fps_v = False
expect_fps_h = False
expect_ui_jank = False

fps_v = [0, 0, 0, 0, 0, 0]
fps_h = [0, 0, 0, 0, 0, 0]
ui_jank = [0, 0, 0, 0, 0, 0]


def extract(line):
    global expect_fps_v
    global expect_fps_h
    global expect_ui_jank
    global fps_h
    global fps_v
    global ui_jank

    if line[0] == ' ':
        pass

    type = line[0:4]
    if type == 'type':
        if int(line[11]) == 1:
            expect_fps_v = True
        if int(line[11]) == 2:
            expect_fps_h = True
        if int(line[11]) == 3:
            expect_ui_jank = True

    if expect_fps_v:
        index = line[0:4]
        if index == 'dist':
            data = line[11:].strip('\n').split(',')
            print data
            for item in data:
                if item == '':
                    break
                if item[0] == 's':
                    key = int(item[1])
                    value = int(item[3:])
                    fps_v[key] += int(value)
                else:
                    break

            expect_fps_v = False
            expect_fps_h = False
            expect_ui_jank = False

    if expect_fps_h:
        index = line[0:4]
        if index == 'dist':
            data = line[11:].strip('\n').split(',')
            print data
            for item in data:
                if item == '':
                    break
                if item[0] == 's':
                    key = int(item[1])
                    value = int(item[3:])
                    fps_h[key] += int(value)
                else:
                    break

            expect_fps_v = False
            expect_fps_h = False
            expect_ui_jank = False

    if expect_ui_jank:
        index = line[0:4]
        if index == 'dist':
            data = line[11:].strip('\n').split(',')
            print data
            for item in data:
                if item == '':
                    break
                if item[0] == 's':
                    key = int(item[1])
                    value = int(item[3:])
                    ui_jank[key] += int(value)
                else:
                    break

            expect_fps_v = False
            expect_fps_h = False
            expect_ui_jank = False


def show():
    print fps_v
    print fps_h
    print ui_jank
    print '\n'


def showFpsV():
    denominator = fps_v[0] + fps_v[1] + fps_v[2] + fps_v[3] + fps_v[4] + fps_v[5]
    if denominator == 0:
        print '0'
        return
    print 'FPS V Distribution: ' + str(100 * (fps_v[4] + fps_v[5]) / denominator) + "%"


def showFpsH():
    denominator = fps_h[0] + fps_h[1] + fps_h[2] + fps_h[3] + fps_h[4] + fps_h[5]
    if denominator == 0:
        print '0'
        return
    print 'FPS H Distribution: ' + str(100 * (fps_h[4] + fps_h[5]) / denominator) + "%"


def showUiJank():
    denominator = ui_jank[0] + ui_jank[1] + ui_jank[2] + ui_jank[3] + ui_jank[4] + ui_jank[5]
    if denominator == 0:
        print '0'
        return
    print 'UI Jank Rate: ' + str(100 * (ui_jank[4] + ui_jank[5]) / denominator) + "%"


def main():
    f = open(sys.argv[1], 'r')
    for line in f.readlines():
        extract(line)
    f.close()
    show()
    showFpsV()
    showFpsH()
    showUiJank()


if __name__ == '__main__':
    main()
