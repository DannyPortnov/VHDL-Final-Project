library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package image_processor_pack is
    constant C_PIXELS_PER_LINE		  : integer := 800;
	constant C_PIXELS_PER_FRAME	      : integer := 525;
    constant MAX_BITS                 : integer := 255;
    constant G_PIXELS_NUM             : integer := 64;

    constant C_RESET_ACTIVE_VALUE     : std_logic := '0';
    constant C_BUTTON_NORMAL_STATE    : std_logic := '1';
    constant C_PRESS_TIMOUT_VAL       : integer := 200;
    constant C_TIME_BETWEEN_PULSES    : integer := 100;

    constant VISIBLE_PIXELS_PER_LINE  : integer := 640;
    constant VISIBLE_PIXELS_PER_FRAME : integer := 480;
    -- IMAGE CONSTANTS --
    constant IMAGE_WIDTH              : integer := 512;
    constant IMAGE_HEIGHT             : integer := 512;
    
    constant IMAGE_H_OFFSET           : integer := (VISIBLE_PIXELS_PER_LINE - IMAGE_WIDTH) / 2;
    constant IMAGE_V_OFFSET           : integer := (IMAGE_HEIGHT - VISIBLE_PIXELS_PER_FRAME) / 2;
   
    constant IMAGE_H_START            : integer := IMAGE_H_OFFSET;
    constant IMAGE_H_END              : integer := VISIBLE_PIXELS_PER_LINE - IMAGE_H_OFFSET - 1;     
  
    constant IMAGE_V_START            : integer := 0;
    constant IMAGE_V_END              : integer := VISIBLE_PIXELS_PER_FRAME - 1;
    -- COLOR BAR CONSTANTS --
    constant COLOR_SEGMENTS           : integer := 8; -- number of segments in color bar

    -- function that converts color from L<=8 bit to 8 bit representation
    function color_convert (P_in: std_logic_vector) return std_logic_vector;
                                   
end package;


package body image_processor_pack is   
       
    function color_convert (P_in: std_logic_vector) return std_logic_vector is
        constant P_in_to_int : integer range 0 to G_PIXELS_NUM := to_integer(unsigned(P_in));
        constant P_in_length : integer range 0 to P_in'length := P_in'length;
        variable color_conv : std_logic_vector(7 downto 0);
        
    begin
        color_conv := std_logic_vector(to_unsigned((P_in_to_int*(MAX_BITS/(2**(P_in_length) - 1))), color_conv'length)); 
        return (color_conv);
    end color_convert;


end package body;



