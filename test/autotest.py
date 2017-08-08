#!/usr/bin/env python
# _*_ coding: utf-8 _*_

import time
from uiautomator import Device

d = Device('038dfa3225202ab4')


# d.swipe(860, 170, 370, 160, steps=10)
# d.swipe(400, 1400, 280, 400, steps=10)


def main():
    print d.info

    for i in range(1):
        # 1. Click Icon
        time.sleep(20)
        d.click(160, 380)
        time.sleep(20)

        # 2. Five times pull to refrash
        for i in range(5):
            d.swipe(480, 510, 480, 1140, steps=10)
            time.sleep(20)

        d.click(350, 840)
        time.sleep(20)

        d.click(85, 150)
        time.sleep(20)

        # 3. Right Swipe 2 times
        for i in range(2):
            d.swipe(850, 1070, 180, 1070, steps=10)
            time.sleep(20)

        # 4.
        for i in range(10):
            d.swipe(850, 1070, 180, 1070, steps=10)
            time.sleep(0.4)

        # 5.
        for i in range(10):
            d.swipe(180, 1070, 850, 1070, steps=10)
            time.sleep(0.4)

        time.sleep(20)

        # 6.
        for i in range(10):
            d.swipe(480, 1500, 480, 350, steps=10)
            time.sleep(20)

        for i in range(10):
            # 7.
            for i in range(5):
                d.swipe(480, 350, 480, 1500, steps=10)
                time.sleep(0.4)

            # 8.
            for i in range(5):
                d.swipe(480, 1500, 480, 350, steps=10)
                time.sleep(0.4)

        time.sleep(20)
        d.press.home()


if __name__ == '__main__':
    main()
