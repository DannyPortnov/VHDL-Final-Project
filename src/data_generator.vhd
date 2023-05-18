library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.image_processor_package.all;

entity data_generator is
    generic (
        G_RESET_ACTIVE_VALUE        : std_logic := 0;
        PIXELS_PER_LINE             : integer := 800;
        PIXELS_PER_FRAME            : integer := 525;
        VISIBLE_PIXELS_PER_LINE     : integer := 640;
        VISIBLE_PIXELS_PER_FRAME    : integer := 480;
        IMAGE_WIDTH                 : integer := 512;  
        IMAGE_HEIGHT                : integer := 512   

    );
    port (
        CLK         : in  std_logic;
        RST         : in  std_logic;
        ANGLE       : in  integer range 0 to 3;
        IMAGE_ENA   : in  std_logic;
        H_CNT       : in  integer range 0 to PIXELS_PER_LINE-1;
        V_CNT       : in  integer range 0 to PIXELS_PER_FRAME-1;
        SRAM_D      : in  std_logic_vector(15 downto 0);
        SRAM_A      : out std_logic_vector(17 downto 0);
        R_DATA      : out std_logic_vector(7 downto 0);
        G_DATA      : out std_logic_vector(7 downto 0);
        B_DATA      : out std_logic_vector(7 downto 0);
        DATA_DE     : out std_logic
    );
end entity;

architecture behave of data_generator is 
    -- Constants declarations
    constant zero_deg                    : integer := 0 
    constant ninety_deg                  : integer := 1 
    constant hundred_eighty_deg          : integer := 2 
    constant two_hunderd_seventy_deg     : integer := 3 
    -- Signal declarations
    signal rot_h_count      : integer range 0 to IMAGE_HEIGHT - 1;
    signal rot_v_count      : integer range 0 to IMAGE_WIDTH - 1;
    signal start_h          : integer range 0 to VISIBLE_PIXELS_PER_LINE - IMAGE_WIDTH;
    signal start_v          : integer range 0 to VISIBLE_PIXELS_PER_FRAME - IMAGE_HEIGHT;


begin
    process(CLK,RST)
    begin
        
        if RST = G_RESET_ACTIVE_VALUE then   --reset output 
            rot_h_count <= 0;
            rot_v_count <= 0;
            start_h <= 0;
            start_v <= 0;
        elsif rising_edge(CLK) then

            -- Check if the pixel is within the visible area
            if (H_CNT < VISIBLE_PIXELS_PER_LINE) and (V_CNT < VISIBLE_PIXELS_PER_FRAME) then
            -- the pixel is inside the visible area
                DATA_DE <= '1';
            else
            -- the pixel is not in the visible area -> blank
                DATA_DE <= '0';     
            end if;

        -- Determine the rotated coordinates based on the selected rotation angle
            case ANGLE is
                when zero_deg =>
                    rot_h_count <= H_CNT;
                    rot_v_count <= V_CNT;

                when ninety_deg =>
                    rot_h_count <= V_CNT;
                    rot_v_count <= IMAGE_WIDTH - H_CNT - 1;
                
                when hundred_eighty_deg =>
                    rot_h_count <= IMAGE_WIDTH - H_CNT - 1;
                    rot_v_count <= IMAGE_HEIGHT - V_CNT - 1;
                
                when two_hunderd_seventy_deg =>
                    rot_h_count <= IMAGE_HEIGHT - V_CNT - 1;
                    rot_v_count <= H_CNT;
                
                when others =>
                    rot_h_count <= 0;
                    rot_v_count <= 0;
            end case;

        -- Calculate the starting coordinates to center the picture
            -- using shift register by shifting the division to the right by 1 position, effectively dividing them by 2.
            start_h <= to_integer(unsigned(VISIBLE_PIXELS_PER_LINE - IMAGE_WIDTH) shr 1);
            start_v <= to_integer(unsigned(VISIBLE_PIXELS_PER_FRAME - IMAGE_HEIGHT) shr 1);

        -- Apply the starting coordinates offset
            rot_h_count <= rot_h_count + start_h;
            rot_v_count <= rot_v_count + start_v;


            if IMAGE_ENA = '0' then
                --color bar is displayed

            elsif IMAGE_ENA = '1' then
                -- image from the memory is displayed 
                -- Access the corresponding pixel from SRAM using the rotated coordinates
                SRAM_A <= std_logic_vector(to_unsigned(rot_v_count * IMAGE_WIDTH + rot_h_count, SRAM_A'length));
                R_DATA <= convert_to_eight_bit(to_integer(unsigned(SRAM_D(4 downto 0)));)
                G_DATA <= convert_to_eight_bit(to_integer(unsigned(SRAM_D(10 downto 5)));)
                B_DATA <= convert_to_eight_bit(to_integer(unsigned(SRAM_D(15 downto 11)));)
            end if;

        end if;
    end process;
end architecture;



