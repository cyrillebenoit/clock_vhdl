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
    Port ( 	clk1 	: in  STD_LOGIC;					  -- clock à 50MHz
    		mode 	: in  STD_LOGIC;					  -- différencie les modes HH:MM et MM:SS
			button 	: in  STD_LOGIC_VECTOR (3 downto 0);  -- permet l'incrémentation manuelle de l'heure
			an 	 	: out STD_LOGIC_VECTOR (3 downto 0);  -- sélectionne le cadran à utiliser
			led  	: out STD_LOGIC_VECTOR (6 downto 0)); -- sélectionne les segments de l'afficheur
end principal;

architecture Behavioral of principal is
	signal an_in : STD_LOGIC_VECTOR (3 downto 0):="0001";  		  -- sélectionne le cadran à utiliser (permet de changer de cadran et de savoir où on en est)
	signal usec, umin, uhour : integer range 0 to 10 :=0; 		  -- unités des secondes, minutes, et heures
	signal dsec, dmin, dhour : integer range 0 to 6 :=0;		  -- dizaines des secondes minutes et heures
	signal count1, count2 : integer :=1;						  -- permet la réduction de fréquence de la clock
	signal clk : std_logic :='0';						  		  -- clock à 60Hz
	signal out_clk : std_logic :='0';
	signal hex : std_logic_vector (3 downto 0):="0000";	  		  -- valeur hexa du chiffre à afficher

	
begin

	process(clk1) 	--Génère une clock de 1Hz (clk) et une clock d'affichege à partir d'une clock de 50MHz (clk1) et affiche les nombres sur les cadrans au rythme de clk1
	begin
		if(clk1'event and clk1='1') then
			
			--PARTIE CREATION DE LA CLOCK A 1HZ
			count1 <=count1+1;
			if(count1 = 25000000) then
				clk <= not clk;
				count1 <=1;
			end if;

			--PARTIE CREATION DE LA CLOCK D'AFFICHAGE
			count2 <=count2+1;
			if(count2 = 250000) then
				out_clk <= not out_clk;
				count2 <=1;
			end if;

		end if;
	end process;

	process(out_clk, mode, usec, dsec, umin, dmin, uhour, dhour) -- affichage
	begin
		if(out_clk'event and out_clk='1') then
			--PARTIE AFFICHAGE
			if (an_in="0001") then -- xx:xX
				if mode = '1' then 		-- si on est en mode HH:MM
					hex <= conv_std_logic_vector(umin,4);
					case hex is
						when "0001" => led <= "1111001";   --1
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
				else 					-- si on est en mode MM:SS
					hex <= conv_std_logic_vector(usec,4);
					case hex is
						when "0001" => led <= "1111001";   --1
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
				end if ;
				an <= "0001";
				an_in <= "0010";
			elsif (an_in="0010") then -- xx:Xx
				if mode = '1' then 		-- si on est en mode HH:MM
					hex <= conv_std_logic_vector(dmin,4);
					case hex is
						when "0001" => led <= "1111001";   --1
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
				else 					-- si on est en mode MM:SS
					hex <= conv_std_logic_vector(dsec,4);
					case hex is
						when "0001" => led <= "1111001";   --1
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
				end if ;
				an <= "0010";
				an_in <= "0100";
			elsif (an_in="0100") then -- xX:xx
				if mode = '1' then 		-- si on est en mode HH:MM
					hex <= conv_std_logic_vector(uhour,4);
					case hex is
						when "0001" => led <= "1111001";   --1
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
				else 					-- si on est en mode MM:SS
					hex <= conv_std_logic_vector(uhour,4);
					case hex is
						when "0001" => led <= "1111001";   --1
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
				end if ;
				an <= "0100";
				an_in <= "1000";
			elsif (an_in="1000") then -- Xx:xx
				if mode = '1' then 		-- si on est en mode HH:MM
					hex <= conv_std_logic_vector(dhour,4);
					case hex is
						when "0001" => led <= "1111001";   --1
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
				else 					-- si on est en mode MM:SS
					hex <= conv_std_logic_vector(dmin,4);
					case hex is
						when "0001" => led <= "1111001";   --1
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
				end if ;
				an <= "1000";
				an_in <= "0001";
			end if;
		end if;
	end process;

	process(clk, button, mode, usec, dsec, umin, dmin, uhour, dhour)  -- modification manuelle de l'heure
	begin
		-- Selon le mode sélectionné, si un bouton est enfoncé, on incrémente le champ correspondant.
		if (button(0) = '1' or button(1) = '1' or button(2) = '1' or button(3) = '1') then
			if mode = '1' then -- Si on est en mode HH:MM
				-- cadran 4 (hh:mM)
				if button(0) = '1' then
					umin <= umin + 1;
					if(umin = 10) then
						umin <= 0;
						dmin <= dmin + 1;
						if(dmin = 6) then -- si on est à 60 minutes
							dmin <= 0;
							uhour <= uhour + 1;
							if dhour=2 and uhour=4 then -- si on est à 24h
								dhour <= 0;
								uhour <= 0;
							elsif uhour=10 then
								dhour <= dhour + 1;
								uhour <= 0;
							end if ;
						end if;
					end if;
				end if;
				-- cadran 3 (hh:Mm)
				if button(1) = '1' then
					dmin <= dmin + 1;
					if(dmin = 6) then -- si on est à 60 minutes
						dmin <= 0;
						uhour <= uhour + 1;
						if dhour=2 and uhour=4 then -- si on est à 24h
							dhour <= 0;
							uhour <= 0;
						elsif uhour=10 then
							dhour <= dhour + 1;
							uhour <= 0;
						end if ;
					end if;
				end if;
				-- cadran 2 (hH:mm)
				if button(2) = '1' then
					uhour <= uhour + 1;
					if dhour=2 and uhour=4 then -- si on est à 24h
						dhour <= 0;
						uhour <= 0;
					elsif uhour=10 then
						dhour <= dhour + 1;
						uhour <= 0;
					end if ;
				end if;
				-- cadran 1 (Hh:mm)
				if button(3) = '1' then
					dhour <= dhour + 1;
					if(dhour = 2 and uhour > 3) then
						dhour <= 0;
					elsif dhour = 3 then
						dhour <= 0;
					else
						dhour <= dhour + 1;
					end if;
				end if;
			else --Si on est en mode MM:SS
				-- cadran 4 (mm:sS)
				if button(0) = '1' then
					usec <= usec +1;
					if(usec = 10) then
						usec <= 0;
						dsec <= dsec + 1;
						if(dsec = 6) then -- si on est à 60 secondes
							umin <= umin + 1;
							if(umin = 10) then
								umin <= 0;
								dmin <= dmin + 1;
								if(dmin = 6) then -- si on est à 60 minutes
									dmin <= 0;
									uhour <= uhour + 1;
									if dhour=2 and uhour=4 then -- si on est à 24h
										dhour <= 0;
										uhour <= 0;
									elsif uhour=10 then
										dhour <= dhour + 1;
										uhour <= 0;
									end if ;
								end if;
							end if;
						end if;
					end if;
				end if;
				-- cadran 3 (mm:Ss)
				if button(1) = '1' then
					dsec <= dsec + 1;
					if(dsec = 6) then -- si on est à 60 secondes
						umin <= umin + 1;
						if(umin = 10) then
							umin <= 0;
							dmin <= dmin + 1;
							if(dmin = 6) then -- si on est à 60 minutes
								dmin <= 0;
								uhour <= uhour + 1;
								if dhour=2 and uhour=4 then -- si on est à 24h
									dhour <= 0;
									uhour <= 0;
								elsif uhour=10 then
									dhour <= dhour + 1;
									uhour <= 0;
								end if ;
							end if;
						end if;
					end if;
				end if;
				-- cadran 2 (mM:ss)
				if button(2) = '1' then
					umin <= umin + 1;
					if(umin = 10) then
						umin <= 0;
						dmin <= dmin + 1;
						if(dmin = 6) then -- si on est à 60 minutes
							dmin <= 0;
							uhour <= uhour + 1;
							if dhour=2 and uhour=4 then -- si on est à 24h
								dhour <= 0;
								uhour <= 0;
							elsif uhour=10 then
								dhour <= dhour + 1;
								uhour <= 0;
							end if ;
						end if;
					end if;
				end if;
				-- cadran 1 (Mm:ss)
				if button(3) = '1' then
					dmin <= dmin + 1;
					if(dmin = 6) then -- si on est à 60 minutes
						dmin <= 0;
						uhour <= uhour + 1;
						if dhour=2 and uhour=4 then -- si on est à 24h
							dhour <= 0;
							uhour <= 0;
						elsif uhour=10 then
							dhour <= dhour + 1;
							uhour <= 0;
						end if ;
					end if;
				end if;
			end if;
		-- On incrémente le timestamp chaque seconde
		elsif(clk'event and clk='1') then
			usec <= usec +1;
			if(usec = 10) then
				usec <= 0;
				dsec <= dsec + 1;
				if(dsec = 6) then -- si on est à 60 secondes
					umin <= umin + 1;
					if(umin = 10) then
						umin <= 0;
						dmin <= dmin + 1;
						if(dmin = 6) then -- si on est à 60 minutes
							dmin <= 0;
							uhour <= uhour + 1;
							if dhour=2 and uhour=4 then -- si on est à 24h
								dhour <= 0;
								uhour <= 0;
							elsif uhour=10 then
								dhour <= dhour + 1;
								uhour <= 0;
							end if ;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
	
end Behavioral;