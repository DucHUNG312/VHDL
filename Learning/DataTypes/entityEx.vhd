library ieee;
use ieee.std_logic_1164.all;

entity entityEx is    -- entityEx is the name of entity
port(
	a, b, c : in std_logic;  -- inputs for encoder
	d       : inout std_logic;  -- inout
	z       : out std_logic  -- out (no ';' in the last declaration)
	);
end entityEx;         -- end entity declaration

architecture arch of entityEx is
	-- assign zero to signal 'a' i.e a = 0000
	signal s0 : std_logic_vector(3 downto 0) := (others => '0');

	-- assign signal 'b' = "0011"
	-- position 0 or 1 = 1, rest 0
	signal s1: std_logic_vector(3 downto 0) := (0|1=>'1', others => '0');

	-- assign signal 'c' = "11110000"
	-- position 7 downto 4 = 1, rest 0
	signal s2 : std_logic_vector(7 downto 0) := (7 downto 4 =>'1', others => '0');
	-- or
	signal s3 : std_logic_vector(7 downto 0) := (4 to 7 =>'1', others => '0');

	-- assign signal 'd' = "01000"
	-- note that d starts from 1 and ends at 5, hence position 2 will be 1.
	signal s4 : std_logic_vector(1 to 5) := (2=>'1', others => '0');
begin
	z <= a and b and c and d; 
end arch;