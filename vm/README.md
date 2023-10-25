## qemu from make
- vm in any vlan and bridge
```
v=3 make alpine
b=br0 v=5 make alpine
```
- display and audio none unless arcan running
```
d=gtk make dragonflybsd
d=sdl a=alsa make alpines
```
- default snapshot mode, to update
```
u= make ros
```
