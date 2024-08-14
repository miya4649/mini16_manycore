EXES=main
EXES16=main16
VCDS=$(wildcard *.vcd)
WARN=-Wanachronisms -Wimplicit -Wmacro-replacement -Wportbind -Wselect-range -Wsensitivity-entire-array

all: $(EXES)

pe16: $(EXES16)

run: $(EXES)
	vvp $(EXES)

run16: $(EXES16)
	vvp $(EXES16)

$(EXES): program testbench.v ../*.v
	iverilog -g2012 $(WARN) -o $(EXES) testbench.v ../*.v

$(EXES16): program16 testbench.v include16.v ../*.v
	iverilog -g2012 $(WARN) -o $(EXES16) include16.v testbench.v ../*.v

program:
	make -C ../asm test4-32

program16:
	make -C ../asm test4-16

clean:
	make -C ../asm clean
	rm -f $(EXES) $(EXES16) $(VCDS)
