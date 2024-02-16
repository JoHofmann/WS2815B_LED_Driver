library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_slave is
port ( 
	rst_n      : in  std_ulogic;
    spi_cs_i   : in  std_ulogic;
    spi_clk_i  : in  std_ulogic;
	spi_mosi_i : in  std_ulogic;
	dv_o       : out std_ulogic;
	d_o        : out std_ulogic_vector(7 downto 0));
end entity;

architecture rtl of spi_slave is
  
  signal index, nindex : unsigned(7 downto 0);
  signal en_icnt : std_ulogic;
  
  signal data1, data2 : std_ulogic_vector(7 downto 0);
  signal toggle, dv : std_ulogic;

begin   
  
  spi_slave_recieve_p : process (spi_clk_i) 
  begin  
    
    if rising_edge(spi_clk_i) and spi_cs_i = '0' then
      
      if toggle = '0' then
        data1(to_integer(index)) <= spi_mosi_i;
        
      else
        data2(to_integer(index)) <= spi_mosi_i;
        
      end if;
    end if;
  end process;
  
  en_icnt <= not spi_cs_i;
	
  dv <= '1' when index = 7 else '0';
  dv_o <= dv when rising_edge(spi_clk_i);
  
  d_o  <= data1 when toggle = '1' else data2;
  
	-- toggle
	toggle_logic_p : process (spi_clk_i, rst_n)
	begin
	    if (rst_n = '0') then
			toggle <= '0';
		elsif (rising_edge(spi_clk_i) and index = 7) then
			toggle <= not toggle;
		end if;
	end process;


 	-- index counter  
	index_counter_p : process(spi_clk_i, rst_n)
  	begin
    	if (rst_n = '0') then
			index <= (others => '0');

		elsif (rising_edge(spi_clk_i) and en_icnt = '1') then
			if (index = 7) then
				index <= (others => '0');
			else
				index <= index + 1;
			end if;
    	end if;
	end process;
  
end architecture rtl;
