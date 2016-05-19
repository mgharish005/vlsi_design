#######################################################
# Makefile to organize compilation and simulation of
# Histogram Equalization RTL
# Author : Kaushik Gopalakrishnan
# Rev 01 (03/28/2016)
#######################################################

# Variables
IVERILOG := iverilog
VVP := vvp
GTKWAVE := gtkwave
INCLUDES := -I/home/kaugop01/projects/verilog/histogram/rtl/histogram/

# Rules
default : compile_rtl

compile_rtl : compile_histogram compile_cdf compile_divider
cdf : compile_cdf run_cdf
	echo Running cdf......

compile_cdf : 
	$(IVERILOG) -o m_cdf cdf/cdf_control.v cdf/cdf_datapath.v memory.v ../tb/cdf/cdf_control_tb.v 

run_cdf : 
	$(VVP) m_cdf
	$(GTKWAVE) cdf_control_tb.vcd &	
	
compile_histogram :
	$(IVERILOG) -o m_hist histogram/histogram_control.v histogram/histogram_data_path.v memory.v cdf/cdf_control.v cdf/cdf_datapath.v ../tb/histogram/histogram_top_tb.v
	$(VVP) m_hist
	$(GTKWAVE) histogram_top_tb.vcd &
	
compile_divider :
	$(IVERILOG) divider/binary_divider.v divider/divider.v

compile_top : 
	$(IVERILOG) -o m_top cdf/cdf_control.v cdf/cdf_datapath.v histogram/histogram_control.v histogram/histogram_data_path.v divider/binary_divider.v divider/divider.v histogram_equalizer_core.v mem_controller.v top_level_control.v memory.v top_without_mem.v top.v 	 

compile_equ :
	$(IVERILOG) -o m_equ cdf/cdf_control.v cdf/cdf_datapath.v histogram/histogram_control.v histogram/histogram_data_path.v divider/binary_divider.v divider/divider.v histogram_equalizer_core.v
	$(VVP) m_equ
	$(GTKWAVE) 
	
clean : 
	rm -f */a.out	
			
