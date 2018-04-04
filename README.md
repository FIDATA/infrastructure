FIDATA Infrastructure
---------------------

This repository contains:
*	Scripts to build immutable servers with Packer & Vagrant & Chef
	*	Kernel images - clean installs without any provisioners
	*	Base images
	*	Jenkins master
	*	Jenkins slaves

	Targets:
	*	Vagrant boxes for VirtualBox - testing environment
	*	Amazon AMIs - production environment

*	Scripts to deploy infrastructure with Terraform

### Prerequisites:
*	Java (JRE or JDK) >= 8
*	VirtualBox (5.2.8)
*	Packer
*	Vagrant and vagrant-cachier plugin
*	Terraform (>= 0.11.7)
*	Ruby & Bundler (~> 1.14, gems locked with 1.16.1)
*	Python 3 & [Pipenv](http://pipenv.org/)

All other build tools (gems, packages, plugins and cookbooks) are
installed by Gradle. You have to do this after repository clone:
```
./gradlew buildToolsInstall
```

When necessary you can check locked versions for updates with:
```
./gradlew buildToolsOutdated
```
and update them with:
```
./gradlew buildToolsUpdate
```

NOTE: Update of gems with exact version constraint (e.g. Chef)
is not supported now (see #67). When you change their versions
you have to update them manually with:
```
bundle update chef
```

### Workflow:

1.	Clean and build kernel VirtualBox images
	```
	./gradlew clean-kernel-*-vbox
	./gradlew build-kernel-*-vbox
	```
	There is a separate task for each image

2.	Deploy common Terraform resources, build base VirtualBox images &
Vagrant boxes
	```
	./gradlew build-base
	```

3.	Test build toolset used for Jenkins slaves:
	```
	./gradlew kitchenTest-BuildToolset
	```

4.	Build Jenkins slave AMIs:
	```
	./gradlew build-JenkinsSlaves
	```

5.	Test Jenkins Master:
	```
	./gradlew kitchenTest-JenkinsMaster-vbox
	./gradlew kitchenTest-JenkinsMaster-amazon
	```

6.	Build JenkinsMaster production AMI:
	```
	./gradlew build-JenkinsMaster
	```

7.	Deploy instances:
	```
	./gradlew deploy
	```

### Making changes:
Check code before pushing:
```
gradlew --continue check
```

### Packer, Vagrant & Chef scripts are based on:
1.	[Bento](https://chef.github.io/bento/)

2.	[Boxcutter](https://github.com/boxcutter)

3.	[joefitzgerald/packer-windows](https://github.com/joefitzgerald/packer-windows)

4.	[innvent/parcelles](https://github.com/innvent/parcelles)

### Credits (Additional reading)
1.	Immutable Servers:
	*	[Kief Morris. ImmutableServer](http://martinfowler.com/bliki/ImmutableServer.html)
	*	[Florian Motlik. Immutable Servers and Continuous Deployment](https://blog.codeship.com/immutable-server/)
2.	[Alvaro Miranda Aguilera: Idea about separate minimal (kernel) image](https://groups.google.com/d/msg/packer-tool/S0h4CFkgN2Y/fsAzpiBhivoJ)
3.	[MistiC: Nested `Berksfile`s](https://habrahabr.ru/company/epam_systems/blog/221791/)
4.	[StephenKing: Method to install Jenkins plugins](https://github.com/chef-cookbooks/jenkins/issues/534#issuecomment-265145360)
5.	[tknerr: `Vagrantfile` to enable `vagrant-cachier`](https://github.com/test-kitchen/kitchen-vagrant/issues/186#issuecomment-133942255)


------------------------------------------------------------------------
Copyright © 2015-2018  Basil Peace

This is part of FIDATA Infrastructure.

Copying and distribution of this file, with or without modification,
are permitted in any medium without royalty provided the copyright
notice and this notice are preserved.  This file is offered as-is,
without any warranty.
