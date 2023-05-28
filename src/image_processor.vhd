library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity image_processor is
generic (
    G_VAL_1SEC    : integer := 25000000 -- In CLK units (1 [sec in ns] / 40 [ns, 1 clock period]) 
);
port (
                            -- System Signals --
	CLK 	    : in  std_logic; -- System clock. 50MHz
	RSTn 	    : in  std_logic; -- Active low system reset. Connect to KEY0
                                -- USER Signals --
    KEY_ROTATE    : in  std_logic;  -- Rotate the image. Rotation direction according to SW_ROTATION_DIR
                                    -- Short press (<2sec) – Rotate 90° CW or CCW according to SW_ROTATION_DIR.
                                    -- Long press (≥2sec) – Rotate 90° CW or CCW according to SW_ROTATION_DIR every 1 sec as long as this key is pressed.
                                    -- Connect to KEY3.
    SW_ROTATION_DIR    : in  std_logic; -- 0 – Rotate CW.
                                        -- 1 – Rotate CCW.
                                        -- Connect to SW2.
    SW_IMAGE_ENA   : in  std_logic; -- 0 – Show color bar.
                                    -- 1 – Show image from SRAM.
                                    -- Connect to SW9.
    SW_MODE   : in  std_logic;  -- 0 – Normal mode
                                -- 1 – Automatic rotation, each 1 sec. Direction according to SW_ROTATION_DIR.
                                -- Connect to SW4.
                            -- SRAM Signals --
    SRAM_A   : out std_logic_vector(17 downto 0) -- SRAM address
    SRAM_D   : in std_logic_vector(15 downto 0) -- SRAM data
    SRAM_CEn : out std_logic -- SRAM chip enable. Should be always enabled.
    SRAM_OEn : out std_logic -- SRAM output enable. Should be always enabled.
    SRAM_WEn  : out std_logic -- SRAM write enable. Should be always disabled.
    SRAM_UBn  : out std_logic -- SRAM upper byte enable. Should be always disabled.
    SRAM_LBn  : out std_logic -- SRAM lower byte enable. Should be always disabled. 
                        -- HDMI Signals --                 
    HDMI_TX     : out std_logic_vector(23 downto 0);    -- 24-bit RGB pixel data to the HDMI controller.
                                                        -- HDMI_TX(23:16) – RED data
                                                        -- HDMI_TX(15:8) – GREEN data
                                                        -- HDMI_TX(7:0) – BLUE data
    HDMI_TX_VS  : out std_logic; -- Vertical sync signal to the HDMI controller.
    HDMI_TX_HS  : out std_logic; -- Horizontal sync signal to the HDMI controller.
    HDMI_TX_DE  : out std_logic;    -- Data enable signal to the HDMI controller.
                                      -- Should be 1 while in visible area and 0 during blanking time.
    HDMI_TX_CLK  : out std_logic; -- 25MHz clock signal to the HDMI controller.
);
end entity;
architecture behave of image_processor is 
    component stabilizer is                -- This is the component declaration.
    port ( 
        D_IN        : in  std_logic;
        CLK         : in  std_logic; 
        RST         : in  std_logic;
        Q_OUT       : out std_logic
    );
    end component;

    component st_mach is                -- This is the component declaration.
    port ( 
        RST   : in    std_logic; -- Asynchronous system reset, active low
        CLK   : in    std_logic; -- System clock
        A     : in    std_logic;
        B     : in    std_logic;
        CAR   : out   std_logic  
    );
    end component;

    component free_place_cnt is                -- This is the component declaration.
    generic (
        TOTAL_PLACES    : integer := 15
    );
    port (
        CLK         : in  std_logic;
        RST         : in  std_logic;
        CAR_IN      : in  std_logic;
        CAR_OUT     : in  std_logic;
        ONES        : out std_logic_vector(3 downto 0) := std_logic_vector(to_unsigned(TOTAL_PLACES mod 10, 4));
        TENS        : out std_logic_vector(3 downto 0) := std_logic_vector(to_unsigned((TOTAL_PLACES/10) mod 10, 4))
    );
    end component;

    component bcd_to_7seg is                -- This is the component declaration.
    port (
        BCD_IN : in   integer range 0 to 9;
        D_OUT  : out  std_logic_vector(6 downto 0)
    );
    end component;

    signal stabilizer_a_output_sig      : std_logic;
    signal stabilizer_b_output_sig      : std_logic;
    signal car_in_output_sig            : std_logic;
    signal car_out_output_sig           : std_logic;
    signal free_place_ones_output_sig   : std_logic_vector(3 downto 0);
    signal free_place_tens_output_sig   : std_logic_vector(3 downto 0);
    signal ones_7seg_input_sig          : integer range 0 to 9;
    signal tens_7seg_input_sig          : integer range 0 to 9;

begin
    
    ones_7seg_input_sig <= to_integer(unsigned(free_place_ones_output_sig)); -- Convert vector to integer
    tens_7seg_input_sig <= to_integer(unsigned(free_place_tens_output_sig));


    car_in_sm: st_mach  -- This is the component instantiation. car_in_sm is the instance name of the component st_mach
    port map ( 
        RST  => RST,
        CLK  => CLK,
        A    => stabilizer_a_output_sig,
        B    => stabilizer_b_output_sig,
        CAR  => car_in_output_sig
    );

    car_out_sm: st_mach  -- This is the component instantiation. car_out_sm is the instance name of the component st_mach
    port map ( 
        RST  => RST,
        CLK  => CLK,
        A    => stabilizer_b_output_sig,
        B    => stabilizer_a_output_sig,
        CAR  => car_out_output_sig
    );

    stabilizer_a: stabilizer            -- This is the component instantiation. stabilizer_a is the instance name of the component stabilizer
    port map (
        RST                 => RST,                         -- The RST input of the stabilizer_a instance of the stabilizer-a component is connected to RST
        CLK                 => CLK,                         -- The CLK input of the stabilizer_a instance of the stabilizer-a component is connected to CLK
        D_IN                => SENSOR_A,                    -- The D_IN input of the stabilizer_a instance of the stabilizer-a component is connected to SENSOR_A
        Q_OUT               => stabilizer_a_output_sig      -- The Q_OUT output of the stabilizer_a instance of the stabilizer-a component is connected to stabilizer_a_output_sig
    );

    stabilizer_b: stabilizer            -- This is the component instantiation. stabilizer_a is the instance name of the component stabilizer
    port map (
        RST                 => RST, 
        CLK                 => CLK, 
        D_IN                => SENSOR_B, 
        Q_OUT               => stabilizer_b_output_sig     -- outputs can be left opened
    );

    free_place_counter: free_place_cnt  -- This is the component instantiation. free_place_counter is the instance name of the component free_place_cnt
    generic map (
        TOTAL_PLACES    => G_TOTAL_PLACES
    )
    port map (
        RST             => RST, 
        CLK             => CLK, 
        CAR_IN          => car_in_output_sig, 
        CAR_OUT         => car_out_output_sig, 
        ONES            => free_place_ones_output_sig, 
        TENS            => free_place_tens_output_sig
    );

    ones_to_7seg: bcd_to_7seg             -- This is the component instantiation. ones_7seg is the instance name of the component bcd_to_7seg                  
    port map (
        BCD_IN  => ones_7seg_input_sig,
        D_OUT   => ONES_7SEG
    );

    tens_to_7seg: bcd_to_7seg             -- This is the component instantiation. tens_7seg is the instance name of the component bcd_to_7seg                  
    port map (
        BCD_IN  => tens_7seg_input_sig,
        D_OUT   => TENS_7SEG
    );


end architecture;