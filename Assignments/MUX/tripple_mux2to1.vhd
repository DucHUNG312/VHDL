library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mux2to1.all;

entity tripple_mux2to1 is
	port(
		clk :  in std_logic;
		d   :  in std_logic;
		q   : out std_logic
	);
end entity;

architecture arch of tripple_mux2to1 is
	signal q1, q2, q3 : std_logic;
begin
	process(clk)
	begin
		-- instantiate Mod-M counter
		mux2to1_bottom : entity work.mux2to1
		port map (w0=>d, w1=>q2, s=>clk, f=>q2);
		
		mux2to1_top : entity work.mux2to1
		port map (w0=>q1, w1=>d, s=>clk, f=>q1);
		
		mux2to1_right : entity work.mux2to1
		port map (w0=>q1, w1=>q2, s=>clk, f=>q3);
	end process;
	
	q <= q3;
end architecture;

