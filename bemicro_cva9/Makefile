ROMS=$(wildcard ../*_code_mem.v ../*_data_mem.v ../*_code.bin ../*_data.bin)

all: program

run: program tool
	make -C ../tools run

tool:
	make -C ../tools

program:
	make -C ../asm c170

clean:
	make -C ../asm clean
	make -C ../tools clean
	rm -f $(ROMS)
	rm -f *.pof *.rpt *.done *.smsg *.summary *.jdi *.pin *.qws *.sld *.sof *.qdf *dump.txt
	rm -rf db incremental_db simulation output_files
