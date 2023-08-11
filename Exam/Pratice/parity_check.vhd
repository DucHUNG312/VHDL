library ieee;
use ieee.std_logic_1164.all;

entity parity_check is
port(
    X : in std_logic_vector(8 downto 0);
    Y : out std_logic
);
end parity_check;

architecture parity_check_arch of parity_check is
    signal T : std_logic_vector((X'high)+1 downto 0);
begin  
    T(0) <= '0';    
    G1: for i in X'range generate
        T(i+1) <= T(i) xor X(i);
    end generate;
    Y <= T(T'high);
end parity_check_arch;