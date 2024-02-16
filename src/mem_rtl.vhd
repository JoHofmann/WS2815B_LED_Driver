library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem is
port ( 
    clk_i   : in  std_ulogic;
    wd_i    : in  std_ulogic_vector(7 downto 0);    -- Write Data
    wa_i    : in  std_ulogic_vector(12 downto 0);   -- Write Address
    we_i    : in  std_ulogic;                       -- Write Enable
    rd_o    : out std_ulogic_vector(7 downto 0);    -- Read Data
    ra_i    : in  std_ulogic_vector(12 downto 0));  -- Read Address 
end entity mem;

architecture rtl of mem is

  type mem_t is array (0 to 2**wa_i'length-1) of std_ulogic_vector(7 downto 0);
  
  signal memory : mem_t;
  
  signal wa, ra : integer range 0 to 2**wa_i'length-1;
  signal output : std_ulogic_vector(7 downto 0);

begin 
  
  wa <= to_integer(unsigned(wa_i));
  ra <= to_integer(unsigned(ra_i));
  
  mem_p : process (clk_i)
    begin
      
      if rising_edge(clk_i) then
		  -- prevents reading from address currently written to
		  if(not ((we_i = '1') and (wa = ra))) then
		    output <= memory(ra);
		  end if;
      
        if we_i = '1' then
          memory(wa) <= wd_i;
        end if;
        
      end if;
    end process;
  
  rd_o <= output;

end architecture rtl;
