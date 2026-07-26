onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /SPI_tb/clk
add wave -noupdate /SPI_tb/rst
add wave -noupdate /SPI_tb/ss_n
add wave -noupdate /SPI_tb/MOSI
add wave -noupdate /SPI_tb/DUT/my_slave/ACCUMULATOR
add wave -noupdate /SPI_tb/MISO_Exp
add wave -noupdate /SPI_tb/DUT/my_mem/RD_ADDR
add wave -noupdate /SPI_tb/MISO
add wave -noupdate /SPI_tb/DUT/my_mem/mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {64 ns}
