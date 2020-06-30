from setuptools import setup

setup(name='unitybuild',
      version='1.2',
      scripts= [
            'bin/unitybuild',
            'bin/resources_workflow',
            ],
      description='unitybuild command line tool',
      url='https://github.com/sric0880/unity-buildscripts',
      author='sric0880',
      author_email='justgotpaid88@qq.com',
      license='MIT',
      packages=['resources_workflow'],
      data_files=[('/usr/local/unitybuild-tool', ['bin/apktool.jar', 'bin/bundletool-all-1.0.0.jar', 'bin/Resources.proto', 'bin/Configuration.proto'])],
      zip_safe=False)