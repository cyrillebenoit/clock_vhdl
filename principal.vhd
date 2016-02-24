----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:53:32 02/24/2016 
-- Design Name: 
-- Module Name:    principal - Behavioral 
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
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity principal is
    Port ( clk1 : in  STD_LOGIC;
			  led1 : out  STD_LOGIC_VECTOR (6 downto 0);
			  led2 : out  STD_LOGIC_VECTOR (6 downto 0);
			  led3 : out  STD_LOGIC_VECTOR (6 downto 0);
			  led4 : out  STD_LOGIC_VECTOR (6 downto 0);
end principal;

architecture Behavioral of principal is
	signal seconds,minutes : std_logic_vector (5 downto 0);
	signal hours : STD_LOGIC_VECTOR (4 downto 0);
	signal sec,min,hour : integer range 0 to 60 :=0;
	signal count : integer :=1;
	signal clk : std_logic :='0';
	signal hex1 : std_logic_vector (3 downto 0);
	signal hex2 : std_logic_vector (3 downto 0);
	signal hex3 : std_logic_vector (3 downto 0);
	signal hex4 : std_logic_vector (3 downto 0);
	
	begin
		seconds <= conv_std_logic_vector(sec,6);
		minutes <= conv_std_logic_vector(min,6);
		hours <= conv_std_logic_vector(hour,5);


		 --clk generation. Génère une clock de 1Hz à partir d'une clock de 100MHz
		process(clk1)
		begin
				if(clk1'event and clk1='1') then
					count <=count+1;
					if(count = 25000000) then
						clk <= not clk;
						count <=1;
					end if;
				end if;
		end process;

		process(clk)   --period of clk is 1 second.	
		begin
			if(clk'event and clk='1') then
				sec <= sec+ 1;
				if(sec = 59) then
					sec<=0;
					min <= min + 1;
					if(min = 59) then
						hour <= hour + 1;
						min <= 0;
						if(hour = 23) then
							hour <= 0;
						end if;
					end if;
				end if;
			end if;
		end process;

			 with hex1 SELect
			led1<= "1111001" when "0001",   --1
					 "0100100" when "0010",   --2
					 "0110000" when "0011",   --3
					 "0011001" when "0100",   --4
					 "0010010" when "0101",   --5
					 "0000010" when "0110",   --6
					 "1111000" when "0111",   --7
					 "0000000" when "1000",   --8
					 "0010000" when "1001",   --9
					 "0001000" when "1010",   --A
					 "0000011" when "1011",   --b
					 "1000110" when "1100",   --C
					 "0100001" when "1101",   --d
					 "0000110" when "1110",   --E
					 "0001110" when "1111",   --F
					 "1000000" when others;   --0
					 
				with hex2 SELect
			led2<= "1111001" when "0001",   --1
					 "0100100" when "0010",   --2
					 "0110000" when "0011",   --3
					 "0011001" when "0100",   --4
					 "0010010" when "0101",   --5
					 "0000010" when "0110",   --6
					 "1111000" when "0111",   --7
					 "0000000" when "1000",   --8
					 "0010000" when "1001",   --9
					 "0001000" when "1010",   --A
					 "0000011" when "1011",   --b
					 "1000110" when "1100",   --C
					 "0100001" when "1101",   --d
					 "0000110" when "1110",   --E
					 "0001110" when "1111",   --F
					 "1000000" when others;   --0
	 
				with hex3 SELect
			led3<= "1111001" when "0001",   --1
					 "0100100" when "0010",   --2
					 "0110000" when "0011",   --3
					 "0011001" when "0100",   --4
					 "0010010" when "0101",   --5
					 "0000010" when "0110",   --6
					 "1111000" when "0111",   --7
					 "0000000" when "1000",   --8
					 "0010000" when "1001",   --9
					 "0001000" when "1010",   --A
					 "0000011" when "1011",   --b
					 "1000110" when "1100",   --C
					 "0100001" when "1101",   --d
					 "0000110" when "1110",   --E
					 "0001110" when "1111",   --F
					 "1000000" when others;   --0
				
				with hex4 SELect
			led4<= "1111001" when "0001",   --1
					 "0100100" when "0010",   --2
					 "0110000" when "0011",   --3
					 "0011001" when "0100",   --4
					 "0010010" when "0101",   --5
					 "0000010" when "0110",   --6
					 "1111000" when "0111",   --7
					 "0000000" when "1000",   --8
					 "0010000" when "1001",   --9
					 "0001000" when "1010",   --A
					 "0000011" when "1011",   --b
					 "1000110" when "1100",   --C
					 "0100001" when "1101",   --d
					 "0000110" when "1110",   --E
					 "0001110" when "1111",   --F
					 "1000000" when others;   --0
		
end Behavioral;

