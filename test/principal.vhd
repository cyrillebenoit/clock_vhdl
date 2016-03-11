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
    Port ( 	clk1 	: in  STD_LOGIC;					  -- clock Ã  50MHz
    		mode 	: in  STD_LOGIC;					  -- differencie les modes HH:MM et MM:SS
			button 	: in  STD_LOGIC_VECTOR (3 downto 0);  -- permet l'incrementation manuelle de l'heure
			an 	 	: out STD_LOGIC_VECTOR (3 downto 0);  -- selectionne le cadran a  utiliser
			led  	: out STD_LOGIC_VECTOR (6 downto 0); -- selectionne les segments de l'afficheur
			bin 	: out STD_LOGIC_VECTOR (7 downto 0)); --test
end principal;

architecture Behavioral of principal is
	signal cadran : integer range 0 to 4 :=1;  		  -- selectionne le cadran a  utiliser (permet de changer de cadran et de savoir ou on en est)
	signal usec, umin, uhour: integer range 0 to 10 :=0;-- unites des secondes, minutes, et heures
	signal dsec, dmin, dhour : integer range 0 to 6 :=0;		  -- dizaines des secondes minutes et heures
	signal count1, count2, count3 : integer :=1;						  -- permet la reduction de frequence de la clock
	signal clk : std_logic :='0';	
	signal sec_clk : std_logic :='0';
	signal min_clk : std_logic :='0';
	signal hour_clk : std_logic :='0';
	signal display_clk : std_logic :='0';
	signal button_clk : std_logic :='0';
	signal sec_modif, min_modif, hour_modif : std_logic :='0';
	signal Minute : std_logic :='0';
	signal Hour : std_logic :='0';
	signal hex : std_logic_vector (3 downto 0):="0000";	  		  -- valeur hexa du chiffre a afficher
	signal test_led : std_logic_vector (7 downto 0):="00000000";

	
begin
	--FS1
	--Genere une clock de 1Hz (clk) et une clock d'affichage a partir d'une clock de 50MHz (clk1) et affiche les nombres sur les cadrans au rythme de clk1
	process(clk1) 	
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
			if(count2 = 25000) then
				display_clk <= not display_clk;
				count2 <=1;
			end if;
			
			--CLOCK DES BUTTONS (2Hz)
			count3 <= count3+1;
			if(count3 = 12500000) then
				button_clk <= not button_clk;
				count3 <= 1;
			end if;
			
		end if;
	end process;
	--FS2 : Compteur de secondes
	process(sec_clk)
	begin
		if(sec_clk'event and sec_clk='1') then
			--Modification des unités
			if(usec=9) then
				usec<=0;
				if(dsec=5) then
					Minute<='1';
					dsec<=0;
				else
					Minute<='0';
					dsec<=dsec+1;
				end if;
			else
				Minute<='0';
				usec<=usec+1;
			end if;
		end if;
	end process;
	
	--FS3 : Compteur de minutes
	process(min_clk)
	begin
		if(min_clk'event and min_clk='1') then
			
			--Modification des unités
			if(umin=9) then
				umin<=0;
				if(dmin=5) then
					dmin<=0;
					Hour<='1';
				else
					Hour<='0';
					dmin<=dmin+1;
				end if;
			else
				Hour<='0';
				umin<=umin+1;
			end if;
		end if;
	end process;
	
	--FS4 : Compteur des heures
	process(hour_clk)
	begin
		if(hour_clk'event and hour_clk='1') then
			--Modification des unités
			if(uhour=9 or uhour=3) then
				if(dhour=2 and uhour=3)  then
					dhour<=0;
					uhour<=0;
				elsif(uhour=9) then
					uhour<=0;
				else
					dhour<=dhour+1;
				end if;
			else
				uhour<=uhour+1;
			end if;
		end if;
	end process;
	
	--FS7 : AVSEC
	process(clk,button_clk,mode,button)
	begin
		--Modification manuelle
		--Conditions : Front montant de button_clk + Mode MM:SS + Bouton 0 ou 1 active
		sec_modif<='0';
		if(clk'event and clk='1') then
			sec_modif<='1';
		end if;
		if(button_clk'event and button_clk='1' and mode='0' and (button(0)='1' or button(1)='1'))then
			sec_modif<='1';
		end if;
		if(sec_modif='1') then
			sec_clk<='1';
		else
			sec_clk<='0';
		end if;
	end process;
	
	--FS9 : AVMI
	process(Minute,button_clk,mode,button)
	begin
		--Modification manuelle
		--Conditions : Front montant de button_clk + [Mode MM:SS + Bouton 2 ou 3 active] ou [Mode HH:MM + Bouton 0 ou 1 active]
		min_modif<='0';
		if(Minute'event and Minute='1') then
			min_modif<='1';
		end if;
		if (button_clk'event and button_clk='1' and ((mode='0' and (button(2)='1' or button(3)='1')) or (mode='1' and (button(0)='1' or button(1)='1')))) then
			min_modif<='1';
		end if;
		if(min_modif='1') then
			min_clk<='1';
		else
			min_clk<='0';
		end if;
	end process;
	
	--FS10 : AVHEU
	process(Hour,button_clk,mode,button)
	begin
		--Modification manuelle
		--Conditions : Front montant de button_clk + [Mode MM:SS + Bouton 2 ou 3 active] ou [Mode HH:MM + Bouton 0 ou 1 active]
		hour_modif<='0';
		if(Hour'event and Hour='1') then
			hour_modif<='1';
		end if;
		if(button_clk'event and button_clk='1' and mode='1' and (button(2)='1' or button(3)='1')) then
			hour_modif<='1';
		end if;
		if(hour_modif='1') then
			hour_clk<='1';
		else
			hour_clk<='0'; 
		end if;
	end process;
	
	process(display_clk, mode, usec, dsec, umin, dmin, uhour, dhour) -- affichage
	begin
		if(display_clk'event and display_clk='1') then
			if(cadran=4) then
				cadran<=1;
			else
				cadran<=cadran+1;
			end if;
		end if;
		if(cadran=1) then-- xx:xX
			an<="1110";
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
		end if;
		if(cadran=2) then-- xx:Xx
			an<="1101";
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
		end if;
		if(cadran=3) then-- xX:xx
			an<="1011";
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
			end if ;
		end if;
		if(cadran=4) then-- Xx:xx
			an<="0111";
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
			end if;
	end process;
	
	--FSB1 Test
	process(usec,button_clk)
	begin
		-- TEST
		test_led <= conv_std_logic_vector(usec,8);
		test_led(4)<= button_clk;
		test_led(5)<= not button_clk;
		bin <= test_led;
	end process;
	
end Behavioral;