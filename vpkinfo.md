% info(1)

# NAME

**info** - install, update and version control software packages

# SYNOPSIS

**info** [**-u**] [**-c** *commit-id*] [*pkg-name* ...]

# DESCRIPTION

The **info** command is used to install or update packages.

**info** can be used to

* Install new packages. This is the normal mode. The  *package-name* ... specified on the command line are new package names to install.
* Update installed packages, using option **-u**.
* Rolling back to a previous state of installed packages, using option **-c**. The *commit-id* specified on the command line is the commit ID to roll back to.

# PATHS

*/var/cache/vpk:* git repository of installed packages

# SEE ALSO

vpkrm(1)

# AUTHORS

Cristian Ariza: Initial work
