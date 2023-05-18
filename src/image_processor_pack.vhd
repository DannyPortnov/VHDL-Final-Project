library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package image_processor_pack is
    constant G_PIXELS_NUM     integer := 64;
    constant R_B_PIXELS_NUM   integer := 32;
    constant R_B_CONV_PARAM   real    := 8.225806452;
    constant G_CONV_PARAM     real    := 4.047619048;
    -- function that converts color from L<=8 bit to 8 bit representation
    function convert_to_eight_bit (clr_data : integer range 0 to G_PIXELS_NUM)    return std_logic_vector(7 downto 0);


end package;


package body image_processor_pack is   
    function convert_to_eight_bit (clr_data : integer range 0 to G_PIXELS_NUM)    return std_logic_vector(7 downto 0) is
        
        variable clr_conv : std_logic_vector(7 downto 0);

    begin
        if (clr_data < R_B_PIXELS_NUM) and (clr_data >= 0) then
            clr_conv <= std_logic_vector(to_unsigned(clr_data * integer(floor(real(255)/real(R_B_CONV_PARAM))) , clr_conv'length)); 
        
        elsif (clr_data >= R_B_PIXELS_NUM) and (clr_data < G_PIXELS_NUM) then
            clr_conv <= std_logic_vector(to_unsigned(clr_data * integer(floor(real(255)/real(G_CONV_PARAM))) , clr_conv'length)); 
        end if;
        return (clr_conv);
    end convert_to_eight_bit;





end package body;
