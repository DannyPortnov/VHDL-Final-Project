library ieee;
use ieee.std_logic_1164.all;
--use WORK.image_processor_pack.all;

entity controller is

generic (
    G_RESET_ACTIVE_VALUE    : std_logic := '0'; -- Determines the RST input polarity. 
                                                -- 0 – the RST input is active low 
                                                -- 1 – the RST input is active high
    G_VAL_1SEC              : integer := 25000000 -- In CLK units (1 [sec in ns] / 40 [ns, 1 clock period])
);
port ( 
    RST             : in std_logic;     -- Asynchronous reset. Active value according to G_RESET_ACTIVE_VALUE
    CLK             : in std_logic;     -- System clock 25MHz
    ROTATE          : in std_logic;     -- Active high, 1 CLK duration rotate request
    ROTATION_DIR    : in std_logic;     -- 0 – CW rotation direction 
                                        -- 1 – CCW rotation direction
    VS              : in std_logic;     -- Active high 1 CLK duration pulse 
                                        -- indication V_SYNC falling edge. 
    MODE            : in std_logic;     -- 0 – Manual rotation mode 
                                        -- 1 – Automatic rotation mode
    
    ANGLE           : out integer range 0 to 3;  --The angle of the displayed image
                                                -- 0 - 0° 
                                                -- 1 - 90° 
                                                -- 2 - 180° 
                                                -- 3 - 270°
    HEX0            : out std_logic_vector(6 downto 0); -- The unity digit of the image angle
    HEX1            : out std_logic_vector(6 downto 0); -- The tens digit of the image angle
    HEX2            : out std_logic_vector(6 downto 0); -- The hundreds digit of the image angle
    HEX3            : out std_logic_vector(6 downto 0) -- Should be OFF
);

end entity;

architecture behave of controller is
    signal angle_sig               : integer range 0 to 3 := 0;
    signal counter                 : integer range 0 to G_VAL_1SEC + 1 := 0;
    signal rotate_sig              : std_logic := '0';
    constant BASE_ANGLE            : integer := 90;
    signal unity_bcd_out           : std_logic_vector(6 downto 0);
    signal tens_bcd_of_90_out      : std_logic_vector(6 downto 0);
    signal tens_bcd_of_180_out     : std_logic_vector(6 downto 0);
    signal tens_bcd_of_270_out     : std_logic_vector(6 downto 0);
    signal hundreds_bcd_of_270_out : std_logic_vector(6 downto 0);
    signal hundreds_bcd_of_180_out : std_logic_vector(6 downto 0);

    component bcd_to_7seg is
        port (
            BCD_IN : in   integer range 0 to 9;
            D_OUT  : out  std_logic_vector(6 downto 0)
        );
        end component;
begin

    unity_bcd: bcd_to_7seg port map(BCD_IN => 0,D_OUT => unity_bcd_out); 
    tens_bcd_of_90: bcd_to_7seg port map(BCD_IN => 9,D_OUT => tens_bcd_of_90_out); 
    tens_bcd_of_180: bcd_to_7seg port map(BCD_IN => 8,D_OUT => tens_bcd_of_180_out); 
    tens_bcd_of_270: bcd_to_7seg port map(BCD_IN => 7,D_OUT => tens_bcd_of_270_out);
    hundreds_bcd_of_270: bcd_to_7seg port map(BCD_IN => 2,D_OUT => hundreds_bcd_of_270_out); 
    hundreds_bcd_of_180: bcd_to_7seg port map(BCD_IN => 1,D_OUT => hundreds_bcd_of_180_out);

    process(RST, CLK)
    begin
        if RST = G_RESET_ACTIVE_VALUE then
            angle_sig <= 0;
            counter <= 0;
            rotate_sig <= '0';
            HEX0 <= (others => '1'); -- Turn off all 7-segment displays when RST is active
            HEX1 <= (others => '1');
            HEX2 <= (others => '1');
        elsif rising_edge(CLK) then
            if MODE = '1' then
                counter <= counter + 1;
                if counter = G_VAL_1SEC then
                    rotate_sig <= '1';
                    counter <= 0;
                else
                    rotate_sig <= '0';
                end if;
            else
                rotate_sig <= ROTATE;
            end if;

            if rotate_sig = '1' then
                if ROTATION_DIR = '1' then
                    if angle_sig = 3 then
                        angle_sig <= 0;
                    else
                        angle_sig <= angle_sig + 1;
                    end if;
                else
                    if angle_sig = 0 then
                        angle_sig <= 3;
                    else
                        angle_sig <= angle_sig - 1;
                    end if;
                end if;
                end if;
            if VS = '1' then
                HEX0 <= unity_bcd_out; -- Always 0 actually
                HEX1 <= (others => '1'); -- Turned off at first by default, then turned on in case of 90°, 180° or 270°
                HEX2 <= (others => '1'); 
                case angle_sig is
                    when 0 =>
                        null;
                    when 1 =>
                        HEX1 <= tens_bcd_of_90_out;
                    when 2 =>
                        HEX1 <= tens_bcd_of_180_out;
                        HEX2 <= hundreds_bcd_of_180_out;
                    when others => -- 3 (270)
                        HEX1 <= tens_bcd_of_270_out;
                        HEX2 <= hundreds_bcd_of_270_out;
                end case;
            end if;
        end if;
    end process;

    ANGLE <= angle_sig;
    HEX3 <= (others => '1');
end behave;


