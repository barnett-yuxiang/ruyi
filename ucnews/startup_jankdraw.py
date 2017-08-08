#!/usr/bin/env python2

from sys import argv
import re
from matplotlib import pyplot as plt
import numpy as np
import pylab as pl
import string
import textwrap

g_arrayOfTimeStamp = []
g_arrayOfConsumeRealTime = []
g_arrayOfConsumeCPUTime = []
g_arrayOfMessageID = []
g_arrayOfTarget = []
g_arrayOfCallback = []


def parse(log):
    timestamp = log[6:18]
    g_arrayOfTimeStamp.append(str(timestamp))

    consumeRealTime = ((re.findall("ConsumeRealTime=[0-9]*", log))[0])[16:]
    g_arrayOfConsumeRealTime.append(int(consumeRealTime))

    consumeCPUTime = ((re.findall("ConsumeCPUTime=[0-9]*", log))[0])[15:]
    g_arrayOfConsumeCPUTime.append(int(consumeCPUTime))

    messageID = ((re.findall("MsgID=[0-9]*", log))[0]).strip()
    g_arrayOfMessageID.append(str(messageID))

    target = (re.findall("Target=(.*?),", log)[0]).strip()
    g_arrayOfTarget.append(str(target))

    callback = (re.findall("Callback=(.*?),", log)[0]).strip()
    g_arrayOfCallback.append(str(callback))


def showSimpleResult():
    # print g_arrayOfTimeStamp
    # print g_arrayOfConsumeRealTime
    # print g_arrayOfConsumeCPUTime

    # print len(g_arrayOfTimeStamp)
    # print len(g_arrayOfConsumeRealTime)
    # print len(g_arrayOfConsumeCPUTime)
    # print len(g_arrayOfMessageID)
    # print len(g_arrayOfTarget)
    # print len(g_arrayOfCallback)

    width = 1
    ind = np.arange(len(g_arrayOfConsumeRealTime))
    plt.bar(ind, g_arrayOfConsumeRealTime, width, color='r')
    # plt.bar(ind + width, g_arrayOfConsumeCPUTime, width, color='y')
    plt.ylabel("UI Message Consume Time(ms)")
    plt.xlabel(argv[2])
    plt.show()


def showOrderResult():
    descOrder = sorted(enumerate(g_arrayOfConsumeRealTime), key=lambda x: x[1], reverse=True)
    # print descOrder
    for index in range(len(g_arrayOfConsumeRealTime)):
        i = descOrder[index][0]
        ConsumeRealTime = 'ConsumeRealTime:' + str(g_arrayOfConsumeRealTime[i])
        messageID = g_arrayOfMessageID[i]
        target = 'Target=' + g_arrayOfTarget[i]
        callback = 'Callback=' + g_arrayOfCallback[i]

        print [ConsumeRealTime.ljust(20), messageID.ljust(15), target.ljust(50), callback.ljust(20)]


if __name__ == '__main__':
    f = open(argv[1])
    for line in f:
        parse(line.strip("\n"))
    f.close()
    showSimpleResult()
    showOrderResult()
