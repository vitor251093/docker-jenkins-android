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
RUN apt-get install wget tmux build-essential software-properties-common python-software-properties -y
RUN apt-get install unzip -y

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

RUN wget --progress=dot:giga http://dl.google.com/android/android-sdk_r23.0.2-linux.tgz
RUN mkdir /opt/android
RUN tar -C /opt/android -xzvf ./android-sdk_r23.0.2-linux.tgz
ENV ANDROID_HOME /opt/android/android-sdk-linux
ENV PATH $ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH
RUN chmod -R 744 $ANDROID_HOME

VOLUME ["/opt/android/android-sdk-linux"]

RUN wget --progress=dot:giga https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip
RUN unzip -o sdk-tools-linux-3859397.zip -d /opt/android/android-sdk-linux
RUN /opt/android/android-sdk-linux/tools/android update sdk -u




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
RUN /opt/android/android-sdk-linux/tools/bin/sdkmanager "tools"
RUN /opt/android/android-sdk-linux/tools/bin/sdkmanager "emulator"
RUN /opt/android/android-sdk-linux/tools/bin/sdkmanager "platforms;android-23"
RUN /opt/android/android-sdk-linux/tools/bin/sdkmanager "platform-tools"
RUN /opt/android/android-sdk-linux/tools/bin/sdkmanager "build-tools;23.0.3"
RUN /opt/android/android-sdk-linux/tools/bin/sdkmanager "build-tools;25.0.3"
RUN /opt/android/android-sdk-linux/tools/bin/sdkmanager "system-images;android-23;default;x86_64"
RUN /opt/android/android-sdk-linux/tools/bin/sdkmanager "system-images;android-23;google_apis;armeabi-v7a"
RUN /opt/android/android-sdk-linux/tools/bin/sdkmanager "system-images;android-23;google_apis;x86"
RUN /opt/android/android-sdk-linux/tools/bin/sdkmanager "system-images;android-23;google_apis;x86_64"



# Creating AVD
RUN /opt/android/android-sdk-linux/tools/bin/avdmanager create avd -n Nexus5_API23 -k "system-images;android-23;google_apis;x86" --tag "google_apis" --device "Nexus 5"
