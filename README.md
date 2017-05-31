# docker-jenkins-android
A Jenkins CI Docker Container for Android which uses the `sdkmanager`, `avdmanager` and `emulator` binaries instead of `android` and `emulator`, being compatible with the most recent Android SDK versions.

That Dockerfile is still in development. It still isn't possible to use Jenkins's android-emulator-plugin with QEMU2, and the classic engine doesn't work since Google changed the location of the `emulator` folder. More details in the pages below:

* https://issues.jenkins-ci.org/browse/JENKINS-44490
* https://issues.jenkins-ci.org/browse/JENKINS-43557
* https://issues.jenkins-ci.org/browse/JENKINS-40178

It's still unclear if that Dockerfile works for non-Jenkins tests using the `emulator` binary, but it runs.

In case of 'SDL init failure' check:
* http://hanscappelle.blogspot.com.br/2013/01/jenkins-android-emulator-plugin-problems.html

## Instructions
Download the Dockerfile to a folder of your preference. Run the following command in that folder to build the image:
```
docker build ./
```

In order to run that image has a container, use that command (you can find out the container-image-name without the output of the prior command):
```
docker run --privileged -d -u=root -p 8080:8080 --name jenkins-ci-android <container-image-name>
```

Example of emulator command line:
```
docker exec <container-id> /opt/android/android-sdk-linux/tools/emulator -engine auto -ports 5772,5773 -report-console tcp:5869,max=60 -avd Nexus5_API23 -no-snapshot-load -no-snapshot-save -no-window -verbose
```

