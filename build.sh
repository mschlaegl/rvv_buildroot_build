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



echo " + Build Toolchain"
if ! build_toolchain ; then
	exit 1
fi
echo " - Build Toolchain"



echo
echo "done."
