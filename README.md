rose-builder
============

The main `rose.sh` script is a convenience tool to:

* Compile applications with ROSE.
* Manage your application workspaces

Usage
-----

See the usage information for more details:

```bash
$ ./rose.sh help
```


Applications
------------

New applications can be added as a "plugin" simply by creating a new script file
under the `applications` directory.  This file must contain a function named in
the form `compile_<application>`, and be named as `<application>.sh`.

Then, you will be able to compile your application with this simple command:

```bash
$ ./rose.sh compile <application>
```
