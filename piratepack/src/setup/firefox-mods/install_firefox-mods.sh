#!/bin/bash

set -e

maindir="$1"

cp "$maindir"/share/firefox-mods/{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}.xpi .
unzip {d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}.xpi -d {d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}
cp -r {d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}-mods/installer/{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}/* {d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}
cd {d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}
zip -r {d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}.xpi .
rm ../{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}.xpi
rm "$maindir"/share/firefox-mods/{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}.xpi
cp {d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}.xpi "$maindir"/share/firefox-mods/
cd ..
rm -r {d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}
mkdir "$maindir"/share/firefox-mods/{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}-mods
cp -r {d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}-mods/profile "$maindir"/share/firefox-mods/{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}-mods
