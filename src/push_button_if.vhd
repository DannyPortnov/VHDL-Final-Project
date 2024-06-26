library ieee;
use ieee.std_logic_1164.all;
entity push_button_if is

generic (
    G_RESET_ACTIVE_VALUE    : std_logic := '0';   -- Determines the RST input polarity. 
                                                -- 0 – the RST input is active low 
                                                -- 1 – the RST input is active high
    G_BUTTON_NORMAL_STATE   : std_logic := '0';   -- The state of the push button when not pressed 
    G_PRESS_TIMOUT_VAL      : integer   := 200; -- Long press value in 10ms units 
    G_TIME_BETWEEN_PULSES   : integer   := 100  -- In 10ms units
);
port ( 
    RST         : in std_logic;     -- Asynchronous reset. Active value according to G_RESET_ACTIVE_VALUE
    CLK         : in std_logic;     -- System clock 25MHz
    SW_IN       : in std_logic;     -- Push button input
    PRESS_OUT   : out std_logic    -- Outputs active high, 1 CLK duration 
                                    -- pulse when the pushbutton is pressed. 
                                    -- If the button is pressed for more than 
                                    -- 2sec, this port shall output pulses each 
                                    -- 1 sec as long as the button is 
                                    -- pressed.  
);
end entity;

architecture behave of push_button_if is
    constant C_RISING_EDGES_IN_10MS    : integer := 250000; --  10,000,000 [10ms in ns] / 40 [ns, 1 clock period] = 250,000 (amount of rising edges occuring in 10ms) 
    constant C_PRESS_TIMEOUT           : integer := G_PRESS_TIMOUT_VAL * C_RISING_EDGES_IN_10MS; -- Rising edges counter untill timeout
    constant C_TIME_BETWEEN_PULSES     : integer := G_TIME_BETWEEN_PULSES * C_RISING_EDGES_IN_10MS; -- Rising edges counter between pulses
    signal timeout_counter             : integer range 0 to C_PRESS_TIMEOUT + 1;
    signal time_between_pulses_counter : integer range 0 to C_TIME_BETWEEN_PULSES + 1;
    signal press_out_reg               : std_logic;
begin
    process (RST, CLK)
    begin
        if RST = G_RESET_ACTIVE_VALUE then
            timeout_counter <= 0;
            time_between_pulses_counter <= 0;
            press_out_reg <= '0';
        elsif rising_edge(CLK) then
            if SW_IN = G_BUTTON_NORMAL_STATE then
                timeout_counter <= 0;
                time_between_pulses_counter <= 0;
                press_out_reg <= '0';
            else
                if timeout_counter = C_PRESS_TIMEOUT then
                    if time_between_pulses_counter = 0 then
                        press_out_reg <= '1';
                    else
                        press_out_reg <= '0';
                    end if;
                    time_between_pulses_counter <= time_between_pulses_counter + 1;
                    if time_between_pulses_counter = C_TIME_BETWEEN_PULSES then -- If reached max value, reset counter
                        time_between_pulses_counter <= 0; -- Value is updated AFTER the process is done, so we actually check max value - 1
                    end if;
                else
                    if timeout_counter = 0 then -- When pressing for the first time, output a pulse immediately (1 clock cycle)
                        press_out_reg <= '1';
                    else
                        press_out_reg <= '0';
                    end if;
                    timeout_counter <= timeout_counter + 1;
                end if;
            end if;
        end if;
    end process;

    PRESS_OUT <= press_out_reg;

end behave;

