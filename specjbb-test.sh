#!/bin/bash

function multi_jvm_1 {
	java -jar specjbb2015.jar -m multicontroller
	java -jar specjbb2015.jar -m txinjector -G GRP1 -J JVM1
	java -jar specjbb2015.jar -m backend -G GRP1 -J JVM2
}

function multi_jvm_4 {
	java -jar specjbb2015.jar -m multicontroller

	java -jar specjbb2015.jar -m txinjector -G GRP1 -J txiJVM1
	java -jar specjbb2015.jar -m txinjector -G GRP1 -J txiJVM2
	java -jar specjbb2015.jar -m backend -G GRP1 -J beJVM

	java -jar specjbb2015.jar -m txinjector -G GRP2 -J txiJVM1
	java -jar specjbb2015.jar -m txinjector -G GRP2 -J txiJVM2
	java -jar specjbb2015.jar -m backend -G GRP2 -J beJVM

	java -jar specjbb2015.jar -m txinjector -G GRP3 -J txiJVM1
	java -jar specjbb2015.jar -m txinjector -G GRP3 -J txiJVM2
	java -jar specjbb2015.jar -m backend -G GRP3 -J beJVM

	java -jar specjbb2015.jar -m txinjector -G GRP4 -J txiJVM1
	java -jar specjbb2015.jar -m txinjector -G GRP4 -J txiJVM2
	java -jar specjbb2015.jar -m backend -G GRP4 -J beJVM
}

multi_jvm_1
