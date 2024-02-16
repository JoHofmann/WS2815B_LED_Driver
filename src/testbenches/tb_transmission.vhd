library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_transmission is
end entity;

architecture tbench of tb_transmission is

	component pwmgen is
	port ( clk_i    : in  std_ulogic;
	       rst_n    : in  std_ulogic;
	       d_i      : in  std_ulogic_vector(7 downto 0);
	       dv_i     : in  std_ulogic;
	       en_pwm_i : in  std_ulogic;
	       pwm_o    : out std_ulogic;
	       done_o   : out std_ulogic);
	end component pwmgen;

	component memreadinterface
	generic(
	    led_num : integer);
	port ( 
		clk_i      : in  std_ulogic;
		rst_n      : in  std_ulogic;
		mem_a_o    : out std_ulogic_vector(12 downto 0);
		mem_d_i    : in  std_ulogic_vector(7 downto 0);
		done_pwm_i : in  std_ulogic;
		dv_o       : out std_ulogic;
		d_o        : out std_ulogic_vector(7 downto 0);
		en_pwm_o   : out std_ulogic;
		new_data_i : in  std_ulogic);
	end component memreadinterface;
  
  component mem
    port ( 
      clk_i   : in  std_ulogic;
      d_i     : in  std_ulogic_vector(7 downto 0);
      a_i     : in  std_ulogic_vector(12 downto 0);
      we_i    : in  std_ulogic;
      a2_i    : in  std_ulogic_vector(12 downto 0);
      d2_o    : out std_ulogic_vector(7 downto 0));
  end component mem;

	-- constants
	constant N : integer := 10;

	-- simulation signals
	signal clock_50, reset : std_ulogic;
	signal simstop : boolean := false;

	-- pwmgen
	signal pwm : std_ulogic;
	
	-- interconnect memreadinterface - pwmgen
	signal pwm_data       : std_ulogic_vector(7 downto 0);
	signal pwm_data_valid : std_ulogic;
	signal pwm_done, pwm_reset, en_pwm : std_ulogic;

	-- interconnect memwriteinterface - memreadinterface
  	signal new_data : std_ulogic;

	-- memory
  	signal mem_di, mem_do : std_ulogic_vector(7 downto 0);
  	signal mem_wa, mem_ra : std_ulogic_vector(12 downto 0);
  	signal mem_we         : std_ulogic;
	
	procedure RunCycle(signal clk_50 : out std_ulogic) is
	begin
		clk_50 <= '0';
		wait for 10 ns;
		clk_50 <= '1';
		wait for 10 ns;
	end procedure;
	
	procedure WriteDummyData(
		signal clk_50, m_we : out std_ulogic; 
		signal m_di : out std_ulogic_vector(7 downto 0); 
		signal m_wa : out std_ulogic_vector(12 downto 0)) is
	begin
		m_we <= '1';

		for i in 0 to 256 loop
			m_di <= std_ulogic_vector(to_unsigned(i + 10 ,m_di'length));
			m_wa <= std_ulogic_vector(to_unsigned(i, m_wa'length));

			RunCycle(clk_50);
		end loop;

		m_we <= '0';
	end procedure;

begin

	pwmgen_i0 : pwmgen
  	port map (
    	clk_i 		=> clock_50,
    	rst_n 		=> reset,
    	d_i   		=> pwm_data,
    	dv_i  		=> pwm_data_valid,
    	en_pwm_i  	=> en_pwm,
    	pwm_o  		=> pwm,
		done_o 		=> pwm_done);

	memreadinterface_i0 : memreadinterface
	generic map ( 
	    led_num => N)
  	port map (
		clk_i      	=> clock_50,
		rst_n      	=> reset,
		mem_a_o     => mem_ra,
		mem_d_i     => mem_do,
		dv_o      	=> pwm_data_valid,
		d_o     	=> pwm_data,
		done_pwm_i 	=> pwm_done,
		en_pwm_o 	=> en_pwm,
		new_data_i	=> new_data);

	mem_i0 : mem
  	port map (
    	clk_i => clock_50,
    	d_i   => mem_di,
    	a_i   => mem_wa,
    	we_i  => mem_we,
    	a2_i  => mem_ra,
    	d2_o  => mem_do);

  -- simulate clock, reset
  reset <= '1', '0' after 20 ns, '1' after 40 ns;
  simstop <= true after 1000 us;

	clk_p : process
    begin
		WriteDummyData(clock_50, mem_we, mem_di, mem_wa);
		
		new_data <= '1';
		RunCycle(clock_50);

		new_data <= '0';

		while True loop
    		RunCycle(clock_50);

			if (simstop) then
				wait;
			end if;
		end loop;
		wait;
    end process clk_p;

end; -- architecture
