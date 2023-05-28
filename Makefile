SIM ?= verilator
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES += $(PWD)/saw2sin.sv $(PWD)/cordic.sv
TOPLEVEL = saw2sin
MODULE = test_saw2sin
EXTRA_ARGS += --trace-fst --trace-structs

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
