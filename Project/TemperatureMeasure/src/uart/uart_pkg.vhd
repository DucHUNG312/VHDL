-- ==================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            uart_pkg.vhd
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

package uart_pkg is
    
    --=========================================== Types ===========================================--
    type uart_config is record
        clock_frequency:        positive;  -- Master clock frequency in Hz 
        data_bits:              positive;  -- Number of data bits 
        num_bits:               positive;  -- Number of baud bits to handle
        baud_rate:              positive;  -- Transceive baud rate in bps
        stop_bit:               positive;  -- Stop bit select, only one/two stopbit
        parity_inhibit:         boolean;   -- Parity inhibit, true: inhibit
        even_parity:            boolean;   -- Even parity enable
        debouncer_stage:        positive;  -- Number of debouncer stages 
        tx_impl:                boolean;   -- Implement UART TX path
        rx_impl:                boolean;   -- Implement UART RX path
        clk_div:                positive;  -- Half bit period clock divider
        skip_last_bit:          boolean;   -- Skip the last bit when in the UART RX path, otherwise UART TX path
        sync_stage:             positive;  -- Synchronizer stages filter
        voter_stage:            positive;  -- Number of ff stages filter for voter; if all '1' out is '1', if all '0' out is '0', otherwise hold;
        output_reset:           bit;       -- Filter output in reset
        reset_active:           bit;       -- Filter reset active level
    end record uart_config;
    

    --========================================== Constants =========================================--
    constant uart_default_config: uart_config := (
        clock_frequency         => 50_000_000,   
        data_bits               => 8,
        num_bits                => 10,
        baud_rate               => 115200,  
        stop_bit                => 1,  
        parity_inhibit          => true,  
        even_parity             => true,    
        debouncer_stage         => 3,  
        tx_impl                 => true,    
        rx_impl                 => true,            
        clk_div                 => 8,               
        skip_last_bit           => false,
        sync_stage              => 2,
        voter_stage             => 3,
        output_reset            => '1',
        reset_active            => '1'        
    );


    --========================================== Functions =========================================--
    function reverse(arg: std_ulogic_vector) return std_ulogic_vector;
    function parity(constant value: std_ulogic_vector; constant even: boolean) return std_ulogic;
    function numParBit(constant parity_inhibit: boolean := true) return integer; 

    --========================================== UART_BAUD =========================================--
    component uart_baud is
        generic (
            config: uart_config := uart_default_config
        );
        port (
            clk:                        in  std_ulogic; -- clock, rising edge
            reset:                      in  std_ulogic; -- reset
            start:                      in  std_ulogic; -- start interaction
    
            busy:                       out std_ulogic; -- transfer is activing
            shift_register_load:        out std_ulogic; -- load parallel input of shift register
            shift_register_begin:       out std_ulogic; -- shift pulse TBIT (time per bit) begin
            shift_register_middle:      out std_ulogic; -- shift pulse TBIT (time per bit) middle
            shift_register_capture:     out std_ulogic  -- all bits in shift register transfered
        );
    end component uart_baud;


    --========================================== UART_FILTER =========================================--
    component uart_filter is
        generic (
            config: uart_config := uart_default_config
        );
        port (
            clk:      in std_ulogic; -- clock, rising edge
            reset:    in std_ulogic; -- asynchronous reset
            data_in:  in std_ulogic; -- serial in
            data_out: out std_ulogic -- synced & voted input bit
        );
    end component uart_filter;


    --========================================== UART_TOP =========================================--
    component uart_top is
        generic (
            config: uart_config := uart_default_config
        );
        port (
            clk:                                  in  std_ulogic; -- Clock, rising edge                                                                        
            reset:                                in  std_ulogic; -- Asynchrony reset                                                                          
            rxd:                                  in  std_ulogic; -- Receive data; LSB first                                                                   
            txd:                                  out std_ulogic; -- Transmit register output (START bit, DATA bits, PARITY bit, and STOP bits); LSB First     
            transmitter_holding_register_data_in: in  std_ulogic_vector(config.data_bits - 1 downto 0); -- Transmitter Holding Register Data Input                                                   
            transmitter_holding_load:             in  std_ulogic; -- Transmitter Holding Register Load, one clock cycle high                                   
            receiver_holding_register_data_out:   out std_ulogic_vector(config.data_bits - 1 downto 0); -- Receiver Holding Register Data Output                                                     
            parity_error:                         out std_ulogic; -- Parity error                                                                              
            framing_error:                        out std_ulogic; -- Framing error                                                                             
            data_received:                        out std_ulogic; -- Data Received, one clock cycle high                                                       
            transmitter_holding_register_empty:   out std_ulogic; -- Transmitter Holding Register Empty                                                        
            transmitter_register_empty:           out std_ulogic  -- Transmitter Register Empty                                                                
        );
    end component uart_top;
    
    
end package uart_pkg;

package body uart_pkg is
    
    -- @see: https://www.thecodingforums.com/threads/swapping-bits-in-a-byte.496443/
    function reverse(arg: std_ulogic_vector) return std_ulogic_vector is
        variable result: std_ulogic_vector(arg'reverse_range);
    begin
        for i in arg'range loop
            result(i) := arg(arg'high - i);
        end loop;
        return result;
    end function reverse;

    -- Creates an string with a fixed length, padded with pad
    function parity(constant value: std_ulogic_vector; constant even: boolean) return std_ulogic is
        variable par: std_ulogic;
    begin
        -- Select parity type
        if even then
            par := '0';
        else
            par := '1';
        end if;
        -- Calculate
        for i in value'range loop
            par := par xor value(i);
        end loop;
        return par;
    end function parity;

    -- Returns number of used parity bits
    function numParBit(constant parity_inhibit: boolean := true) return integer is
    begin
        if parity_inhibit then
            return 0;
        end if;
        return 1;
    end function numParBit;
    
end package body uart_pkg;