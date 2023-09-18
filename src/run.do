# Compile design source
vlog spi_slave_interface.v
vlog prng.v
vlog dds.v
vlog dds_top.v
vlog synchronizer.v
vlog sync_async_reset.v
vlog tt_um_basic_dds.v

# Compile testbench
vcom testbench.vhd

# Launch simulation
vsim -t 10ps -voptargs=+acc testbench

# Add waves
config wave -signalnamewidth 1
add wave -group {TESTBENCH}             sim:/testbench/*
add wave -group {TT_UM_BASIC_DDS}       sim:/testbench/inst_tt_um_basic_dds/*
add wave -group {RESET_RESYNC}          sim:/testbench/inst_tt_um_basic_dds/inst_sync_async_reset/*
add wave -group {DATA_RESYNC}           sim:/testbench/inst_tt_um_basic_dds/sync_0/*
add wave -group {DDS_TOP}               sim:/testbench/inst_tt_um_basic_dds/inst_dds_top/*
add wave -group {SPI_SLAVE_INTERFACE}   sim:/testbench/inst_tt_um_basic_dds/inst_dds_top/inst_spi_slave_interface/*
add wave -group {DDS}                   sim:/testbench/inst_tt_um_basic_dds/inst_dds_top/inst_dds/*
add wave -group {PRNG}                  sim:/testbench/inst_tt_um_basic_dds/inst_dds_top/inst_dds/inst_prng/*

# Run the simulation
run 20 us