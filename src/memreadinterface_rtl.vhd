library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memreadinterface is
--  generic ( 
--    N : integer); 
port ( 
	clk_i      	: in  std_ulogic;
	rst_n      	: in  std_ulogic;
	mem_a_o    	: out std_ulogic_vector(12 downto 0);
	mem_d_i    	: in  std_ulogic_vector(7 downto 0);
	done_pwm_i 	: in  std_ulogic;
	dv_o       	: out std_ulogic;
	d_o        	: out std_ulogic_vector(7 downto 0);
	en_pwm_o   	: out std_ulogic;
	idle_o 	   	: out std_ulogic;
	new_frame_i : in  std_ulogic);
    
end entity memreadinterface;


architecture rtl of memreadinterface is
  
  -- constants
  constant t_reset : integer := 14000; -- Reset time -> 280 us
  
  -- type declaration
  type state_t is (IDLE, FETCH, DELIVER, STREAM, RESET);
	
	-- signal state machine
  signal cstate, nstate : state_t;
  
  -- index counter
  signal index : unsigned(12 downto 0);
  
  -- reset timer
  signal reset_counter : unsigned(13 downto 0);
  signal en_reset_counter, done_reset_counter : std_ulogic;
    
begin 
    
  mem_a_o <= std_ulogic_vector(index);
  d_o     <= mem_d_i; 

	-- index counter  
	index_counter_p : process(clk_i, rst_n)
	begin
		if (rst_n = '0') then
			index <= (others => '0');

		elsif (rising_edge(clk_i)) then

			if (done_pwm_i = '1') then
--				if (index = N-1) then
				if (index = 12-1) then
					index <= (others => '0');
				else
					index <= index + 1;
				end if;
			end if;
		end if;
	end process;
  
	-- reset counter
	reset_counter_p : process(clk_i, rst_n)
	begin
		if (rst_n = '0') then
			reset_counter <= (others => '0');

		elsif rising_edge(clk_i) then

			if en_reset_counter = '1' then
				reset_counter <= reset_counter + 1;
			end if;

			if reset_counter = t_reset then
				reset_counter <= (others => '0');
				done_reset_counter <= '1';
			else
				done_reset_counter <= '0';
			end if;
		end if;
	end process;

  	-- state machine
  	cstate <= IDLE when rst_n = '0' else nstate when rising_edge(clk_i);

	statemachine_p: process (clk_i, cstate, new_frame_i, done_pwm_i)
  	begin
    
		nstate <= cstate;
	  
	 	case cstate is
	   		when IDLE =>	      
		     	-- outputs
				en_pwm_o <= '0';
				en_reset_counter <= '0';
				dv_o <= '0';
				idle_o <= '1';

		     	if new_frame_i = '1' then	     
		       		nstate <= FETCH;
		     	end if;
	     
---------------------------------------------	      
	   		when FETCH =>
	     		-- outputs
				en_pwm_o <= '0';
				en_reset_counter <= '0';
				dv_o <= '0';
				idle_o <= '0';

	     		nstate <= DELIVER;

---------------------------------------------
			when DELIVER =>
				-- outputs
				en_pwm_o <= '0';
				en_reset_counter <= '0';
				dv_o <= '1';
				idle_o <= '0';

				nstate <= STREAM;

---------------------------------------------	     
	   		when STREAM =>
	     		-- outputs
				en_pwm_o <= '1';
				en_reset_counter <= '0';
				dv_o <= '0';
				idle_o <= '0';

				if done_pwm_i = '1' then
--					if index = N-1 then
					if index = 12-1 then
						nstate <= RESET;
					else
						nstate <= FETCH;
					end if;
				end if;

---------------------------------------------			
	  		when RESET => 
		   		-- outputs
				en_pwm_o <= '0';
				en_reset_counter <= '1';
				dv_o <= '0';
				idle_o <= '0';

       			if done_reset_counter = '1' then

					if new_frame_i = '1' then	     
		       			nstate <= FETCH;
					else
						nstate <= IDLE;
		     		end if;
       			end if;
        
      		when others => null;
    	end case;
  	end process statemachine_p;

end architecture rtl;
