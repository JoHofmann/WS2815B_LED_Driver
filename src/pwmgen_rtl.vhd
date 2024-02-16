library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwmgen is
port ( 
	clk_i    : in  std_ulogic;
    rst_n    : in  std_ulogic;
    d_i      : in  std_ulogic_vector(7 downto 0);
    dv_i     : in  std_ulogic;
    en_i 	 : in  std_ulogic;
    pwm_o    : out std_ulogic;
    done_o   : out std_ulogic);
end entity;

architecture rtl of pwmgen is
  
  -- timings	(timing for reset time in memreadinterface)
  constant t_low   : integer := 14;    -- -> 300 ns
  constant t_high  : integer := 49;    -- -> 600 ns
  constant t_total : integer := 64;    -- -> 1300 ns
  
  -- type declaration
  type state_t is (IDLE, OUTPUT, BIT_COMPLETED, REQUEST, RESET);
	
	-- signal state machine
  signal cstate, nstate : state_t;

  -- data buffer
  signal data : std_ulogic_vector(7 downto 0);
  
  signal sel_bit : std_ulogic;
  
  -- counter
  signal index : unsigned(2 downto 0);
  signal timer : unsigned(6 downto 0);    
  
  -- control singals
  signal en_tcnt, en_icnt : std_ulogic;

  signal timer_done, done_bit : std_ulogic;

begin 
  
	-- select bit
	sel_bit <= data(to_integer(index));
  
  	pwm_o <= '0' when en_i = '0' else
       '1' when (sel_bit = '1' and timer <= t_high) or 
				(sel_bit = '0' and timer <= t_low) else '0';
	
  	-- load data if valid
    load_data_p : process(clk_i)
    begin
      	if(rising_edge(clk_i) and dv_i = '1') then
			data <= d_i;
      	end if;
    end process;
  
	-- Index counter: mod 8 counter with en singal
	index_counter_p : process(clk_i, rst_n)
	begin
		if(rst_n = '0') then
			index <= (others => '0');

		elsif(rising_edge(clk_i) and en_icnt = '1') then
			if(index = 7) then
				index <= (others => '0');
			else
				index <= index + 1;
			end if;
		end if;
	end process;
  
  	-- Timer counter
  	timer_counter_p : process(clk_i, rst_n)
  	begin
		if(rst_n = '0') then
			timer <= (others => '0');
			timer_done <= '0';

		elsif(rising_edge(clk_i) and en_tcnt = '1') then
			if(timer = t_total) then
				timer <= (others => '0');
				timer_done <= '1';
			else
				timer <= timer + 1;
				timer_done <= '0';
			end if;
		end if;
  	end process;

	-- done signal
	done_o <= '1' when (timer = t_total-2 and index = 7) else '0';
	done_bit <= '1' when timer = t_total-1  else '0';

	-- state machine
  	cstate <= IDLE when rst_n = '0' else nstate when rising_edge(clk_i);

  	statemachine_p: process (clk_i, rst_n, cstate, dv_i)	
  	begin
	 	nstate <= cstate;
	 	case cstate is
	   		when IDLE =>	      
	     		-- outputs
	     		en_icnt <= '0';
	     		en_tcnt <= '0';

	     		-- next state
	     		if dv_i = '1' then	     
	     			nstate <= OUTPUT;
	     		end if;
	     
---------------------------------------------	      
		    when OUTPUT =>
		    	-- outputs
		    	en_icnt <= '0';
		    	en_tcnt <= '1';

				-- next state  
		    	if (done_bit = '1') then	 
		    	    nstate <= BIT_COMPLETED;  
		    	end if;
			
---------------------------------------------			
		    when BIT_COMPLETED =>
		    	-- outputs
		    	en_icnt <= '1';
		    	en_tcnt <= '1';

				-- next state
	       		if (index = 7) then
					if (dv_i = '1') then
						nstate <= OUTPUT;   
					else
						nstate <= IDLE;
					end if;
				else
		      		nstate <= OUTPUT;   
		     	end if;
     		when others => null;
    	end case;
  	end process statemachine_p;
  
end architecture rtl;
