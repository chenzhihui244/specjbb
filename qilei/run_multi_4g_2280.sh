#!/bin/bash

###############################################################################
# Sample script for running SPECjbb2015 in MultiJVM mode.
# 
# This sample script demonstrates running the Controller, TxInjector(s) and 
# Backend(s) in separate JVMs on the same server.
###############################################################################

# Launch command: java [options] -jar specjbb2015.jar [argument] [value] ...

# Number of Groups (TxInjectors mapped to Backend) to expect
GROUP_COUNT=4

# Number of TxInjector JVMs to expect in each Group
TI_JVM_COUNT=2

# Benchmark options for Controller / TxInjector JVM / Backend
# Please use -Dproperty=value to override the default and property file value
# Please add -Dspecjbb.controller.host=$CTRL_IP (this host IP) to the benchmark options for the all components
# and -Dspecjbb.time.server=true to the benchmark options for Controller 
# when launching MultiJVM mode in virtual environment with Time Server located on the native host.
SPEC_OPTS_C="-Dspecjbb.group.count=$GROUP_COUNT -Dspecjbb.txi.pergroup.count=$TI_JVM_COUNT"
SPEC_OPTS_TI=""
SPEC_OPTS_BE=""

# Java options for Controller / TxInjector / Backend JVM
JAVA_OPTS_C="-Xmn1536m -Xms2g -Xmx2g -XX:ParallelGCThreads=8"
JAVA_OPTS_TI="-Xms2g -Xmx2g -Xmn1536m  -XX:ParallelGCThreads=8"
JAVA_OPTS_BE="-showversion -server -XX:LargePageSizeInBytes=2m -XX:+AggressiveOpts -XX:-UseAdaptiveSizePolicy -XX:+AlwaysPreTouch -XX:-UseBiasedLocking  -XX:+UseLargePages -XX:+UseParallelOldGC  -Xms25g -Xmx25g -Xmn22g -XX:SurvivorRatio=28 -XX:TargetSurvivorRatio=95 -XX:ParallelGCThreads=16 -XX:MaxTenuringThreshold=5 -XX:+PrintTenuringDistribution -XX:+UseTransparentHugePages -XX:+PrintGCDetails -XX:+PrintGCTimeStamps"

# Optional arguments for multiController / TxInjector / Backend mode 
# For more info please use: java -jar specjbb2015.jar -m <mode> -h
MODE_ARGS_C=""
MODE_ARGS_TI=""
MODE_ARGS_BE=""

# Number of successive runs
NUM_OF_RUNS=1

###############################################################################
# This benchmark requires a JDK7 compliant Java VM.  If such a JVM is not on
# your path already you must set the JAVA environment variable to point to
# where the 'java' executable can be found.
###############################################################################

JAVA=java

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

  cd $result

  echo "Run $n: $timestamp"
  echo "Launching SPECjbb2015 in MultiJVM mode..."
  echo

  echo "Start Controller JVM"
  $JAVA $JAVA_OPTS_C $SPEC_OPTS_C -jar ../specjbb2015.jar -m MULTICONTROLLER $MODE_ARGS_C 2>controller.log > controller.out &

  CTRL_PID=$!
  echo "Controller PID = $CTRL_PID"

  sleep 3

  for ((gnum=1; $gnum<$GROUP_COUNT+1; gnum=$gnum+1)); do

    GROUPID=Group$gnum
    echo -e "\nStarting JVMs from $GROUPID:"

    cpunode=$[$gnum-1]

    for ((jnum=1; $jnum<$TI_JVM_COUNT+1; jnum=$jnum+1)); do

        JVMID=txiJVM$jnum
        TI_NAME=$GROUPID.TxInjector.$JVMID

        echo "    Start $TI_NAME"
        $JAVA $JAVA_OPTS_TI $SPEC_OPTS_TI -jar ../specjbb2015.jar -m TXINJECTOR -G=$GROUPID -J=$JVMID $MODE_ARGS_TI > $TI_NAME.log 2>&1 &
        echo -e "\t$TI_NAME PID = $!"
        sleep 1
    done

    JVMID=beJVM
    BE_NAME=$GROUPID.Backend.$JVMID

    echo "    Start $BE_NAME"
    #cpunode=$[2*($gnum-1)],$[2*($gnum-1)+1]
    numactl --cpunodebind=$cpunode --localalloc $JAVA $JAVA_OPTS_BE $SPEC_OPTS_BE -jar ../specjbb2015.jar -m BACKEND -G=$GROUPID -J=$JVMID $MODE_ARGS_BE > $BE_NAME.log 2>&1 &
    echo -e "\t$BE_NAME PID = $!"
    sleep 1

  done

  echo
  echo "SPECjbb2015 is running..."
  echo "Please monitor $result/controller.out for progress"

  wait $CTRL_PID
  echo
  echo "Controller has stopped"

  echo "SPECjbb2015 has finished"
  echo
  
  cd ..

done

exit 0

