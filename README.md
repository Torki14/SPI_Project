# SPI Slave with a Single-Port RAM

A synchronous SPI slave peripheral implemented in Verilog, interfaced with a single-port 256×8 RAM through a custom memory-mapped command protocol. The slave decodes serial commands from the SPI bus, drives read/write transactions into the RAM, and returns data back over MISO.

## Architecture

```
                 ┌──────────────────┐        ┌──────────────┐
   MOSI ───────► │                  │  10-bit│              │
   SS_n  ───────►│    SPI_slave     │  cmd/  │     RAM      │
   clk   ───────►│                  │  addr/ │  (256 x 8)   │
   rst_n ───────►│                  │  data  │              │
                 │                  ├───────►│              │
   MISO  ◄───────│                  │◄───────┤              │
                 └──────────────────┘        └──────────────┘
                        SPI_wrapper (top-level integration)
```

- **`SPI_slave.v`** — FSM-based SPI slave. Shifts in 10-bit command words on MOSI, decodes the command, and shifts data back out on MISO for read operations.
- **`RAM.v`** — Parameterized single-port memory (default 256 × 8) with a simple 4-command interface driven by the top 2 bits of the received word.
- **`SPI_wrapper.v`** — Top-level module instantiating and connecting `SPI_slave` and `RAM`.
- **`SPI_tb.v`** — Directed testbench exercising the full write-address → write-data → read-address → read-data sequence.
- **`mem.dat`** — Hex memory initialization file loaded into the RAM at simulation start via `$readmemh`.

## Protocol

Each SPI transaction shifts in a **10-bit command word**, where the top 2 bits select the operation and the remaining 8 bits carry the address or data payload:

| `din[9:8]` | Command          | `din[7:0]` meaning |
|:----------:|------------------|---------------------|
| `00`       | Set write address| Target address       |
| `01`       | Write data       | Data byte to store    |
| `10`       | Set read address | Target address       |
| `11`       | Trigger read     | (ignored)             |

For a read, the slave receives the 10-bit read-trigger word, then continues clocking to shift the RAM's output byte back out on **MISO**.

### SPI Slave FSM

| State       | Description                                             |
|-------------|----------------------------------------------------------|
| `IDLE`      | Waiting for `SS_n` to go low (start of transaction)       |
| `CHK_CMD`   | Reads the first command bit to decide write vs. read path |
| `WRITE`     | Shifts in a 10-bit write-address or write-data word        |
| `READ_ADD`  | Shifts in a 10-bit read-address word                       |
| `READ_DATA` | Shifts in the read-trigger word, then shifts out MISO data |

## Module Interfaces

### `SPI_slave`

| Port      | Direction | Width | Description                    |
|-----------|-----------|:-----:|---------------------------------|
| `clk`     | input     | 1     | System clock                    |
| `rst_n`   | input     | 1     | Active-low asynchronous reset   |
| `SS_n`    | input     | 1     | Active-low slave select         |
| `MOSI`    | input     | 1     | Master-out, slave-in serial line|
| `tx_data` | input     | 8     | Byte from RAM to shift out on read |
| `tx_valid`| input     | 1     | Pulse indicating `tx_data` is valid |
| `MISO`    | output    | 1     | Master-in, slave-out serial line |
| `rx_data` | output    | 10    | Decoded command word to RAM      |
| `rx_valid`| output    | 1     | Pulse indicating `rx_data` is valid |

### `RAM`

| Port       | Direction | Width | Description                  |
|------------|-----------|:-----:|-------------------------------|
| `clk`      | input     | 1     | System clock                  |
| `rst_n`    | input     | 1     | Active-low reset               |
| `din`      | input     | 10    | Command word from SPI slave    |
| `rx_valid` | input     | 1     | Latches `din` on this pulse    |
| `dout`     | output    | 8     | Data byte for the current read |
| `tx_valid` | output    | 1     | Pulse indicating `dout` is valid|

**Parameters:** `MEM_DEPTH` (default 256), `ADDR_SIZE` (default 8)

## Verification

`SPI_tb.v` is a directed testbench that:
1. Preloads the RAM from `mem.dat`.
2. Applies reset.
3. Sends a write-address command, then a write-data command.
4. Sends a read-address command, then a read-trigger command.
5. Observes the byte shifted back on `MISO`.

## Running the Simulation

```bash
# ModelSim / QuestaSim
vlog SPI_slave.v RAM.v SPI_wrapper.v SPI_tb.v
vsim -c SPI_tb -do "run -all"
```

Make sure `mem.dat` is in the simulation's working directory, since it's loaded via a relative path in the testbench.

## Tools

Verilog, ModelSim/QuestaSim

## Author

Mohamed Torki Bassuni — [LinkedIn](https://linkedin.com/in/muhammad-torki) · [GitHub](https://github.com/Torki14)
