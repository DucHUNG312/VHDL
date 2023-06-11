library ieee;
use ieee.std_logic_1164.all;

-- Random number generation with LFSR
-- Feedback polynomial : x^3 + x^2 + 1 
-- maximum length : 2^3 - 1 = 7

-- if generic value is changed, then choose the correct Feedback polynomial i.e. change 'feedback_value' pattern
 
entity rand_num_generator is 
	generic(
		N : integer := 3
	);
	port(
		clk, reset : in std_logic;
		q 			  : out std_logic_vector(N downto 0)
	);
end entity;

architecture arch of rand_num_generator is
	signal r_reg, r_next  : std_logic_vector(N downto 0);
	signal feedback_value : std_logic; -- based on feedback polynomial
begin
	process(clk, reset)
	begin
		if(reset='1') then
			-- set initial value to '1'
			r_reg(0) <= '1';
			r_reg(N downto 1) <= (others=>'0');
		elsif(clk'event and clk='1') then
			r_reg <= r_next;
		end if;
	end process;
	
	-- N = 3
   -- Feedback polynomial : x^3 + x^2 + 1 
   -- total sequences (maximum) : 2^3 - 1 = 7
	feedback_value <= r_reg(3) xor r_reg(2) xor r_reg(0);
	
	r_next <= feedback_value & r_reg(N downto 1);
	q <= r_reg;
end architecture;