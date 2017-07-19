#!/usr/bin/env python
# -*- coding:utf-8 -*-

from collections import Counter

# 统计总汉字数，文本均以utf-8格式保存
TotalChar = [x for x in open("./123", "r").read() if 19968 <= ord(x) <= 40869]
# 统计不同汉字的重复次数
CountChar = Counter(TotalChar)

print("总汉字数：", len((TotalChar)))
print("不同汉字数：", len((CountChar)))
print(CountChar)
