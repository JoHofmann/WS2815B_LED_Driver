library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memwriteinterface is
--generic ( 
--	N : integer); 
port ( 
	clk_i       : in  std_ulogic;
	rst_n       : in  std_ulogic;
	mem_a_o     : out std_ulogic_vector(12 downto 0);
	mem_d_o     : out std_ulogic_vector(7 downto 0);
	mem_we_o    : out std_ulogic;
	dv_i        : in  std_ulogic;
	d_i         : in  std_ulogic_vector(7 downto 0);
	new_frame_o : out std_ulogic);
end entity;

architecture rtl of memwriteinterface is
  
	signal index : unsigned(12 downto 0);
	signal en_icnt : std_ulogic;
	
	signal new_data : std_ulogic;

	-- data valid signals for syncing
  	signal dv1, dv2, dv3, s_dv : std_ulogic;
  
begin 
  
	-- sync dv
	dv1 <= '0' when rst_n = '0' else dv_i when rising_edge(clk_i);
	dv2 <= '0' when rst_n = '0' else dv1 when rising_edge(clk_i);
	dv3 <= '0' when rst_n = '0' else dv2 when rising_edge(clk_i);

	-- rising edge detection
	s_dv <= '0' when rst_n = '0' else not dv3 and dv2 when rising_edge(clk_i); 

--	new_frame_o <= '1' when index = N-1 and s_dv = '1' else '0';
	new_frame_o <= '1' when index = 12-1 and s_dv = '1' else '0';


	mem_d_o  <= d_i when rising_edge(clk_i) and s_dv = '1';
    mem_a_o  <= std_ulogic_vector(index);
	mem_we_o <= en_icnt;
  
	en_icnt <= s_dv when rising_edge(clk_i);
	
	index_counter_p : process(clk_i, rst_n)
	begin
		if (rst_n = '0') then
			 index <= (others => '0');
		elsif (rising_edge(clk_i) and en_icnt = '1') then
--			if (index = N-1) then
			if (index = 12-1) then
				index <= (others => '0');
			else
				index <= index + 1;
			end if;
		end if;
	end process;

end architecture rtl;


