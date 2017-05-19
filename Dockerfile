#######################################################################
# Dockerfile to build a Jenkins CI container image
# Based on Ubuntu
#######################################################################

# Set the base image to Ubuntu
FROM ubuntu:16.10
# File Author / Maintainer
MAINTAINER VitorMM <vitor251093@gmail.com>

# Add Android SDK
RUN apt-get update
ENV DEBIAN_FRONTEND noninteractive
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | /usr/bin/debconf-set-selections
RUN echo "debconf shared/accepted-oracle-license-v1-1 seen true" | /usr/bin/debconf-set-selections

RUN apt-get update
RUN apt-get install wget tmux build-essential software-properties-common python-software-properties -y

RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update
RUN apt-get install oracle-java8-installer -y
RUN apt-get install oracle-java8-set-default -y
ENV JAVA_HOME /usr/bin/java



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



RUN apt-get install -y unzip
ADD https://services.gradle.org/distributions/gradle-2.4-all.zip /opt/
RUN unzip /opt/gradle-2.4-all.zip -d /opt/gradle
ENV GRADLE_HOME /opt/gradle/gradle-2.4-all
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
