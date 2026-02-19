# Makefile for Day 1: Combinational Logic
# Compiler and flags
CC = iverilog
FLAGS = -g2012 -Wall

# Directories
SRC_DIR = src
TB_DIR = tb

# Files (Note: Package must be compiled first!)
PKG = $(SRC_DIR)/alu_pkg.sv
SRC = $(wildcard $(SRC_DIR)/*.sv)
TB = $(TB_DIR)/tb_day1.sv

# Output executable
OUT = sim_out

# Targets
all: compile run

compile:
	@echo "Compiling SystemVerilog files..."
	$(CC) $(FLAGS) -o $(OUT) $(PKG) $(filter-out $(PKG), $(SRC)) $(TB)

run: compile
	@echo "Running simulation..."
	vvp $(OUT)

wave: run
	@echo "Opening waveforms in GTKWave..."
	gtkwave day1_sim.vcd &

clean:
	@echo "Cleaning up..."
	rm -f $(OUT) *.vcd

.PHONY: all compile run wave clean
