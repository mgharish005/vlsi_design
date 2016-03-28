#######################################################
# Makefile to organize compilation and simulation of
# Histogram Equalization RTL
# Author : Kaushik Gopalakrishnan
# Rev 01 (03/28/2016)
#######################################################

# Variables
IVERILOG := iverilog
INCLUDES := -I/home/kaugop01/projects/verilog/histogram/rtl/histogram/

# Rules
default : compile_rtl

compile_rtl : compile_histogram compile_cdf compile_divider

compile_cdf : 
	$(IVERILOG) cdf/cdf_control.v cdf/cdf_memcontroller.v cdf/cdf_datapath.v
	
compile_histogram :
	$(IVERILOG) histogram/histogram_control.v histogram/histogram_data_path.v
	
compile_divider :
	$(IVERILOG) divider/binary_dividier.v divider/divider.v
	
clean : 
	rm -f */a.out	
			
