#!/bin/bash

###############################################################################
## Sample script for running SPECjbb2015 in Composite mode.
## 
## This sample script demonstrates launching the Controller, TxInjector and 
## Backend in a single JVM.
###############################################################################

# Launch command: java [options] -jar specjbb2015.jar [argument] [value] ...
#WORKERS=4
WORKERS=$1
# Benchmark options (-Dproperty=value to override the default and property file value)
# Please add -Dspecjbb.controller.host=$CTRL_IP (this host IP) and -Dspecjbb.time.server=true
# when launching Composite mode in virtual environment with Time Server located on the native host.
SPEC_OPTS="-Dspecjbb.forkjoin.workers=$WORKERS"

# Java options for Composite JVM
#JAVA_OPTS="-addmods ALL-SYSTEM"

# Optional arguments for the Composite mode (-l <num>, -p <file>, -skipReport, etc.)
MODE_ARGS=""

# Number of successive runs
NUM_OF_RUNS=1

. ./spec-opts.env

. ./java-opts.env

###############################################################################
# This benchmark requires a JDK7 compliant Java VM.  If such a JVM is not on
# your path already you must set the JAVA environment variable to point to
# where the 'java' executable can be found.
###############################################################################

JAVA=java

TASKSET="taskset -c 0-95,128-223"

which $JAVA > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "ERROR: Could not find a 'java' executable. Please set the JAVA environment variable or update the PATH."
    exit 1
fi

for ((n=1; $n<=$NUM_OF_RUNS; n=$n+1)); do

  # Create result directory                
  timestamp=$(date '+%y-%m-%d_%H%M%S')
  result=./$timestamp
  mkdir $result

  # Copy current config to the result directory
  cp -r config $result

  java -version > $result/jdk-version.log

  cd $result

  echo "Run $n: $timestamp"
  echo "Launching SPECjbb2015 in Composite mode..."
  echo

  echo "Start Composite JVM"
  $TASKSET $JAVA $JAVA_OPTS $SPEC_OPTS -jar ../specjbb2015.jar -m COMPOSITE $MODE_ARGS 2>composite.log > composite.out &

    COMPOSITE_PID=$!
    echo "Composite JVM PID = $COMPOSITE_PID"

  sleep 3

  echo
  echo "SPECjbb2015 is running..."
  echo "Please monitor $result/controller.out for progress"

  wait $COMPOSITE_PID
  echo
  echo "Composite JVM has stopped"

  echo "SPECjbb2015 has finished"
  echo

 cd ..

done

exit 0
