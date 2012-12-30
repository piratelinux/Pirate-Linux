#!/bin/bash

cd i2p-0.9.2
rm apps/jrobin/jrobin-1.5.9.1.jar
rm apps/systray/java/lib/systray4j.jar
rm apps/systray/java/lib/systray4j.dll
rm apps/systray/java/resources/iggy.ico
rm core/c/jcpuid/msvc/jcpuid.suo
rm debian/libjbigi-jni.install
rm installer/lib/launch4j/bin/ld
rm installer/lib/launch4j/bin/ld.exe
rm installer/lib/launch4j/bin/windres
rm installer/lib/launch4j/bin/windres.exe
cd installer
find -name '*.so' | xargs rm
find -name '*.exe' | xargs rm
find -name '*.jar' | xargs rm
find -name '*.dll' | xargs rm
find -name '*.jnilib' | xargs rm
find -name '*.jfrm' | xargs rm
find -name '*.a' | xargs rm
find -name '*.o' | xargs rm
find -name 'i2psvc' | xargs rm
find -name 'i2psvc-macosx*' | xargs rm
rm lib/launch4j/demo/SimpleApp/l4j/splash.bmp
rm lib/launch4j/demo/SimpleApp/l4j/SimpleApp.ico
rm lib/launch4j/demo/ConsoleApp/l4j/ConsoleApp.ico
rm lib/launch4j/launch4j.jfpr
rm -r apps/systray
