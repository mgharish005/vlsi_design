CC = g++
#OPT = -O3
OPT = -g
WARN = -Wall
CFLAGS = $(OPT) $(WARN) $(INC) $(LIB) -m32

#List .cc files here
SIM_SRC = equalizer.cc

#List compiled object files here 
SIM_OBJ = equalizer.o

###########################################

#default rule

all : equalizer
	@echo "my work is done here..."

#rule for making equalizer

equalizer : $(SIM_OBJ)
	    $(CC) -o eq $(CFLAGS) $(SIM_OBJ) -lm
	    @echo "-------DONE WITH EQUALIZER"

# generic rule for converting any .cc file to any .o file

.cc.o: 
	$(CC) $(CFLAGS) -c $*.cc

clean:
	rm -rf *.o eq *hist*.txt *divid*.txt *cdf*.txt
