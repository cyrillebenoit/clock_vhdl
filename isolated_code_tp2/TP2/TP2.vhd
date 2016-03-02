----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:00:25 03/02/2016 
-- Design Name: 
-- Module Name:    TP2 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TP2 is
    Port ( clk1 : in  STD_LOGIC;
           an : out  STD_LOGIC_VECTOR (3 downto 0);
           led : out  STD_LOGIC_VECTOR (6 downto 0);
           light : out  STD_LOGIC);
end TP2;

architecture Behavioral of TP2 is
	signal clk : std_logic :='0';
	signal sec,tmp : integer range 0 to 61 :=0;
	signal unites,dizaines : integer range 0 to 10:=0;
	signal count: integer :=1;
	signal toggle: std_logic :='0';
	signal hex : std_logic_vector (3 downto 0):="0000";


begin
	light <=toggle;
	process(clk1) 			--clk generation. Génère une clock de 1Hz à partir d'une clock de 50MHz
	begin
			if(clk1'event and clk1='1') then
				count <=count+1;
				if(count = 25000000) then
					clk <= not clk;
					count <=1;
				end if;
			end if;
	end process;
	
	process(clk,sec) --compteur
	begin
		if(clk'event and clk='1') then
			sec <= sec+1;
		end if;
		if(sec = 10) then
			sec<=0;
			toggle <='1';
		end if;
	end process;
	
	process(sec) --afficheur
	begin
		
		tmp <= sec;
		while tmp >= 10 loop -- equivalent au modulo
			tmp <= tmp - 10 ;
			dizaines <= dizaines + 1;
		END LOOP;
		unites <= tmp;
		--unites
		hex <= conv_std_logic_vector(unites,4);
		an <= "1110";
		case hex is
				when "0001" => led <= "1111001";
				when "0010" => led <= "0100100";   --2
				when "0011" => led <= "0110000";   --3
				when "0100" => led <= "0011001";   --4
				when "0101" => led <= "0010010";   --5
				when "0110" => led <= "0000010";   --6
				when "0111" => led <= "1111000";   --7
				when "1000" => led <= "0000000";   --8
				when "1001" => led <= "0010000";   --9
				when others => led <= "1000000";   --0
				end case;
--		--dizaines
--		hex <= conv_std_logic_vector(dizaines,4);
--		an <= "1101";
--		case hex is
--				when "0001" => led <= "1111001";
--				when "0010" => led <= "0100100";   --2
--				when "0011" => led <= "0110000";   --3
--				when "0100" => led <= "0011001";   --4
--				when "0101" => led <= "0010010";   --5
--				when "0110" => led <= "0000010";   --6
--				when "0111" => led <= "1111000";   --7
--				when "1000" => led <= "0000000";   --8
--				when "1001" => led <= "0010000";   --9
--				when "1010" => led <= "0001000";   --A
--				when "1011" => led <= "0000011";   --b
--				when "1100" => led <= "1000110";   --C
--				when "1101" => led <= "0100001";   --d
--				when "1110" => led <= "0000110";   --E
--				when "1111" => led <= "0001110";   --F
--				when others => led <= "1000000";   --0
--		end case;

	end process;
						
end Behavioral;


