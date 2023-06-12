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
use ieee.std_ulogic_1164.all;
use ieee.numeric_std.all;

package uart_pkg is
    
    --================================= Types =====================================--
    type uart_config is record
        clock_frequency:    positive;  -- clock frequency (50MHz)
        baud_rate:          positive;  -- desired baud rate (9600)
        data_bits:          positive;  -- Number of data bits per frame
        stop_bits:          positive;  -- Number of stop bits
        clock_divider:      positive;  -- Clock divider for baud rate generation
        fifo_width:         positive;
        fifo_depth:         positive;
    end record uart_config;
    
    --================================= Constants =================================--
    constant uart_default_config: uart_config := (
        clock_frequency =>    50000000,
        baud_rate       =>    19200,
        data_bits       =>    8,
        stop_bits       =>    1,
        clock_divider   =>    163, -- 50000000/(16*19200)
        fifo_width      =>    32,
        fifo_depth      =>    1024
    );
    
    --================================= Functions ===================================--
    function get_fifo_level(write_pointer: unsigned; read_pointer: unsigned; depth: positive) return integer;
    
    --================================= UART_TX ===================================--
    component uart_tx is
        
    end component;
    
    --================================= UART_RX ===================================--
    component uart_rx is
        
    end component;
    
    --================================= UART_FIFO ===================================--
    component uart_fifo is
        
    end component;
    
    --================================= UART_BAUD ===================================--
    component uart_baud is -- Generates a pulse at the sample rate and baud
        
    end component;
    
    --================================= UART_TOP ===================================--
    component uart_top is
        
    end component;
    
    --================================= UART_TB ===================================--
    component uart_tb is
        
    end component;
    
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

















