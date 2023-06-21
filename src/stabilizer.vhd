library ieee;
use ieee.std_logic_1164.all;
entity stabilizer is

generic (
	G_RESET_ACTIVE_VALUE    : std_logic := '0' -- ; -- Determines the RST input polarity. 
												-- 0 – the RST input is active low 
												-- 1 – the RST input is active high
	-- G_INITIAL_STATE : std_logic := '0' -- Determines the initial state of the input.
);
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
		if RST = G_RESET_ACTIVE_VALUE then
			-- D2_Q1 <= G_INITIAL_STATE;
			-- Q_OUT <= G_INITIAL_STATE;
			D2_Q1 <= '0';
			Q_OUT <= '0';
		elsif rising_edge(CLK) then 
			Q_OUT <= D2_Q1;
			D2_Q1 <= D_IN;
		end if;
		
	end process;	
end architecture;