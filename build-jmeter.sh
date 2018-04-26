#!/bin/bash
#export JAVA_HOME=$JAVA8_HOME

function get_web_getter() {
  # get a getter
  if [ \! -z `type -t curl` ]; then
    GET="curl --silent --location --compressed -O"
  elif [ \! -z `type -t wget` ]; then
    GET="wget --quiet"
  else
    ERR "No getter (curl/wget)"
    exit 1
  fi
}

set -e

if [ ! -d "jmeter" ]; then  
  get_web_getter
  $GET http://mirror.klaus-uwe.me/apache//jmeter/binaries/apache-jmeter-4.0.zip
  unzip -q apache-jmeter-4.0.zip
  mv apache-jmeter-4.0 jmeter

  $GET https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/json-simple/json-simple-1.1.1.jar
  mv json-simple-1.1.1.jar  jmeter/lib/ext/json-simple-1.1.1.jar
  cp document/workload/jmeter/lib/acmeair-driver-1.0-SNAPSHOT.jar jmeter/lib/ext/acmeair-driver-1.0-SNAPSHOT.jar
fi