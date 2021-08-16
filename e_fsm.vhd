-----------------------------------------------------------------------
--               Design authored by Sabyasachi Mondal                --
--    sabyasachi.mondal@stud.th-deg.de , sachi.iiest@gmail.com       --
--                       Jul 20th 2022                               --
-----------------------------------------------------------------------
--           This code creates a FSM that emulates a EVM             --
--  A Turing machine with the e_memory module acting as our Menory   --
-----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity e_evm is
	Port (	sl_clk: in std_logic;                                ------- Clock on our EVM --------
				slv_option : in std_logic_vector(2 downto 0);        ------- Option select --------
				slv_cnd_sl: in std_logic_vector(2 downto 0);         ------- Candidate Select --------
				slv_op: out std_logic_vector(19 downto 0)            ------- Output to 7-seg display -------
				);

end e_evm;

architecture a_evm of e_evm is

------- Declaration Part ---------

	-- fsm_states in an Electronic Voting Machine (S_INIT, S_CHK, S_RST, S_COUNT, S_POLL, S_WIN); --
 -- -------------------------------- --
	--	S_INIT - 000 - Q0
	-- S_CHK - 001 - check a aprticular candidate's vote
	-- S_RST - 010 - reset the RAM
	-- S_COUNT - 011 - count total votes of all candidates
	--	S_POLL - 100 - Poll / give vote
	--	S_WIN - 101 - Check the candidate with highest votes
 -- -------------------------------- --
 
	signal slv_count: std_logic_vector(19 downto 0);
	signal slv_mode_ctrl, slv_address_ctrl, slv_addr_op: std_logic_vector(2 downto 0);
	signal slv_data_op: std_logic_vector(15 downto 0);
	signal slv_success, sl_clk_ctrl: std_logic;
	-- signal fsm_change_signal : std_logic_vector(2 downto 0); --

------- Declaration Component --------
	
	component e_memory
		port(	 clock : in std_logic;
				 mode : in std_logic_vector(2 downto 0);
				 address  : in std_logic_vector(2 downto 0);
				 max_addr : out std_logic_vector(2 downto 0);
				 data_out : out std_logic_vector(15 downto 0) );
	end component;

begin

------- Assignment Part -------
	sl_clk_ctrl <= sl_clk;

------- Component Instantiation --------
 I_MEM: e_memory port map (clock => sl_clk_ctrl,mode => slv_mode_ctrl, address => slv_address_ctrl, 
										max_addr => slv_addr_op, data_out => slv_data_op); 

	---------- Qn of our FSM ------------
	p_fsm_transitions : process(sl_clk) -- fsm_change_signal not added to sensitivity list --
	
		variable fsm_state : std_logic_vector(2 downto 0) := "000";
		variable slv_actions: std_logic_vector(2 downto 0) := "000";
	
		begin
		
			if (rising_edge(sl_clk)) then
			
				-- fsm_change_signal <= fsm_state; -- we change only at next clock pulse
			
				case fsm_state is
					when "010" =>
						slv_actions := slv_actions + '1';
						slv_mode_ctrl <= "010";
						slv_address_ctrl <= "ZZZ"; 
						------------ reset all votes --------------
						if (slv_actions = "111") then
							slv_count <= '1' & slv_addr_op & slv_data_op;
							-------------- Transition to Q0 only when (Q0,A) where A in {7} ---------------
							fsm_state:="000";
						else
							slv_count <= '0' & slv_addr_op & slv_data_op;
							-------------- Transition to Q0 only when (Q0,A) where A in {0,1,2,3,4,5,6} ---------------
							fsm_state:="010";
						end if;
					when "101" =>
						slv_actions := slv_actions + '1';
						slv_mode_ctrl <= "100";
						slv_address_ctrl <= "ZZZ";
						------------ Check Winner -------------
						if (slv_actions = "111") then
							slv_count <= '1' & slv_addr_op & slv_data_op;
							-------------- Transition to Q0 only when (Q0,A) where A in {7} ---------------
							fsm_state:="000";
						else
							slv_count <= '0' & "ZZZ" & slv_data_op;
							-------------- Transition to Q0 only when (Q0,A) where A in {0,1,2,3,4,5,6} ---------------
							fsm_state:="101";
						end if;
					when "011" =>
						slv_actions := slv_actions + '1';
						slv_mode_ctrl <= "011";
						slv_address_ctrl <= slv_cnd_sl;
						------------ Count total vote of all parties -------------
						if (slv_actions = "111") then
							slv_count <= '1' & slv_addr_op & slv_data_op;
							-------------- Transition to Q0 only when (Q0,A) where A in {7} ---------------
							fsm_state:="000";
						else
							slv_count <= '0' & "ZZZ" & slv_data_op;
							-------------- Transition to Q0 only when (Q0,A) where A in {0,1,2,3,4,5,6} ---------------
							fsm_state:="011";
						end if;
					when "100" =>
						slv_mode_ctrl <= "001";
						slv_address_ctrl <= slv_cnd_sl;
						slv_count <= '1' & slv_addr_op & "ZZZZZZZZZZZZZZZZ"; 
						------------ Poll choosen candidate --------------
						------------ Transition back to Q0 on any actions A -----------
						fsm_state:="000";
					when "001" =>
						slv_mode_ctrl <= "000";
						slv_address_ctrl <= slv_cnd_sl;
						slv_count <= '1' & slv_addr_op & slv_data_op;
						------------ Show particular candidate's Votes  -------------
						------------ Transition back to Q0 on any actions A -----------
						fsm_state:="000";
					when "000" =>
						slv_mode_ctrl <= "111";
						slv_address_ctrl <= "ZZZ";
						slv_count <= '1' & slv_addr_op & slv_data_op;
						------------ Be active but do nothing, FSM will always start in this state -------------
						------------  FSM will be assigned to other state here based on user InPut --------------
						fsm_state:=slv_option;
					when others =>
						fsm_state := "000";
				end case;
				
			end if;
			
	end process;

   
---------  Assigning updated vote bank to Output ----------
slv_op<=slv_count;
--------- slv_op <= v_cand & v_tmp; Output format ----------

end a_evm;
