vlib work
vlog SPI_slave.v RAM.v SPI_wrapper.v SPI_tb.v  +cover -covercells
vsim -voptargs=+acc work.SPI_tb -cover
do wave.do
run -all