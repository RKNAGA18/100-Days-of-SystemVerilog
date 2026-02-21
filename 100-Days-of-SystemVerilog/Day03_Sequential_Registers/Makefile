# Makefile for Day 3: Sequential Core & Registers
CC = iverilog
FLAGS = -g2012 -Wall

SRC_DIR = src
TB_DIR = tb

SRC = $(wildcard $(SRC_DIR)/*.sv)
TB = $(TB_DIR)/tb_day3.sv
OUT = sim_out

all: compile run

compile:
	@echo "Compiling SystemVerilog files..."
	$(CC) $(FLAGS) -o $(OUT) $(SRC) $(TB)

run: compile
	@echo "Running simulation..."
	vvp $(OUT)

wave: run
	@echo "Opening waveforms in GTKWave..."
	gtkwave day3_sim.vcd &

clean:
	@echo "Cleaning up..."
	rm -f $(OUT) *.vcd

.PHONY: all compile run wave clean