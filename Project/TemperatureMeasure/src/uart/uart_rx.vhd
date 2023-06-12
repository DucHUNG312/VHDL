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
        rx_baud_tick:         in std_ulogic;
        rx:                   in std_logic;

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
    signal uart_rx_count:                 unsigned(2 downto 0)                                    := (others => '0');
    signal uart_rx_data_vec:              std_ulogic_vector(config.data_bits - 1 downto 0)        := (others => '0');
    signal uart_rx_data_out_sb:           std_ulogic                                              := '0'; 
    signal uart_rx_data_sr:               std_ulogic_vector(1 downto 0)                           := (others => '1');
    signal uart_rx_bit:                   std_ulogic                                              := '1';
    signal uart_rx_filter:                unsigned(1 downto 0)                                    := (others => '1');
    signal uart_rx_bit_spacing:           unsigned(3 downto 0)                                    := (others => '0');
    signal uart_rx_bit_tick:              std_ulogic                                              := '0';
begin
    -- Connect IO
    data_stream_out <= uart_rx_data_vec;
    data_stream_out_stb <= uart_rx_data_out_sb;

    -- RXD_SYNCHRONIZE: Synchronize the incoming received data (rxd) with the oversampled baud rate. It ensures that the received 
    -- data is sampled at the correct time to extract the transmitted bits accurately.
    RXD_SYNCHRONIZE : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                uart_rx_data_sr <= (others => '1');
            else
                if rx_baud_tick = '1' then
                    uart_rx_data_sr(0) <= rx;
                    uart_rx_data_sr(1) <= uart_rx_data_sr(0);
                end if;
            end if;
        end if;
    end process; -- RXD_SYNCHRONIZE

    -- RXD_FILTER: Filters the received data and determines the logic level of each received bit. 
    -- It improves noise immunity, enhances bit detection reliability, and enables accurate interpretation of the transmitted data.
    RXD_FILTER : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                uart_rx_filter <= (others => '1');
                uart_rx_bit <= '1';
            else 
                if rx_baud_tick = '1' then
                    -- filter rxd
                    if uart_rx_data_sr(1) = '1' and uart_rx_filter < 3 then
                        uart_rx_filter <= uart_rx_filter + 1;
                    elsif uart_rx_data_sr(1) = '0' and uart_rx_filter > 0 then
                        uart_rx_filter <= uart_rx_filter - 1;
                    end if;
                    -- set the rx bit
                    if uart_rx_filter = 3 then
                        uart_rx_bit <= '1';
                    elsif uart_rx_filter = 0 then
                        uart_rx_bit <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process; -- RXD_FILTER 

    -- RX_BIT_SPACING: Provided UART receiver implementation is responsible for tracking the 
    -- spacing between received bits (each bit is sampled 16 times) and determining the timing of each bit.
    RX_BIT_SPACING : process(clk)
    begin
        if rising_edge(clk) then
            uart_rx_bit_tick <= '0';
            if rx_baud_tick = '1' then
                if uart_rx_bit_spacing = 15 then
                    uart_rx_bit_tick <= '1';
                    uart_rx_bit_spacing <= (others => '0');
                else 
                    uart_rx_bit_spacing <= uart_rx_bit_spacing + 1;
                end if;
                if uart_rx_state = rx_get_start_bit then
                    uart_rx_bit_spacing <= (others => '0');
                end if;
            end if;
        end if;
    end process; -- RX_BIT_SPACING
   

    UART_RECEIVE_DATA : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                uart_rx_state <= rx_get_start_bit;
                uart_rx_data_vec <= (others => '0');
                uart_rx_count <= (others => '0');
                uart_rx_data_out_sb <= '0';
            else 
                uart_rx_data_out_sb <= '0';
                case uart_rx_state is
                    when rx_get_start_bit =>
                        if rx_baud_tick = '1' and uart_rx_bit = '0' then
                            uart_rx_state <= rx_get_data;
                        end if;
                    when rx_get_data =>
                        if uart_rx_bit_tick = '1' then
                            uart_rx_data_vec(uart_rx_data_vec'high) <= uart_rx_bit; -- receive uart_rx_bit
                            uart_rx_data_vec(uart_rx_data_vec'high - 1 downto 0) <= uart_rx_data_vec(uart_rx_data_vec'high downto 1); -- shift the data
                            if uart_rx_count < 7 then
                                uart_rx_count <= uart_rx_count + 1;
                            else 
                                uart_rx_count <= (others => '0');
                                uart_rx_state <= rx_get_stop_bit;
                            end if;
                        end if;
                    when rx_get_stop_bit =>
                        if uart_rx_bit_tick = '1' then 
                            if uart_rx_bit = '1' then
                                uart_rx_state <= rx_get_start_bit;
                                uart_rx_data_out_sb <= '1';
                            end if;
                        end if;
                    when others =>
                        uart_rx_state <= rx_get_start_bit;      
                end case;
            end if;
        end if;
    end process; -- UART_RECEIVE_DATA

end architecture rtl;























