# m68K-AmigaOS-cross-compiler-setup-script
Easy Cross Compiler Setup On Ubuntu 16.04 LTS (may be other debian based distrubition) to compile your Amiga OS 3.X C project. This shell script uses whiptail to setup amigaos-cross-toolchain [https://github.com/cahirwpz/amigaos-cross-toolchain] <br><br>

Special Thanks to: <br>
@Alpyre [https://github.com/alpyre]<br>
@Simon [https://github.com/ozayturay] <br>
from www.commodore.gen.tr

# Usage
~~~~ bash
chmod +x m68k-amigaos-gcc-setup
sudo ./m68k-amigaos-gcc-setup
~~~~

# Compile MUI Project
Do not forget add lines your source code to compile MUI project for Amiga OS 3.X with MUI3.8
~~~~ c
/* Otherwise auto open will try version 37, and muimaster.library has version
 * 19.x for MUI 3.8 */
int __oslibversion = 0;

/* We don't use command line arguments. */
int __nocommandline = 1;
~~~~
