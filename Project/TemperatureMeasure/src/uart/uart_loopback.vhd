-- =============================================================================
-- AUTHOR:          Le Vu Duc Hung
--
-- DATE:            12/06/2023
--
-- FILE:            uart_loopback.vhd
--
-- DESCRIPTION:     This VHDL file implements a loopback functionality for UART 
--                  communication. It includes components for transmitting 
--                  (uart_tx), receiving (uart_rx), and buffering (uart_fifo) UART 
--                  data. The loopback functionality retransmits any received data.
--                  The uart_tx component sends data to the uart_fifo for buffering,
--                  and the uart_rx component receives data from the uart_fifo. 
--                  The uart_baud component generates baud rate signals for the 
--                  transmitter and receiver.
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
use ieee.math_real.all;
use work.uart_pkg.all;

entity uart_loopback is
    generic(
        config: uart_config := uart_default_config
    );
    port (
        clk:   in std_ulogic;
        reset: in std_ulogic;
        rx:    in std_ulogic;
        tx:    out std_ulogic
    );
end entity uart_loopback;

architecture rtl of uart_loopback is
    --================================= UART_TX ===================================--
    component uart_tx is
        generic(
            config: uart_config := uart_default_config
        );
        port (
            clk:                  in std_ulogic;
            reset:                in std_ulogic;
            tx_baud_tick:         in std_ulogic;
            data_stream_in:       in std_ulogic_vector(config.data_bits - 1 downto 0);
            data_stream_in_std:   in std_ulogic;
            data_stream_in_ack:   out std_ulogic;
            tx:                   out std_ulogic
        );
    end component uart_tx;
    
    --================================= UART_RX ===================================--
    component uart_rx is
        generic(
            config: uart_config := uart_default_config
        );
        port(
            clk:                  in std_ulogic;
            reset:                in std_ulogic;
            rx_baud_tick:         in std_ulogic;
            rx:                   in std_ulogic;

            data_stream_out:      out std_ulogic_vector(config.data_bits - 1 downto 0);
            data_stream_out_stb:  out std_ulogic 
        );
    end component uart_rx;
    
    --================================= UART_FIFO ===================================--
    component uart_fifo is
        generic (
            config: uart_config := uart_default_config
        );
        port(
            clk:          in std_ulogic;
            reset:        in std_ulogic;
            write_data:   in std_ulogic_vector(config.fifo_width - 1 downto 0);
            write_enable: in std_ulogic;
            read_enable:  in std_ulogic;
            
            read_data:    out std_ulogic_vector(config.fifo_width - 1 downto 0);
            full :        out std_ulogic;
            empty:        out std_ulogic;
            level:        out std_ulogic_vector(integer(ceil(log2(real(config.fifo_depth)))) - 1 downto 0)
        );
    end component uart_fifo;
    
    --================================= UART_BAUD ===================================--
    component uart_baud is
        generic (
            config:   uart_config := uart_default_config
        );
        port(
            clk:      in  std_ulogic;
            reset:    in  std_ulogic;
            rx_tick:  out std_ulogic;
            tx_tick:  out std_ulogic
        );
    end component uart_baud;

-- ==============================================================================================================
-- |         UART Signals          |                         Data Type                     |       Value        |
-- ==============================================================================================================
    signal uart_rx_baud_tick       :    std_ulogic                                                 := '0';
    signal uart_tx_baud_tick       :    std_ulogic                                                 := '0';
    signal uart_data_in            :    std_ulogic_vector(config.data_bits - 1 downto 0);
    signal uart_data_out           :    std_ulogic_vector(config.data_bits - 1 downto 0);
    signal uart_data_in_stb        :    std_ulogic                                                 := '0';
    signal uart_data_in_ack        :    std_ulogic                                                 := '0';
    signal uart_data_out_stb       :    std_ulogic                                                 := '0';
-- ===============================================================================================================

-- ==============================================================================================================
-- |    Transmit Buffer Signals    |                         Data Type                     |       Value        |
-- ==============================================================================================================
    signal fifo_data_out           :    std_ulogic_vector(config.data_bits - 1 downto 0);                                                 
    signal fifo_data_in            :    std_ulogic_vector(config.data_bits - 1 downto 0);                                                 
    signal fifo_data_out_stb       :    std_ulogic                                                 := '0';            
    signal fifo_data_in_stb        :    std_ulogic                                                 := '0';  
    signal fifo_full               :    std_ulogic                                                 := '0';  
    signal fifo_empty              :    std_ulogic                                                 := '1';  
-- ===============================================================================================================
    
begin
    --================================= UART_TX INSTANCE ===================================--
    UART_TX_INST : uart_tx
    generic map (
        config                => config
    )
    port map (
        clk                   => clk,
        reset                 => reset,
        tx_baud_tick          => uart_tx_baud_tick,
        data_stream_in        => uart_data_in,
        data_stream_in_std    => uart_data_in_stb,
        data_stream_in_ack    => uart_data_in_ack,
        tx                    => tx
    );

    --================================= UART_RX INSTANCE ===================================--
    UART_RX_INST : uart_rx
    generic map (
        config                => config
    )
    port map (
        clk                   => clk,
        reset                 => reset,
        rx_baud_tick          => uart_rx_baud_tick,
        rx                    => rx,
        data_stream_out       => uart_data_out,
        data_stream_out_stb   => uart_data_out_stb
    );
    
    --================================= UART_FIFO INSTANCE ===================================--
    FIFO_BUFFER : uart_fifo
    generic map (
        config                => config
    )
    port map (
        clk                   => clk,
        reset                 => reset,
        write_data            => fifo_data_in,
        write_enable          => fifo_data_in_stb,
        read_enable           => fifo_data_out_stb,
		read_data             => fifo_data_out,
        full                  => fifo_full,
        empty                 => fifo_empty,
        level                 => open
    );

    --================================= UART_BAUD INSTANCE ===================================--
    UART_BAUD_INST : uart_baud
    generic map (
        config                => config
    )
    port map (
        clk                   => clk,
        reset                 => reset,
        rx_tick               => uart_rx_baud_tick,
        tx_tick               => uart_tx_baud_tick
    );

    -- Simple loopback, retransmit any received data
    UART_LOOPBACK : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                uart_rx_baud_tick   <= '0';   
                uart_tx_baud_tick   <= '0';
                uart_data_in        <= (others => '0');
                uart_data_in_stb    <= '0';
                fifo_data_out_stb   <= '0';
                fifo_data_in_stb    <= '0';
            else
                -- Acknowledge data receive strobes and set up a transmission request
                fifo_data_in_stb <= '0';
                if uart_data_out_stb = '1' and fifo_full = '0' then
                    fifo_data_in_stb <= '1';
                    fifo_data_in     <= uart_data_out;
                end if;
                -- Clear transmission request strobe upon acknowledge
                if uart_data_in_ack = '1' then
                    uart_data_in_stb <= '0';
                end if;
                -- Transmit any data in the buffer
                fifo_data_out_stb <= '0';
                if fifo_empty = '0' then
                    if uart_data_in_stb = '0' then
                        fifo_data_out_stb <= '1';
                        uart_data_in_stb <= '1';
                        uart_data_in <= fifo_data_out;
                    end if;
                end if;
            end if;
        end if;
    end process; -- UART_LOOPBACK
    
end architecture rtl;