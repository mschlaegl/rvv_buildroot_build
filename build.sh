#!/bin/bash

echo "Build RISC-V toolchain and buildroot with support for Vector extension"
echo

# switch to directory where build is located
cd $(dirname $0)
# get current path
WORKPATH=$(pwd -P)
# path where the toolchain is installed
TOOLCHAIN_INSTALL_PATH="$WORKPATH/riscv-gnu-toolchain_install"


build_toolchain()
{
	# check, if already built
	if [ -e .stamp/toolchain ] ; then
		echo "already built -> skipped!"
		return 0
	fi


	pushd riscv-gnu-toolchain > /dev/null

	echo " ++ Configure"
	if ! ./configure --prefix="$TOOLCHAIN_INSTALL_PATH" ; then
		echo "ERROR! -> Abort"
		popd > /dev/null
		return 1
	fi
	echo " -- Configure"

	echo " ++ Build"
	if ! make linux -j $(nproc) ; then
		echo "ERROR! -> Abort"
		popd > /dev/null
		return 1
	fi
	echo " -- Build"

	popd > /dev/null
	
	# success -> create stamp file
	mkdir -p .stamp
	touch .stamp/toolchain

	return 0
}


build_buildroot()
{
	echo " ++ Update config"
	sed buildroot.config \
		-e s#\@TOOLCHAIN_INSTALL_PATH\@#$TOOLCHAIN_INSTALL_PATH#g	\
	> buildroot/.config
	echo " -- Update config"

	echo " ++ Build"
	pushd buildroot > /dev/null
	if ! make ; then
		echo "ERROR! -> Abort"
		popd > /dev/null
		return 1
	fi
	echo " -- Build"

	popd > /dev/null

	echo " ++ Link output"
	rm -rf output
	ln -s buildroot/output
	echo " -- Link output"

	return 0
}


echo " + Build Toolchain"
if ! build_toolchain ; then
	exit 1
fi
echo " - Build Toolchain"


echo " + Build Buildroot"
if ! build_buildroot ; then
	exit 1
fi
echo " - Build Buildroot"


echo
echo "done."
