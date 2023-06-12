-- =============================================================================
-- AUTHOR:    Le Vu Duc Hung
--
-- DATE:      12/06/2023
--
-- FILE:      uart_pkg.vhd
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
use ieee.math_real.all;
use ieee.numeric_std.all;

package uart_pkg is
    
    --================================= Types =====================================--
    type uart_config is record
        clock_frequency:    positive;  -- clock frequency (50MHz)
        baud_rate:          positive;  -- desired baud rate (9600)
        data_bits:          positive;  -- Number of data bits per frame
        bit_spacing:        positive; 
        fifo_width:         positive;
        fifo_depth:         positive;   
    end record uart_config;
    
    --================================= Constants =================================--
    constant uart_default_config: uart_config := (
        clock_frequency =>    50000000,
        baud_rate       =>    19200,
        data_bits       =>    8,
        bit_spacing     =>    16,
        fifo_width      =>    8,
        fifo_depth      =>    1024
    );
    
    --================================= Functions ===================================--
    function get_fifo_level(write_pointer: unsigned; read_pointer: unsigned; depth: positive) return integer;
    
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
        generic(
            config: uart_config := uart_default_config
        );
        port(
            clk:          in std_ulogic;
            reset:        in std_ulogic;
            write_data:   in std_ulogic_vector(config.fifo_width - 1 downto 0);
            read_data:    in std_ulogic_vector(config.fifo_width - 1 downto 0);
            write_enable: in std_ulogic;
            read_enable:  in std_ulogic;
            
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

    --================================= UART_LOOPBACK ===================================--
    component uart_loopback is
        generic(
            config: uart_config := uart_default_config
        );
        port (
            clk:   in std_ulogic;
            reset: in std_ulogic;
            rx:    in std_ulogic;
            tx:    out std_ulogic
        );
    end component uart_loopback;
    
    --================================= UART_TOP ===================================--
    component uart_top is
        
    end component uart_top;
    
end package uart_pkg;


package body uart_pkg is
       
    function get_fifo_level(write_pointer: unsigned; read_pointer: unsigned; depth: positive) return integer is
    begin
        if write_pointer > read_pointer then
            return to_integer(write_pointer - read_pointer);
        elsif write_pointer = read_pointer then
            return 0;
        else
            return (((depth) - to_integer(read_pointer)) + to_integer(write_pointer));
        end if;
    end function get_fifo_level;

end package body uart_pkg;

















