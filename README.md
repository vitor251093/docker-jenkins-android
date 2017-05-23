# docker-jenkins-android
A Jenkins CI Docker Container for Android

Running Docker:
```
docker run -d -u=root -p 8080:8080 --name jenkins-ci-android <container-image-name>
```

Running emulator:
```
docker exec <container-id> /opt/android/android-sdk-linux/emulator/emulator64-x86 -engine classic -ports 5772,5773 -report-console tcp:5869,max=60 -avd Nexus5_API23 -no-snapshot-load -no-snapshot-save -no-window -verbose
```

