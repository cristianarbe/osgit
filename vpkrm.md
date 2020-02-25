% vpkrm(1)

# NAME

**vpkrm** - ununinstall and version control software packages

# SYNOPSIS

**vpkrm** [**-u**] [**-c** *commit-id*] [*package* ...]

# DESCRIPTION

The **vpkrm** command is used to ununinstall packages.

**vpkrm** can be used to

* uninstall new packages. This is the normal mode. The  *package* ... specified on the command line are package names to uninstall.
* Reverting to a previous state of uninstalled packages, using option **-c**. The *commit-id* specified on the command line is the commit ID to revert.

# PATHS

*/var/cache/vpk:* git repository of uninstalled packages

# SEE ALSO

vpkadd(1)

# AUTHORS

Cristian Ariza: Initial work
