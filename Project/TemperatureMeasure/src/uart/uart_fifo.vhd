-- =============================================================================
-- AUTHOR:          Le Vu Duc Hung
--
-- DATE:            12/06/2023
--
-- FILE:            uart_fifo.vhd
--
-- DESCRIPTION:     UART FIFO Implementation
--                  This file contains the implementation of a FIFO (First-In,
--                  First-Out) buffer for UART communication. It is used for storing
--                  incoming and outgoing data in a sequential manner, ensuring that
--                  the order of data transmission is preserved. The FIFO has separate
--                  write and read pointers to manage data transfers and track the
--                  occupancy level of the buffer. The fullness and emptiness of the
--                  FIFO can be determined using the 'full' and 'empty' signals, while
--                  the current level of data can be accessed through the 'level' signal.
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

entity uart_fifo is
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
end entity uart_fifo;

architecture rtl of uart_fifo is
    type memory is array (0 to config.fifo_depth - 1) of std_ulogic_vector(config.fifo_width - 1 downto 0);
    
    signal fifo_memory: memory     := (others => (others => '0'));
    signal read_pointer, write_pointer: unsigned(integer(ceil(log2(real(config.fifo_depth)))) - 1 downto 0) := (others => '0');
    signal fifo_empty:  std_ulogic := '1';
    signal fifo_full:   std_ulogic := '0';
begin
    full <= fifo_full;
    empty <= fifo_empty;

    FIFO_FLAGS : process(write_pointer, read_pointer) is
        variable fifo_level: integer range 0 to config.fifo_depth - 1;
    begin
        fifo_level := get_fifo_level(write_pointer, read_pointer, config.fifo_depth);
        level <= std_ulogic_vector(to_unsigned(fifo_level, level'length));

        if fifo_level = config.fifo_depth - 1 then
            fifo_full <= '1';
        else 
            fifo_full <= '0';
        end if;

        if fifo_level = 0 then
            fifo_empty <= '1';
        else 
            fifo_empty <= '0';
        end if;
    end process; -- FIFO_FLAGS

    FIFO_LOGIC : process(clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                write_pointer <= (others => '0');
                read_pointer  <= (others => '0');
            else
                -- FIFO WRITE
                if write_enable = '1' and fifo_full = '0' then
                    fifo_memory(to_integer(write_pointer)) <= write_data;
                    if write_pointer < config.fifo_depth - 1 then
                        write_pointer <= write_pointer + 1;
                    else
                        write_pointer <= (others => '0');
                    end if;
                end if;
                -- FIFO READ
                if read_enable = '1' and fifo_empty = '0' then
                    if read_pointer < config.fifo_depth - 1 then
                        read_pointer <= read_pointer + 1;
                    else
                        read_pointer <= (others => '0');
                    end if;
                end if;
            end if;
        end if;

        read_data <= fifo_memory(to_integer(read_pointer));
    end process ; -- FIFO_LOGIC

end architecture rtl;
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        