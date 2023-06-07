library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

entity hdmi_gen is
  port (
    HDMI_TX    : in std_logic_vector(23 downto 0);
    HDMI_TX_VS : in std_logic;
    HDMI_TX_HS : in std_logic;
    HDMI_TX_DE : in std_logic;
    HDMI_TX_CLK: in std_logic
  );
end entity hdmi_gen;

architecture rtl of hdmi_gen is
  type pixel_buffer is array (natural range <>, natural range <>) of std_logic_vector(23 downto 0);
  signal image_buffer : pixel_buffer(0 to 639, 0 to 479);
begin
  process(HDMI_TX_CLK)
    file image_file : text;
    variable line_buf : line;
    variable pixel_str : string(1 to 24);
  begin
    if rising_edge(HDMI_TX_CLK) then
      if HDMI_TX_HS = '1' and HDMI_TX_VS = '1' then
        for i in 0 to 639 loop
          for j in 0 to 479 loop
            image_buffer(i, j) <= HDMI_TX;
          end loop;
        end loop;

        -- Open the text file for writing
        file_open(image_file, "C:/Users/user/OneDrive - ort braude college of engineering/B.sc/Year 4/Semester B/VHDL/Final Project/VHDL-Final-Project/sim/image.txt", write_mode);

        -- -- Write the buffer data to the text file
        -- for j in 0 to 479 loop
        --   for i in 0 to 639 loop
        --     -- Convert the std_logic_vector to string
        --     for k in 0 to 23 loop
        --       pixel_str(k+1) := std_logic'image(image_buffer(i, j)(k));
        --     end loop;
        --     write(line_buf, pixel_str);
        --     writeline(image_file, line_buf);
        --   end loop;
        -- end loop;

       -- Write the buffer data to the text file
       for j in 0 to 479 loop
        for i in 0 to 639 loop
          -- Convert the std_logic_vector to string
          for k in 0 to 23 loop
            case image_buffer(i, j)(k) is
              when '0' =>
                pixel_str(k+1) := '0';
              when '1' =>
                pixel_str(k+1) := '1';
              when others =>
                pixel_str(k+1) := 'X'; -- or 'Z' if it represents unknown state
            end case;
          end loop;
          write(line_buf, pixel_str);
          writeline(image_file, line_buf);
        end loop;
      end loop;


        -- Close the text file
        file_close(image_file);
      end if;
    end if;
  end process;
end architecture rtl;

-- library ieee;
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
-- use std.textio.all;

-- entity ImageCapture is
--   port (
--     HDMI_TX    : in std_logic_vector(23 downto 0);
--     HDMI_TX_VS : in std_logic;
--     HDMI_TX_HS : in std_logic;
--     HDMI_TX_DE : in std_logic;
--     HDMI_TX_CLK: in std_logic
--   );
-- end entity ImageCapture;

-- architecture rtl of ImageCapture is
--   type pixel_buffer is array (natural range <>, natural range <>) of std_logic_vector(23 downto 0);
--   signal image_buffer : pixel_buffer(0 to 639, 0 to 479);
--   variable pixel_str : string(1 to 24);

-- begin
--   process(HDMI_TX_CLK)
--     file image_file : text;
--     variable line_buf : line;
--   begin
--     if rising_edge(HDMI_TX_CLK) then
--       if HDMI_TX_HS = '1' and HDMI_TX_VS = '1' then
--         for i in 0 to 639 loop
--           for j in 0 to 479 loop
--             image_buffer(i, j) <= HDMI_TX;
--           end loop;
--         end loop;

--         -- Open the text file for writing
--         file_open(image_file, "C:/Users/user/OneDrive - ort braude college of engineering/B.sc/Year 4/Semester B/VHDL/Final Project/VHDL-Final-Project/sim/image.txt", write_mode);

--         -- -- Write the buffer data to the text file
--         -- for j in 0 to 479 loop
--         --   for i in 0 to 639 loop
--         --     write(line_buf, image_buffer(i, j));
--         --     writeline(image_file, line_buf);
--         --   end loop;
--         -- end loop;

--         -- -- Write the buffer data to the text file
--         -- for j in 0 to 479 loop
--         --     for i in 0 to 639 loop
--         --         write(line_buf, to_string(image_buffer(i, j)));
--         --         writeline(image_file, line_buf);
--         --     end loop;
--         --     end loop;



--         -- Write the buffer data to the text file
--         for j in 0 to 479 loop
--             for i in 0 to 639 loop
--               -- Convert the std_logic_vector to string
--               for k in 0 to 23 loop
--                 pixel_str(k+1) := std_logic'image(image_buffer(i, j)(k));
--               end loop;
--               write(line_buf, pixel_str);
--               writeline(image_file, line_buf);
--             end loop;
--           end loop;


--         -- Close the text file
--         file_close(image_file);
--       end if;
--     end if;
--   end process;
-- end architecture rtl;

-- library ieee;
-- use ieee.std_logic_1164.all;
-- use std.textio.all;

-- entity hdmi_gen is
--   port (
--     HDMI_TX    : in std_logic_vector(23 downto 0);
--     HDMI_TX_VS : in std_logic;
--     HDMI_TX_HS : in std_logic;
--     HDMI_TX_DE : in std_logic;
--     HDMI_TX_CLK: in std_logic
--   );
-- end entity hdmi_gen;

-- architecture rtl of hdmi_gen is
    
--   type pixel_buffer is array (natural range <>) of std_logic_vector(23 downto 0);
--   signal image_buffer : pixel_buffer(0 to 639, 0 to 479);
-- begin
--   process(HDMI_TX_CLK)
--     file image_file : text;
--     variable line_buf : line;
--   begin
--     if rising_edge(HDMI_TX_CLK) then
--       if HDMI_TX_HS = '1' and HDMI_TX_VS = '1' then
--         for i in 0 to 639 loop
--           for j in 0 to 479 loop
--             image_buffer(i, j) <= HDMI_TX;
--           end loop;
--         end loop;

--         -- Open the text file for writing
--         file_open(image_file, "C:/Users/user/OneDrive - ort braude college of engineering/B.sc/Year 4/Semester B/VHDL/Final Project/VHDL-Final-Project/sim/image.txt", write_mode);

--         -- Write the buffer data to the text file
--         for j in 0 to 479 loop
--           for i in 0 to 639 loop
--             write(line_buf, image_buffer(i, j));
--             writeline(image_file, line_buf);
--           end loop;
--         end loop;

--         -- Close the text file
--         file_close(image_file);
--       end if;
--     end if;
--   end process;
-- end architecture rtl;
