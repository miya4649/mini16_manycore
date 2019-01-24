#------------------------------------------------------------
create_clock -period "50.0 MHz" [get_ports DDR3_CLK_50MHZ]
create_clock -period "24.0 MHz" [get_ports CLK_24MHZ]

#------------------------------------------------------------
derive_pll_clocks

#------------------------------------------------------------
derive_clock_uncertainty

#------------------------------------------------------------

set_clock_groups -asynchronous -group [get_clocks {CLK_24MHZ}] -group [get_clocks {av_pll2_0002_0|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -group [get_clocks {av_pll2_0002_0|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}]


set_false_path -from [get_ports {TACT[0]}]
set_false_path -to [get_ports {USER_LED[0]}]
set_false_path -to [get_ports {USER_LED[1]}]
set_false_path -to [get_ports {USER_LED[2]}]
set_false_path -to [get_ports {USER_LED[3]}]
set_false_path -to [get_ports {USER_LED[4]}]
set_false_path -to [get_ports {USER_LED[5]}]
set_false_path -to [get_ports {USER_LED[6]}]
set_false_path -to [get_ports {USER_LED[7]}]
set_false_path -to [get_ports {LVDS_TX_O_N2}]
set_false_path -from [get_ports {LVDS_TX_O_N1}]
set_false_path -to [get_ports {GPIO2}]
set_false_path -to [get_ports {GPIO4}]
set_false_path -to [get_ports {GPIO6}]
set_false_path -to [get_ports {GPIO8}]
set_false_path -to [get_ports {GPIO_D}]
set_false_path -to [get_ports {DIFF_TX_N9}]
set_false_path -to [get_ports {LVDS_TX_O_P3}]
set_false_path -to [get_ports {LVDS_TX_O_P0}]
