library ieee;
use ieee.std_logic_1164.all;
entity push_button_if is

generic (
    G_RESET_ACTIVE_VALUE    : std_logic := 0    --Determines the RST input polarity. 
                                                -- 0 – the RST input is active low 
                                                -- 1 – the RST input is active high 
);

port ( 
    RST         : in    std_logic;  -- Asynchronous reset. Active value according to G_RESET_ACTIVE_VALUE
    CLK         : in    std_logic;  -- System clock 25MHz
    ANGLE       : in    std_logic;  -- The angle of the displayed image 
                                -- 0 - 0° 
                                -- 1 - 90° 
                                -- 2 - 180° 
                                -- 3 - 270°
    IMAGE_ENA   : in    std_logic; 0 – Color bar is displayed   
                                -- 1 – Image from the memory is 
                                -- displayed
    CAR   : out   std_logic  
);
end entity;

architecture behave of push_button_if is
    type car_states_machine is (
        Idle,
        Enter,
        St1,
        St2,
        St3
    );
    signal car_sm : car_states_machine;
    --signal current_input : std_logic_vector(1 downto 0); -- MSB: A, LSB: B
begin
	process(RST, CLK)
	begin
		if RST = '0' then
			CAR <= '0';
		elsif rising_edge(CLK) then
            CAR <= '0';
            --current_input <= A & B;
			case car_sm is
                when Idle =>
                    if (A = '0' and B = '1') then
                        car_sm <= St1;
                    end if;
                when Enter =>
                    car_sm <= Idle;
                when St1 =>
                    if (A = '0' and B = '0') then
                        car_sm <= St2;
                    elsif (A = '0' and B = '1') then
                        car_sm <= St1;
                    else
                        car_sm <= Idle;
                    end if;
                when St2 =>
                    if (A = '1' and B = '0') then
                        car_sm <= St3;
                    elsif (A = '0' and B = '0') then
                        car_sm <= St2;
                    else
                        car_sm <= Idle;
                    end if;
                when St3 =>
                    if (A = '1' and B = '1') then
                        car_sm <= Enter;
                        CAR <= '1';
                    elsif (A = '1' and B = '0') then
                        car_sm <= St3;
                    else
                        car_sm <= Idle;
                    end if;
                -- when others =>
                --     CAR <= Idle;
            end case;
		end if;
	end process;	
end architecture;