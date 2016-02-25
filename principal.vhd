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
--use ieee.numeric_std.all;
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
	signal amount : integer :=0;
	signal clk : std_logic :='0';
	signal hex : std_logic_vector (3 downto 0):="0000";

	
begin

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

	process(clk, button, mode)  --period of clk is 1 second.	
	begin
		-- Selon le mode sélectionné, si un bouton est enfoncé, on incrémente le champ correspondant.
		if (button(0) = '1' or button(1) = '1' or button(2) = '1' or button(3) = '1') then
			if mode = '1' then -- Si on est en mode HH:MM
				-- cadran 4 (hh:mM)
				if button(0) = '1' then
					min <= min + 1;
					if(min > 59) then
						hour <= hour + 1;
						min <= 0;
						if(hour > 23) then
							hour <= 0;
						end if;
					end if;
				end if;
				-- cadran 3 (hh:Mm)
				if button(1) = '1' then
					min <= min + 10;
					if(min > 59) then
						hour <= hour + 1;
						min <= min - 60;
						if(hour > 23) then
							hour <= 0;
						end if;
					end if;
				end if;
				-- cadran 2 (hH:mm)
				if button(2) = '1' then
					hour <= hour + 1;
					if(hour > 23) then
						hour <= 0;
					end if;
				end if;
				-- cadran 1 (Hh:mm)
				if button(3) = '1' then
					hour <= hour + 10;
					if(hour > 23) then
						hour <= hour - 24;
					end if;
				end if;
			else --Si on est en mode MM:SS
				-- cadran 4 (mm:sS)
				if button(0) = '1' then
					sec <= sec +1;
					if(sec > 59) then
						sec<=0;
						min <= min + 1;
						if(min > 59) then
							hour <= hour + 1;
							min <= 0;
							if(hour > 23) then
								hour <= 0;
							end if;
						end if;
					end if;
				end if;
				-- cadran 3 (mm:Ss)
				if button(1) = '1' then
					sec <= sec + 10;
					if(sec > 59) then
						sec<= sec - 60;
						min <= min + 1;
						if(min > 59) then
							hour <= hour + 1;
							min <= 0;
							if(hour > 23) then
								hour <= 0;
							end if;
						end if;
					end if;
				end if;
				-- cadran 2 (mM:ss)
				if button(2) = '1' then
					min <= min +1;
					if(min > 59) then
						hour <= hour + 1;
						min <= 0;
						if(hour > 23) then
							hour <= 0;
						end if;
					end if;
				end if;
				-- cadran 1 (Mm:ss)
				if button(3) = '1' then
					min <= min + 10;
					if(min > 59) then
						hour <= hour + 1;
						min <= min - 60;
						if(hour > 23) then
							hour <= 0;
						end if;
					end if;
				end if;
			end if;
		-- On incrémente le timestamp chaque seconde
		elsif(clk'event and clk='1') then
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
		
	process(mode, sec, min, hour) 	--Génère les valeurs binaires des chiffres à afficher et les envoie à la carte.(mux)
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
				
				amount <= 0;
				while (amount < (min - tmp)) loop
					amount <= amount + 10;
				end loop;
				
				-- On a ici les dizaines de minutes
				hex <= conv_std_logic_vector(amount,4);
				
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
				
				amount <= 0;
				while (amount < (hour - tmp)) loop
					amount <= amount + 10;
				end loop;

				hex <= conv_std_logic_vector(hour,4);

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
				
				amount <= 0;
				while (amount < (sec - tmp)) loop
					amount <= amount + 10;
				end loop;

				-- On a ici les dizaines de minutes
				hex <= conv_std_logic_vector(amount,4);
				
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
				
				amount <= 0;
				while (amount < (min - tmp)) loop
					amount <= amount + 10;
				end loop;

				-- On a ici les dizaines de minutes
				hex <= conv_std_logic_vector(amount,4);
				
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

