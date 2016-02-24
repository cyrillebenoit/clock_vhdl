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
    Port ( clk : in  STD_LOGIC;
           led : out  STD_LOGIC_VECTOR (6 downto 0);
           an : out  STD_LOGIC_VECTOR (3 downto 0));
end principal;

architecture Behavioral of principal is

	signal sec,min,hour : integer range 0 to 60 :=0;
	signal count : integer :=1;
	signal clk : std_logic :='0';
	signal hex_out : std_logic_vector (3 downto 0);
	
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
		
		
end Behavioral;

