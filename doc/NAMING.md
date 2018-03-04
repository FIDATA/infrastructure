Artifact Naming Guidelines
--------------------------

The following artifacts are named with version:
*	AMIs
*	VirtualBox VMs
*	VirtualBox images (files)
*	Vagrant box files
*	Packer output directories for VirtualBox builders

The following artifacts are named without version:
*	Vagrant boxes

The following artifacts are named with version and timestamp:
*	Packer manifests

Each obtainment of artifact is made with explicit version:
*	AMIs - with version tag
*	VagrantBox images - with version specified
	in names of directory and file
*	Vagrant boxes - with built-in version property

Use of `most_recent` filter is prohibited.

Labels in names are named according to Semantic Versioning
with the following interpretations and deviations:

1.	Environment name is considered as the part of the name. It is
separated from the base name with hyphen `-` and precedes a version.

2.	Architecture and builder (provider, format) are considered as build
metadata.

3.	If timestamp is present it is appended in the end with hyphen `-`
separator.

4.	In the names of the following artifacts plus `+` separator is
replaced with low line (ground) `_`:

	*	VirtualBox VMs
	*	VirtualBox images
	*	AMIs
	*	Vagrant box files
	*	Vagrant boxes

5.	The version can contain pre-release label as usual.


------------------------------------------------------------------------
Copyright © 2018  Basil Peace

This is part of FIDATA Infrastructure.

Copying and distribution of this file, with or without modification,
are permitted in any medium without royalty provided the copyright
notice and this notice are preserved.  This file is offered as-is,
without any warranty.
