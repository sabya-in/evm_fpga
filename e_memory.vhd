-----------------------------------------------------------------------
--               Design authored by Sabyasachi Mondal                --
--    sabyasachi.mondal@stud.th-deg.de , sachi.iiest@gmail.com       --
--                       Jul 20th 2022                               --
-----------------------------------------------------------------------
--    This code instantiates a 8 x 16 memory with inbuilt functions   --
--	                And accessed by only the FSM                      --
-----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity e_memory is 
port ( clock : in std_logic;
		 mode : in std_logic_vector(2 downto 0);
       address  : in std_logic_vector(2 downto 0);
		 max_addr : out std_logic_vector(2 downto 0);
       data_out : out std_logic_vector(15 downto 0) );
end entity e_memory;

architecture a_memory of e_memory is

---- Declaration Part -----------------------------------------------

 -- Signal Declarations
   signal sl_Clock_int : std_logic;
	signal slv_Write_int, slv_Address_int : std_logic_vector(2 downto 0);
   signal i_Address_int, i_loop : integer range 0 to 7;
   signal slv_DataIn_int : std_logic_vector(15 downto 0);

 -- Type Declarations
   type t_mem is array(0 to 7) of std_logic_vector(15 downto 0);

 -- specify ram with initial contents:
   signal a_mem : t_mem := (0 => x"0FFF", 1 => x"1AFF", 2 => x"0FF5", 3 => x"0FF7",  4 => x"0FF1",  5 => x"1FAF", others => x"00F0");

begin

---- Assignment Part ------------------------------------------------

-- Concurrent Assignments:
   sl_Clock_int <= clock;
   slv_Write_int <= mode;
   slv_Address_int <= address;
   i_Address_int <= to_integer(unsigned(slv_Address_int));

   slv_DataIn_int <= a_mem(i_Address_int);
	data_out <= (others => 'Z');
	max_addr <= (others => 'Z');

-- Sequential process tied to clock
   p_memory: process (sl_Clock_int,i_loop)
	
-- Variable declaration
		variable tmp_addr : std_logic_vector(2 downto 0) := "000";
		variable tmp : std_logic_vector(15 downto 0) := x"0000";
		
		begin
			if ((rising_edge(sl_Clock_int)) or i_loop'event) then
			
				case slv_Write_int is
				
					when "000" =>
						data_out <= a_mem(i_Address_int);
						max_addr <= std_logic_vector(to_unsigned(i_Address_int,max_addr'length));
						
					when "001" =>
						a_mem(i_Address_int) <= slv_DataIn_int + 1;
						max_addr <= std_logic_vector(to_unsigned(i_Address_int,max_addr'length));
						
					when "010" =>
						wpe_mem : for i_loop in 0 to 7 loop
							a_mem(i_loop) <= x"0000";
							data_out <= x"0000";
							max_addr <= "000";
						end loop wpe_mem;
						
					when "011" =>
						acc_mem : for i_loop in 0 to 7 loop
							if(i_loop = 0) then
								tmp := a_mem(i_loop);
								tmp_addr := std_logic_vector(to_unsigned(i_loop,tmp_addr'length));
							elsif(i_loop > 0) then
								tmp := a_mem(i_loop) + tmp;
								tmp_addr := std_logic_vector(to_unsigned(i_loop,tmp_addr'length));
								max_addr <= tmp_addr;
								data_out <= tmp;
							end if;
						end loop acc_mem;
						
					when "100" =>
						max_mem : for i_loop in 0 to 7 loop
							if(i_loop = 0) then
								tmp := a_mem(i_loop);
								tmp_addr := std_logic_vector(to_unsigned(i_loop,tmp_addr'length));
							elsif(a_mem(i_loop) > tmp) then
								tmp := a_mem(i_loop);
								tmp_addr := std_logic_vector(to_unsigned(i_loop,tmp_addr'length));
							elsif(i_loop = 7) then
								if (a_mem(i_loop) > tmp) then
									tmp := a_mem(i_loop);
									tmp_addr := std_logic_vector(to_unsigned(i_loop,tmp_addr'length));
								end if;
								data_out <= tmp;
								max_addr <= tmp_addr;
							end if;
						end loop max_mem;
						
					when others =>
						data_out <= (others => 'Z');
						max_addr <= (others => 'Z');
						
				end case;
			
			end if;
			
   end process p_memory;

end architecture a_memory;