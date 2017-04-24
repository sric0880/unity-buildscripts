# unity-buildscripts
Unity build command tools for android, ios, windows, macOSX. Support hot-fix by generating resources list and upload to server.

# Install
```sh
sudo pip install .
# or if already installed, run this:
sudo pip install . --upgrade
```

# Usage
```sh
unitybuild -h/--help
# for example:
unitybuild -c android-yyb --git-rev 9f08a67 --version-name 1.0.0 --version-code 2 --unity-project your_unity_project_path -b master --output ./output
```

* Unity project must has `autobuild` folder. Detail see `Dependency` below.
* Resources directory must be the same as unity project. eg.
  ```
  --root
    |--unity-project
        |--Assets
        |--autobuild
        |--...
    |--resources
  ```


# Dependency
* [unity-onesdk](https://github.com/sric0880/unity-onesdk)
* [unity-framework](https://github.com/sric0880/unity-framework)
  * Depends on `Assets/Editor/Build.cs`. Add build target scenes to `Build.cs`.
  * Modify `autobuild/config`.
  * Modify `autobuild/*.yaml`.
    1. `resources-hotfix-server.yaml` for hotfix server.
    2. `resources-local.yaml` for copy files from resources to package.
    3. `resources-update.yaml` for update files from hotfix server to external storage.
  * Add your own signature files to `android` and `ios` folders. Filenames must not be changed:
    1. `android/keystore`
    2. `android/pwd` : keystore password
    3. `ios/embedded.mobileprovision`
    4. `ios/entitlements.plist`


# TODO List
 1. not fully tested.
 2. onesdk for iOS.
 3. number of multi-thread should be limited.
 4. post process
