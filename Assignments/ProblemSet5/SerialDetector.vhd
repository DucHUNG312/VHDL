-- Created by   :   Le Vu Duc Hung
-- Date         :   7-Jun-23

library ieee;
use ieee.std_logic_1164.all;
entity SerialDetector is
    port(
        clk : in std_logic;
        ASCII : in std_logic_vector(7 downto 0) := "00000000";
        flag : out std_logic
    );
end entity;
architecture arch of SerialDetector is
    type type_fstate is (state1,state2,state3,state4,state5);
    signal fstate : type_fstate;
    signal reg_fstate : type_fstate;
    signal reg_flag : std_logic := '0';
begin
    process (clk,reg_fstate)
    begin
        if (clk'event and clk='1') then
            fstate <= reg_fstate;
        end if;
    end process;
    process(fstate,ASCII,reg_flag)
    begin
			reg_flag <= '0';
			flag <= '0';
			case fstate is
				 when state1 =>
					  if ((ASCII(7 downto 0) = "01010110")) then
							reg_fstate <= state2;
					  else
							reg_fstate <= state1;
					  end if;

					  reg_flag <= '0';
				 when state2 =>
					  if ((ASCII(7 downto 0) = "01001000")) then
							reg_fstate <= state3;
					  else
							reg_fstate <= state1;
					  end if;

					  reg_flag <= '0';
				 when state3 =>
					  if ((ASCII(7 downto 0) = "01000100")) then
							reg_fstate <= state4;
					  else
							reg_fstate <= state1;
					  end if;

					  reg_flag <= '0';
				 when state4 =>
					  if ((ASCII(7 downto 0) = "01001100")) then
							reg_fstate <= state5;
					  else
							reg_fstate <= state1;
					  end if;

					  reg_flag <= '0';
				 when state5 =>
					  reg_flag <= '1';
					  if ((ASCII(7 downto 0) = "01010110")) then
							reg_fstate <= state2;
					  else
							reg_fstate <= state1;
					  end if;
				 when others => 
					  reg_flag <= 'X';
					  report "Reach undefined state";
			end case;
			flag <= reg_flag;
    end process;
end architecture;