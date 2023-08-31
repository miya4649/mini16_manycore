ROMS=$(wildcard ../*_code_mem.v ../*_data_mem.v ../*_code.bin ../*_data.bin)

all: program

run: program tool
	make -C ../tools run

tool:
	make -C ../tools

program:
	make -C ../asm c96

clean:
	make -C ../asm clean
	make -C ../tools clean

	rm -f $(ROMS)
