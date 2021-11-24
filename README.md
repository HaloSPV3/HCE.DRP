# DISCORD RICH PRESENCE

This tree contains the DRP (Discord Rich Presence) source code, which
aims to integrate Halo CE and SPV3 with Discord by allowing players to display the
mission & difficulty they're playing on.

The source code has been generously developed and provided by giraffe,
and has been integrated into a custom Visual C++ project for convenient
reproducible builds.

## COMPILING

In Visual Studio, the project MUST be compiled with the following
configuration:

- Type: RELEASE
- Platform: x86

Attempting to compile to any other type or platform will cause issues!

The DLL is compiled to the following paths in the following contexts:

        debug                      release
  ----- -------------------------- ----------------------------
  x86   .\bin\Debug\controls       .\bin\Release\controls
  x64   .\bin\x64\Debug\controls   .\bin\x64\Release\controls

## RESOURCES

The drp/resources directory stores the images used in the Discord Rich
Presence:

| directory    | description
| ------------ | --------------------------------------------
| campaign     | images representing each map
| difficulty   | images representing each singleplayer difficulty

Images have been generously provided by Arecaidian Fox, giraffe, sbdJazz
and the rest of the SPV3 crew.
