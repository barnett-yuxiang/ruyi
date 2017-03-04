#
#
from distutils.core import setup


setup(
    name='adb',
    version='0.0.1',
    description='A Python interface to the Android Debug Bridge.',
    license='Apache 2.0',
    keywords='adb android',
    package_dir={'adb': ''},
    packages=['adb'],
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: Apache Software License',
    ]
)
