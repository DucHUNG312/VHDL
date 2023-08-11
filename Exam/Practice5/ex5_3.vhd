library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ex5_3 is
    port (
        ascii_code: in std_logic_vector(7 downto 0);
        clk: in std_logic;
        flag: out std_logic
    );
end entity ex5_3;

architecture rtl of ex5_3 is 
    type stateMoore_type is (Init, V, VH, VHD, VHDL);
    signal stateMoore_reg, stateMoore_next : stateMoore_type;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            stateMoore_reg <= stateMoore_next;
        end if;
    end process; 

    process(ascii_code, stateMoore_reg)
    begin
        stateMoore_next <= stateMoore_reg;
        flag <= '0';
        case stateMoore_reg is 
        when Init => 
            if ascii_code = "01010110" then -- V
                stateMoore_next <= V;
            end if; 
        when V => 
            if ascii_code = "01001000" then -- H
                stateMoore_next <= VH;
            elsif ascii_code /= "01010110" then -- V
                stateMoore_next <= Init;
            end if; 
        when VH =>
            if ascii_code = "01000100" then -- D
                stateMoore_next <= VHD;
            elsif ascii_code = "01010110" then -- V
                stateMoore_next <= V;
            else
                stateMoore_next <= Init;
            end if; 
        when VHD =>
            if ascii_code = "01001100" then -- L
                stateMoore_next <= VHDL;
            elsif ascii_code = "01010110" then -- V
                stateMoore_next <= V;
            else
                stateMoore_next <= Init;
            end if; 
        when VHDL =>
            flag <= '1';
            if ascii_code = "01010110" then -- V
                stateMoore_next <= V;
            else
                stateMoore_next <= Init;
            end if; 
        end case;
    end process;
end architecture rtl;