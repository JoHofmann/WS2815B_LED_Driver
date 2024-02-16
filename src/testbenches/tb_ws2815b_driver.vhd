library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ws2815B_driver is
end entity;

architecture tbench of tb_ws2815b_driver is
  
	component ws2815B_driver is 
	port (   
		CLOCK_50     	: in  std_ulogic;
		RESET_N        	: in  std_ulogic;
		SPI_CLK_IN		: in  std_ulogic;
		SPI_MOSI_IN		: in  std_ulogic;
		SPI_CS_IN 		: in  std_ulogic;
		INTERRUPT_OUT	: out std_ulogic;
		SERIAL_OUT		: out std_ulogic);
	end component;

	-- constants
	constant N : integer := 12;		--> N = number of bytes e.g. N = LED_count*3


  	-- simulation signals
	signal clock_50, reset : std_ulogic;

	-- spi signals
  	signal spi_clk, spi_cs, spi_mosi : std_ulogic;
	
	-- output, interrupt
	signal serial_out, interrupt : std_ulogic;
    
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
  
	WS2815B_Driver_i0 : ws2815b_driver
    port map (
        CLOCK_50     	=> clock_50,
        RESET_N      	=> reset,
        SPI_CLK_IN		=> spi_clk,
        SPI_MOSI_IN		=> spi_mosi,
        SPI_CS_IN 		=> spi_cs,
		INTERRUPT_OUT	=> interrupt,
        SERIAL_OUT  	=> serial_out);


	-- simulate single spi transmission
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
