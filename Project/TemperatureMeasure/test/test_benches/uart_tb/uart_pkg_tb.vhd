-- ==================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            uart_pkg_tb.vhd
--
-- @date:            14/06/2023
-- ==================================================================================================================
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
-- ==================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.uart_pkg.all;

package uart_pkg_tb is

    --========================================== Constants =========================================--
    constant uart_default_test_config: uart_config := (
        clock_frequency         => 1_000_000,   
        data_bits               => 8,
        num_bits                => 3,
        baud_rate               => 38400,  
        stop_bit                => 1,  
        parity_inhibit          => true,  
        even_parity             => true,    
        debouncer_stage         => 3,  
        tx_impl                 => true,    
        rx_impl                 => true,            
        clk_div                 => 4,               
        skip_last_bit           => false,
        sync_stage              => 2,
        voter_stage             => 5,
        output_reset            => '0',
        reset_active            => '1'        
    );
    
end package uart_pkg_tb;

package body uart_pkg_tb is
    
    
    
end package body uart_pkg_tb;