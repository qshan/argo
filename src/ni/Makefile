#FILES= ../ocp/ocp_config.vhd ../ocp/ocp.vhd ../argo_types.vhd ../mem/tdp_ram.vhd \
#	 ../util/math_util.vhd config_bus.vhd TDM_controller.vhd schedule_table.vhd \
#	 DMA_table.vhd config_unit.vhd data_unit.vhd irq_unit.vhd network_interface.vhd

comp:
	rm -fr work
	vlib work
	vcom -quiet ../config.vhd
	vcom -quiet ../ocp/ocp_config.vhd ../ocp/ocp.vhd
	vcom -quiet ../argo_types.vhd
	vcom -quiet ../mem/tdp_ram.vhd
	vcom -quiet ../util/math_util.vhd
	vcom -quiet -2008 config_bus.vhd
	vcom -quiet -2008 TDM_controller.vhd schedule_table.vhd packet_manager.vhd
	vcom -quiet -2008 config_unit.vhd data_unit.vhd irq_unit.vhd irq_fifo.vhd 
	vcom -quiet network_interface.vhd

#./comp/%.o: %.vhd work
#	-mkdir comp
#	echo "Compiled" >> $@
#	vcom -quiet $*.vhd
#
#sim-%.vhd: %.vhd
#	vsim %

clean:
	rm -fr work

#work:
#	vlib work
#
#comp: work $(FILES)