#######################################################################
# Dockerfile to build a Jenkins CI container image
# Based on Ubuntu
#######################################################################

# Set the base image to Ubuntu
FROM ubuntu
# File Author / Maintainer
MAINTAINER VitorMM <vitor251093@gmail.com>

# Thanks to mitchwongho, which created the base for that Dockerfile
# https://github.com/mitchwongho/docker-jenkins-android

# Installing Oracle Java 8 SDK
RUN apt-get update
ENV DEBIAN_FRONTEND noninteractive
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | /usr/bin/debconf-set-selections
RUN echo "debconf shared/accepted-oracle-license-v1-1 seen true" | /usr/bin/debconf-set-selections

RUN apt-get update
RUN apt-get install unzip wget tmux build-essential software-properties-common python-software-properties -y

RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update
RUN apt-get install oracle-java8-installer -y
RUN apt-get install oracle-java8-set-default -y
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV PATH $JAVA_HOME/bin:$PATH



# Add Android SDK
RUN apt-get update
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install wget tmux build-essential software-properties-common python-software-properties -y

RUN mkdir /opt/android
RUN mkdir /opt/android/android-sdk-linux
RUN wget --progress=dot:giga https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip
RUN unzip -o sdk-tools-linux-3859397.zip -d /opt/android/android-sdk-linux
ENV ANDROID_HOME /opt/android/android-sdk-linux
ENV PATH $ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH
RUN chmod -R 744 $ANDROID_HOME

VOLUME ["/opt/android/android-sdk-linux"]





RUN wget --progress=dot:giga https://services.gradle.org/distributions/gradle-2.14.1-bin.zip
RUN unzip gradle-2.14.1-bin.zip -d /opt/gradle
ENV GRADLE_HOME /opt/gradle/gradle-2.14.1
ENV PATH $GRADLE_HOME/bin:$PATH




# Add git
RUN apt-get install -y git-core

# Add Jenkins
# Thanks to orchardup/jenkins Dockerfile
RUN wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
RUN echo "deb http://pkg.jenkins-ci.org/debian-stable binary/" >> /etc/apt/sources.list
RUN apt-get update
# HACK: https://issues.jenkins-ci.org/browse/JENKINS-20407
RUN mkdir /var/run/jenkins
RUN mkdir /opt/data
RUN apt-get install -y jenkins
RUN service jenkins stop
EXPOSE 8080 48429
VOLUME ["/var/lib/jenkins"]
USER jenkins
ENTRYPOINT [ "java","-jar","/usr/share/jenkins/jenkins.war" ]
## END



# Installing dependencies
## Bug fix to the accept license bug
## Reference: https://stackoverflow.com/questions/38096225/automatically-accept-all-sdk-licences/38381577#38381577
RUN mkdir -p $ANDROID_HOME/licenses/
RUN /bin/sh -c "echo -e \"\n8933bad161af4178b1185d1a37fbf41ea5269c55\" > $ANDROID_HOME/licenses/android-sdk-license"
RUN /bin/sh -c "echo -e \"\n84831b9409646a918e30573bab4c9c91346d8abd\" > $ANDROID_HOME/licenses/android-sdk-preview-license"

## Dependencies installation
RUN $ANDROID_HOME/tools/bin/sdkmanager "tools"
RUN $ANDROID_HOME/tools/bin/sdkmanager "emulator"
RUN $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-23"
RUN $ANDROID_HOME/tools/bin/sdkmanager "platform-tools"
RUN $ANDROID_HOME/tools/bin/sdkmanager "build-tools;23.0.3"
RUN $ANDROID_HOME/tools/bin/sdkmanager "build-tools;25.0.3"
RUN $ANDROID_HOME/tools/bin/sdkmanager "system-images;android-23;default;x86_64"
RUN $ANDROID_HOME/tools/bin/sdkmanager "system-images;android-23;google_apis;armeabi-v7a"
RUN $ANDROID_HOME/tools/bin/sdkmanager "system-images;android-23;google_apis;x86"
RUN $ANDROID_HOME/tools/bin/sdkmanager "system-images;android-23;google_apis;x86_64"



# Creating AVD
RUN $ANDROID_HOME/tools/bin/avdmanager create avd -n Nexus5_API23 -k "system-images;android-23;google_apis;x86" --tag "google_apis" --device "Nexus 5"
