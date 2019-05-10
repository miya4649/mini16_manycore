create_clock -period "50.0 MHz" [get_ports CLOCK_50]

derive_pll_clocks

derive_clock_uncertainty

set_clock_groups -asynchronous -group [get_clocks {CLOCK_50}] -group [get_clocks {av_pll2_0002_0|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -group [get_clocks {av_pll2_0002_0|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}]


set_false_path -from [get_ports {RESET_N}]
set_false_path -to [get_ports {LEDR[0]}]
set_false_path -to [get_ports {LEDR[1]}]
set_false_path -to [get_ports {LEDR[2]}]
set_false_path -to [get_ports {LEDR[3]}]
set_false_path -to [get_ports {LEDR[4]}]
set_false_path -to [get_ports {LEDR[5]}]
set_false_path -to [get_ports {LEDR[6]}]
set_false_path -to [get_ports {LEDR[7]}]
set_false_path -to [get_ports {LEDR[8]}]
set_false_path -to [get_ports {LEDR[9]}]
set_false_path -to [get_ports {GPIO_0[30]}]
set_false_path -from [get_ports {GPIO_0[32]}]
set_false_path -to [get_ports {VGA_HS}]
set_false_path -to [get_ports {VGA_VS}]
set_false_path -to [get_ports {VGA_R[0]}]
set_false_path -to [get_ports {VGA_R[1]}]
set_false_path -to [get_ports {VGA_R[2]}]
set_false_path -to [get_ports {VGA_R[3]}]
set_false_path -to [get_ports {VGA_G[0]}]
set_false_path -to [get_ports {VGA_G[1]}]
set_false_path -to [get_ports {VGA_G[2]}]
set_false_path -to [get_ports {VGA_G[3]}]
set_false_path -to [get_ports {VGA_B[0]}]
set_false_path -to [get_ports {VGA_B[1]}]
set_false_path -to [get_ports {VGA_B[2]}]
set_false_path -to [get_ports {VGA_B[3]}]
