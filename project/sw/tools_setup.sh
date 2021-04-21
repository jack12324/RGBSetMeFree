# !/usr/bin/bash
# FPGA Environment
export OPAE_PLATFORM_ROOT=~/opae
export PATH=$PATH:$OPAE_PLATFORM_ROOT/bin
export prefix=$OPAE_PLATFORM_ROOT
export LD_LIBRARY_PATH=$OPAE_PLATFORM_ROOT/lib
export MTI_HOME=/cae/apps/data/mentor-current/questasim
export QUARTUS_HOME=/cae/apps/data/quartus-current/quartus
export VCS_HOME=/cae/apps/data/synopsys-current/vcs-mx/Q-2020.03-SP1
export PATH=$QUARTUS_HOME/bin:$PATH
export FPGA_FAMILY=cyclonev
export FPGA_BBB_CCI_SRC=~/intel-fpga-bbb
export CLASS_SYSARG="-I$OPAE_PLATFORM_ROOT/include -L$OPAE_PLATFORM_ROOT/lib"
bash
