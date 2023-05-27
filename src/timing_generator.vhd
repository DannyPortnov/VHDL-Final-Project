library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timing_generator is
    generic (
        G_RESET_ACTIVE_VALUE        : std_logic := 0;
        G_PIXELS_PER_LINE           : integer := 800;
        G_PIXELS_PER_FRAME          : integer := 525;
        -- VISIBLE_PIXELS_PER_LINE     : integer := 640;
        -- VISIBLE_PIXELS_PER_FRAME    : integer := 480;
    );
    port (
        CLK         : in  std_logic;
        RST         : in  std_logic;
        H_CNT       : out integer range 0 to PIXELS_PER_LINE-1;
        V_CNT       : out integer range 0 to PIXELS_PER_FRAME-1;
        H_SYNC      : out std_logic;
        V_SYNC      : out std_logic;
        VS          : out std_logic
    );
end entity;

architecture behave of timing_generator is 
    -- Horizontal Timing Constants 
    constant H_visible      : integer:= 640; -- horizontal visible area
    constant H_FP           : integer:= 16;  -- hsync front porch
    constant H_BP           : integer:= 48;  -- hsync back porch
    constant HS_pulse       : integer:= 96;  -- hsync retrace
    -- Vertical Timing Constants
    constant V_visible      : integer:= 480; -- vertical visible area
    constant V_FP           : integer:= 10;  -- vsync front porch
    constant V_BP           : integer:= 33;  -- vsync back porch
    constant VS_pulse       : integer:= 2;   -- vsync retrace


    signal h_cnt_sig		: integer range 0 to G_PIXELS_PER_LINE - 1 	:= 0;	-- This signal counts how much pixles are passed on each line, every 800 pixles cnt_H_pixels = 0.
	signal v_cnt_sig		: integer range 0 to G_PIXELS_PER_FRAME - 1	:= 0; 	-- This signal counts how much lines are passed in pixles units.


    begin
    process(CLK,RST)
    begin
        H_CNT <= h_cnt_sig;
        V_CNT <= v_cnt_sig;

        if RST = G_RESET_ACTIVE_VALUE then   --reset output 
            h_cnt_sig <= 0;
            v_cnt_sig <= 0;
            H_SYNC <= '1';
            V_SYNC <= '1';
            VS <= '0';

        elsif rising_edge(CLK) then
        -- handle horizontal and vertical counters
            if (h_cnt_sig < G_PIXELS_PER_LINE - 1) then
                h_cnt_sig <= h_cnt_sig + 1;
            elsif (h_cnt_sig = G_PIXELS_PER_LINE - 1) then
                h_cnt_sig <= 0;
                if (v_cnt_sig < G_PIXELS_PER_FRAME - 1) then

                    -- need to check if VS is active high just for 1 clk pulse!
                    if (v_cnt_sig = (V_visible + V_FP)) then
                        VS <= '1';
                    else
                        VS <= '0';
                    end if;    
                    
                    v_cnt_sig <= v_cnt_sig + 1;
                
                elsif (h_cnt_sig = G_PIXELS_PER_FRAME - 1) then
                    v_cnt_sig <= 0;
                end if;
            end if;

        -- horizontal sync for 640 pixels
            if (h_cnt_sig >= (H_visible + H_FP) and h_cnt_sig < (G_PIXELS_PER_LINE - H_BP)) then
                H_SYNC <= '0';
            elsif (h_cnt_sig < (H_visible + H_FP) or h_cnt_sig >= (G_PIXELS_PER_LINE - H_BP)) then
                H_SYNC <= '1';
            -- elsif (h_cnt_sig = G_PIXELS_PER_LINE - 1) then
            --     H_SYNC <= '1';                
            end if;

        -- vertical sync for 480 pixels
            if (v_cnt_sig >= (V_visible + V_FP) and v_cnt_sig < (G_PIXELS_PER_FRAME - V_BP)) then
                V_SYNC <= '0';
            elsif (v_cnt_sig < (V_visible + V_FP) or v_cnt_sig >= (G_PIXELS_PER_FRAME - V_BP)) then
                V_SYNC <= '1';
            -- elsif (v_cnt_sig = G_PIXELS_PER_LINE - 1) then
            --     V_SYNC <= '1';
            end if;
        end if;
    end process;
end architecture;


