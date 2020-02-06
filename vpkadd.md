% VPK_ADD(1)

# NAME

**vpk_add** - install, update and version control software packages

# SYNOPSIS

**vpk_add** [**-u**] [**-c** *commit-id*] [*pkg-name* ...]

# DESCRIPTION

The **vpkadd** command is used to install or update packages.

**vpkadd** can be used to

* Install new packages. This is the normal mode. The  *package-name* ... specified on the command line are new package names to install.
* Update installed packages, using option **-u**.
* Rolling back to a previous state of installed packages, using option **-c**. The *commit-id* specified on the command line is the commit ID to roll back to.

# FILES

*/var/cache/vpk:* git repository of installed packages

# SEE ALSO

vpkrm(1)

# AUTHORS

Cristian Ariza: Initial work