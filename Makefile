ROMS=$(wildcard *_code_mem.v *_data_mem.v *_code.bin *_data.bin)

all: program

run: program tool
	make -C tools run

tool:
	make -C tools

program:
	make -C asm

sim:
	make -C testbench run

clean:
	make -C asm clean
	make -C testbench clean
	make -C tools clean

	rm -f $(ROMS)
