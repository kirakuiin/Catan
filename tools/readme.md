## How to use it

Workflow is very simple. If you have only one png prepared
run first script in command line like this:

```
godot -s CreateIcon.gd customized.ico customized.png
```

Call it like this when you have six required resolutions:

```
godot -s CreateIcon.gd customized.ico customized1.png customized2.png ...
```

Then use created icon with your exported project:

```
godot -s ReplaceIcon.gd customized.ico MyProject.exe
```

When you provide multiple files to icon creator remember
that they should be in sizes: 16x16, 32x32, 48x48, 64x64,
128x128 and 256x256 pixels.

![Remember that Windows caches icons so you probably need to refresh this cache. Hacky way is to rename the executable after icon replacement.](https://raw.githubusercontent.com/pkowal1982/godoticon/3.x/image/warning.png)

Refreshing icon cache in Windows 10:

```
ie4uinit.exe -show
```

and in other versions:

```
ie4uinit.exe -ClearIconCache