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
	$(IVERILOG) -o m_cdf cdf/cdf_control.v cdf/cdf_datapath.v ../tb/cdf/cdf_control_tb.v

run_cdf : 
	$(VVP) m_cdf
	$(GTKWAVE) cdf_control_tb.vcd &	
	
compile_histogram :
	$(IVERILOG) histogram/histogram_control.v histogram/histogram_data_path.v
	
compile_divider :
	$(IVERILOG) divider/binary_dividier.v divider/divider.v
	
clean : 
	rm -f */a.out	
			
