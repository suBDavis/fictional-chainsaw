#!/bin/bash -f
xv_path="/opt/Xilinx/Vivado/2015.4"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xsim project_screentest_behav -key {Behavioral:sim_1:Functional:project_screentest} -tclbatch project_screentest.tcl -log simulate.log
