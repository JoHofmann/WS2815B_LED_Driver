library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_recieving is
end entity;

architecture tbench of tb_recieving is
  
    component spi_slave is
    port (rst_n      : in  std_ulogic;
          spi_cs_i   : in  std_ulogic;
          spi_clk_i  : in  std_ulogic;
          spi_mosi_i : in  std_ulogic;
          dv_o       : out std_ulogic;
          d_o        : out std_ulogic_vector(7 downto 0));
    end component;

	component memwriteinterface is
	generic ( 
		N : integer); 
	port ( 
		clk_i       : in  std_ulogic;
		rst_n       : in  std_ulogic;
		mem_a_o     : out std_ulogic_vector(12 downto 0);
		mem_d_o     : out std_ulogic_vector(7 downto 0);
		mem_we_o    : out std_ulogic;
		dv_i        : in  std_ulogic;
		d_i         : in  std_ulogic_vector(7 downto 0);
		new_frame_o : out std_ulogic);
	end component ;

	component mem
    port ( 
		clk_i   : in  std_ulogic;
		wd_i    : in  std_ulogic_vector(7 downto 0);    -- Write Data
		wa_i    : in  std_ulogic_vector(12 downto 0);   -- Write Address
		we_i    : in  std_ulogic;                       -- Write Enable
		rd_o    : out std_ulogic_vector(7 downto 0);    -- Read Data
		ra_i    : in  std_ulogic_vector(12 downto 0));  -- Read Address 
  	end component mem;

	-- constants
	constant N : integer := 12;


	-- simulation signals
  	signal clock_50, reset : std_ulogic;
  
  	signal spi_clk, spi_cs, spi_mosi : std_ulogic;
  	signal clock_50_out, reset_out, serial_out : std_ulogic;
  
  	signal data_valid, new_frame : std_ulogic;
	signal data : std_ulogic_vector(7 downto 0);

	-- memory
	signal mem_wd, mem_rd : std_ulogic_vector(7 downto 0);
  	signal mem_wa, mem_ra : std_ulogic_vector(12 downto 0);
  	signal mem_we         : std_ulogic;
  
	procedure RunCycle(signal clk_50 : out std_ulogic) is
	begin
		clk_50 <= '0';
		wait for 10 ns;
		clk_50 <= '1';
		wait for 10 ns;
	end procedure;

	procedure SPIRunCycle(signal clk : out std_ulogic) is
	begin
	    clk <= '0';
      	wait for 20 ns;
      	clk <= '1';
      	wait for 20 ns;
	end procedure;

  	procedure GenerateDummySPI(signal clk, cs, mosi : out std_ulogic) is
  	begin
		cs   <= '1';
    	clk  <= '0';
    	mosi <= '0';
    	wait for 100 ns;

		cs <= '0';
    	wait for 5 ns;

		for k in 0 to N*8-1 loop
			if k mod 2 = 0 then
        		mosi <= '1';
      		else
        		mosi <= '0';
      		end if;
			SPIRunCycle(clk);
		end loop;
	
    	wait for 5 ns;
		cs  <= '1';
		clk <= '0';

  	end procedure;
  
begin
  
	spi_slave_i0 : spi_slave
    port map (
    	rst_n    	=> reset,
		spi_cs_i	=> spi_cs,
		spi_clk_i	=> spi_clk,
		spi_mosi_i	=> spi_mosi,
        dv_o       	=> data_valid,
        d_o       	=> data);

	memwriteinterface_i0 : memwriteinterface
	generic map (
		N => N)
    port map (
		clk_i      	=> clock_50,
		rst_n      	=> reset,
		mem_a_o    	=> mem_wa,
		mem_d_o    	=> mem_wd,
		mem_we_o   	=> mem_we,
		dv_i       	=> data_valid,
		d_i        	=> data,
		new_frame_o => new_frame);

	mem_i0 : mem
    port map (
		clk_i  	=> clock_50,
		wd_i   	=> mem_wd,
		wa_i   	=> mem_wa,
		we_i   	=> mem_we,
		rd_o   	=> mem_rd,
		ra_i   	=> mem_ra);
  
	spi_gen_p : process
  	begin
		GenerateDummySPI(spi_clk, spi_cs, spi_mosi);
		wait;

	end process;
  
  -- simulate clock, reset
	reset <= '1', '0' after 20 ns, '1' after 40 ns;

	clk_p : process
    begin
      RunCycle(clock_50);
    end process clk_p;


end; -- architecture
