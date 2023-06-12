-- =============================================================================
-- AUTHOR:          Le Vu Duc Hung
--
-- FILE:            uart_rx.vhd
-- =============================================================================
-- MIT License
-- Copyright (c) 2023 Le Vu Duc Hung
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
-- LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
-- OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
-- WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.uart_pkg.all;

entity uart_tx is
    generic(
        config: uart_config := uart_default_config
    );
    port(
        clk:                  in std_ulogic;
        reset:                in std_ulogic;
        rx:                   in std_ulogic;

        data_stream_in_ack :  out std_logic;
        data_stream_out:      out std_logic_vector(config.data_bits downto 0);
        data_stream_out_stb:  out std_logic;
    );
begin
end entity uart_tx;

architecture rtl of uart_tx is
    type uart_rx_states is (rx_get_start_bit, rx_get_data, rx_get_stop_bit);

-- ===================================================================================================================
-- |          Signals               |                        Data Type                          |        Value        |
-- ===================================================================================================================
    signal uart_rx_state:                 uart_rx_states                                          := rx_get_start_bit;
    signal uart_rx_bit :                  std_ulogic                                              := '1';
    signal uart_rx_data_vec:              std_ulogic_vector(config.data_bits - 1 downto 0)        := (others => '0');
    signal uart_rx_data_sr:               std_ulogic_vector(1 downto 0)                           := (others => '1');
    signal uart_rx_filter:                unsigned(1 downto 0)                                    := (others => '1');
    signal uart_rx_count:                 unsigned(2 downto 0)                                    := (others => '0');
    signal uart_rx_data_out_sb:           std_ulogic                                              := '0'; 
    signal uart_rx_bit_spacing:           unsigned(3 downto 0)                                    := (others => '0');
    signal uart_rx_bit_tick:              std_ulogic                                              := '0';
begin
    if reset = '1' then
        uart_rx_state <= rx_get_start_bit;
        uart_rx_data_vec <= (others => '0');
        uart_rx_count <= (others => '0');
        uart_rx_data_out_sb <= '0';

        uart_rx_bit
        uart_rx_bit_tick
end architecture rtl;























