----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Cyrille Benoit
-- 
-- Create Date:    13:53:32 02/24/2016 
-- Design Name: 
-- Module Name:    principal - Behavioral 
-- Project Name: projetS4
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
    Port ( 	clk1 	: in  STD_LOGIC;
    		mode 	: in  STD_LOGIC;
			button 	: in  STD_LOGIC_VECTOR (3 downto 0);
			an 	 	: out STD_LOGIC_VECTOR (3 downto 0);
			led  	: out STD_LOGIC_VECTOR (6 downto 0));
end principal;

architecture Behavioral of principal is
	signal sec,min,hour : integer range 0 to 60 :=0;
	signal tmp : integer range 0 to 60:=0; -- Aide pour les calculs d'unité et de dizaine
	signal count : integer :=1;
	signal clk : std_logic :='0';
	signal hex : std_logic_vector (3 downto 0):="0000";
	
begin

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
		
	process(button, mode) 	--Incrémente les compteurs correspondant aux cadrans adjacents
	begin
		if mode = '1' then -- Si on est en mode HH:MM
			-- cadran 1
--			if button(0) = 
--
--			end if;
		else
			
		end if;
	end process;


	process(mode, sec, min, hour, tmp, hex)
	begin
		if mode = '1' then -- Si on est en mode HH:MM
			--Calcul de la valeur HEX à afficher sur le 4e cadran (unités de minutes)
			
				tmp <= sec;

				while tmp > 10 loop
					tmp <= tmp - 10 ;
				END LOOP;
				
				-- On a un nombre inférieur à 10 qu'on convertit en binaire
				hex <= conv_std_logic_vector(tmp,4);
				
				an <= "1110";
				-- On calcule la valeur des bits de sortie
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
					when "1010" => led <= "0001000";   --A
					when "1011" => led <= "0000011";   --b
					when "1100" => led <= "1000110";   --C
					when "1101" => led <= "0100001";   --d
					when "1110" => led <= "0000110";   --E
					when "1111" => led <= "0001110";   --F
					when others => led <= "1000000";   --0
				end case;

			--Calcul de la valeur HEX à afficher sur le 3e cadran (dizaine de minutes)
			
				tmp <= (min - tmp)/10;
				
				-- On a ici les dizaines de minutes
				hex <= conv_std_logic_vector(tmp,4);
				
				an <= "1101";
				-- On calcule la valeur des bits de sortie
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
					when "1010" => led <= "0001000";   --A
					when "1011" => led <= "0000011";   --b
					when "1100" => led <= "1000110";   --C
					when "1101" => led <= "0100001";   --d
					when "1110" => led <= "0000110";   --E
					when "1111" => led <= "0001110";   --F
					when others => led <= "1000000";   --0
				end case;
			
			--Calcul de la valeur HEX à afficher sur le 2e cadran (unités des heures)
			
				tmp <= hour;
				
				-- on récupère les unités
				while tmp > 10 loop
					tmp <= tmp - 10;
				end loop;
				
				hex <= conv_std_logic_vector(tmp,4);

				an <= "1011";
				-- On calcule la valeur des bits de sortie
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
					when "1010" => led <= "0001000";   --A
					when "1011" => led <= "0000011";   --b
					when "1100" => led <= "1000110";   --C
					when "1101" => led <= "0100001";   --d
					when "1110" => led <= "0000110";   --E
					when "1111" => led <= "0001110";   --F
					when others => led <= "1000000";   --0
				end case;
			
			--Calcul de la valeur HEX à afficher sur le 1er cadran (dizaines des heures)
			
				tmp <= (hour - tmp)/10;
				
				hex <= conv_std_logic_vector(tmp,4);

				an <= "0111";
				-- On calcule la valeur des bits de sortie
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
					when "1010" => led <= "0001000";   --A
					when "1011" => led <= "0000011";   --b
					when "1100" => led <= "1000110";   --C
					when "1101" => led <= "0100001";   --d
					when "1110" => led <= "0000110";   --E
					when "1111" => led <= "0001110";   --F
					when others => led <= "1000000";   --0
				end case;
			
		else -- Sinon mode MM:SS
			--Calcul de la valeur HEX à afficher sur le 4e cadran (unités de secondes)
			
				tmp <= sec;

				while tmp > 10 loop
					tmp <= tmp - 10 ;
				END LOOP;
				
				-- On a un nombre inférieur à 10 qu'on convertit en binaire
				hex <= conv_std_logic_vector(tmp,4);
				
				an <= "1110";
				-- On calcule la valeur des bits de sortie
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
					when "1010" => led <= "0001000";   --A
					when "1011" => led <= "0000011";   --b
					when "1100" => led <= "1000110";   --C
					when "1101" => led <= "0100001";   --d
					when "1110" => led <= "0000110";   --E
					when "1111" => led <= "0001110";   --F
					when others => led <= "1000000";   --0
				end case;
			
			--Calcul de la valeur HEX à afficher sur le 3e cadran (dizaine de secondes)
			
				tmp <= (sec - tmp)/10;
				
				-- On a ici les dizaines de minutes
				hex <= conv_std_logic_vector(tmp,4);
				
				an <= "1101";
				-- On calcule la valeur des bits de sortie
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
					when "1010" => led <= "0001000";   --A
					when "1011" => led <= "0000011";   --b
					when "1100" => led <= "1000110";   --C
					when "1101" => led <= "0100001";   --d
					when "1110" => led <= "0000110";   --E
					when "1111" => led <= "0001110";   --F
					when others => led <= "1000000";   --0
				end case;
			
			--Calcul de la valeur HEX à afficher sur le 2e cadran (unités des minutes)
			
				tmp <= min;

				while tmp > 10 loop
					tmp <= tmp - 10 ;
				END LOOP;
				
				-- On a un nombre inférieur à 10 qu'on convertit en binaire
				hex <= conv_std_logic_vector(tmp,4);
				
				an <= "1011";
				-- On calcule la valeur des bits de sortie
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
					when "1010" => led <= "0001000";   --A
					when "1011" => led <= "0000011";   --b
					when "1100" => led <= "1000110";   --C
					when "1101" => led <= "0100001";   --d
					when "1110" => led <= "0000110";   --E
					when "1111" => led <= "0001110";   --F
					when others => led <= "1000000";   --0
				end case;
			
			--Calcul de la valeur HEX à afficher sur le 1er cadran (dizaines des minutes)
			
				tmp <= (min - tmp)/10;
				
				-- On a ici les dizaines de minutes
				hex <= conv_std_logic_vector(tmp,4);
				
				an <= "0111";
				-- On calcule la valeur des bits de sortie
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
					when "1010" => led <= "0001000";   --A
					when "1011" => led <= "0000011";   --b
					when "1100" => led <= "1000110";   --C
					when "1101" => led <= "0100001";   --d
					when "1110" => led <= "0000110";   --E
					when "1111" => led <= "0001110";   --F
					when others => led <= "1000000";   --0
				end case;
			
		end if;
	end process;
	

	
end Behavioral;

