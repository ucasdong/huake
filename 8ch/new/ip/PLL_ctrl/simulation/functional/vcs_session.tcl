gui_open_window Wave
gui_sg_create PLL_ctrl_group
gui_list_add_group -id Wave.1 {PLL_ctrl_group}
gui_sg_addsignal -group PLL_ctrl_group {PLL_ctrl_tb.test_phase}
gui_set_radix -radix {ascii} -signals {PLL_ctrl_tb.test_phase}
gui_sg_addsignal -group PLL_ctrl_group {{Input_clocks}} -divider
gui_sg_addsignal -group PLL_ctrl_group {PLL_ctrl_tb.CLK_IN1}
gui_sg_addsignal -group PLL_ctrl_group {{Output_clocks}} -divider
gui_sg_addsignal -group PLL_ctrl_group {PLL_ctrl_tb.dut.clk}
gui_list_expand -id Wave.1 PLL_ctrl_tb.dut.clk
gui_sg_addsignal -group PLL_ctrl_group {{Status_control}} -divider
gui_sg_addsignal -group PLL_ctrl_group {PLL_ctrl_tb.RESET}
gui_sg_addsignal -group PLL_ctrl_group {PLL_ctrl_tb.LOCKED}
gui_sg_addsignal -group PLL_ctrl_group {{Counters}} -divider
gui_sg_addsignal -group PLL_ctrl_group {PLL_ctrl_tb.COUNT}
gui_sg_addsignal -group PLL_ctrl_group {PLL_ctrl_tb.dut.counter}
gui_list_expand -id Wave.1 PLL_ctrl_tb.dut.counter
gui_zoom -window Wave.1 -full
