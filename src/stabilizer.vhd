library ieee;
use ieee.std_logic_1164.all;
entity stabilizer is

port ( 
	
	D_IN        : in  std_logic;
	CLK         : in  std_logic; 
	RST         : in  std_logic;
	Q_OUT       : out std_logic
);
end entity;

architecture behave of stabilizer is
	signal D2_Q1  : std_logic;
	
begin

	process(RST, CLK)
	
	begin
		if RST = '0' then
			D2_Q1 <= '1';
			Q_OUT <= '1';
		elsif rising_edge(CLK) then 
			Q_OUT <= D2_Q1;
			D2_Q1 <= D_IN;
		end if;
		
	end process;	
end architecture;