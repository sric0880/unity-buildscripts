from setuptools import setup

setup(name='unitybuild',
      version='1.1',
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
      data_files=[('/usr/local/unitybuild', [
            'config/resources-hotfix-server.yaml',
            'config/resources-local.yaml',
            'config/resources-update.yaml'
            ]), ('/usr/local/apktool', [
            'bin/apktool.jar'])],
      zip_safe=False)