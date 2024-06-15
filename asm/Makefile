SRCS=$(wildcard *.java)
OBJS=$(SRCS:.java=.class)
BIN=$(wildcard ../*_code.bin ../*_data.bin ../*_code_mem.v ../*_data_mem.v)

all: $(OBJS) c32

test4-32: $(OBJS)
	java AsmTop --cores=4 --enable_uart=0

test4-16: $(OBJS)
	java AsmTop --cores=4 --width_p_d=16 --depth_p_i=9 --depth_m2s=4 --vram_width_bits=6 --vram_height_bits=7 --image_width_bits=6 --image_height_bits=6 --pe_depth_reg=4 --pe_enable_mvil=1 --pe_enable_mul=0 --pe_enable_mvc=0 --pe_enable_wa=0 --pe_enable_multi_bit_shift=0 --lreg_start=8 --enable_uart=0

c32: $(OBJS)
	java AsmTop --cores=32

c64: $(OBJS)
	java AsmTop --cores=64 --width_p_d=16 --depth_p_i=9 --depth_m2s=4 --vram_width_bits=6 --vram_height_bits=7 --image_width_bits=6 --image_height_bits=6 --pe_depth_reg=4 --pe_enable_mvil=1 --pe_enable_mul=0 --pe_enable_mvc=0 --pe_enable_wa=0 --pe_enable_multi_bit_shift=0 --lreg_start=8

c96: $(OBJS)
	java AsmTop --cores=96

kv260: $(OBJS)
	java AsmTop --cores=144 --depth_p_i=8 --depth_p_d=5 --depth_m2s=4

c128: $(OBJS)
	java AsmTop --cores=128

c170: $(OBJS)
	java AsmTop --cores=170

c500: $(OBJS)
	java AsmTop --cores=500 --width_p_d=16 --depth_p_i=9 --depth_m2s=4 --vram_width_bits=6 --vram_height_bits=7 --image_width_bits=6 --image_height_bits=6 --pe_depth_reg=4 --pe_enable_mvil=1 --pe_enable_mul=0 --pe_enable_mvc=0 --pe_enable_wa=0 --pe_enable_multi_bit_shift=0 --lreg_start=8

$(OBJS):%.class:%.java
	javac $<

clean:
	rm -f *.class
	rm -f $(BIN)
