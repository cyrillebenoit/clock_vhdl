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
    Port ( 	clk1 	: in  STD_LOGIC;					  -- clock a 50MHz
    		switch 	: in  STD_LOGIC_VECTOR (7 downto 0);  --leviers
			button 	: in  STD_LOGIC_VECTOR (3 downto 0);  -- permet l'incrementation manuelle de l'heure
			an 	 	: out STD_LOGIC_VECTOR (3 downto 0);  -- selectionne le cadran a  utiliser
			led  	: out STD_LOGIC_VECTOR (6 downto 0); -- selectionne les segments de l'afficheur
			bin 	: out STD_LOGIC_VECTOR (7 downto 0)); -- leds
end principal;

architecture Behavioral of principal is
	
	
	--Signaux du diviseur de frequence
	signal count : std_logic_vector (25 downto 0):="00000000000000000000000000";
	signal clk : std_logic :='0';	
	
	--Signaux des compteurs
	signal usec, umin, uhour: integer range 0 to 10 :=0;
	signal dsec, dmin, dhour : integer range 0 to 6 :=0;		  
	signal sec_clk : std_logic :='0';
	signal min_clk : std_logic :='0';
	signal hour_clk : std_logic :='0';
	signal Minute : std_logic :='0';
	signal Hour : std_logic :='0';
	
	--Signaux de l'affichage
	signal value : integer range 0 to 10 :=0;
	signal cadran : integer range 0 to 4 :=1;  		  -- selectionne le cadran a  utiliser (permet de changer de cadran et de savoir ou on en est)
	signal count2 : std_logic :='0';	  
	signal test_led : std_logic_vector (7 downto 0):="00000000";
	
	--CHRONOMETRE
	signal chrono_usec,chrono_umin,chrono_dsec,chrono_dmin: integer range 0 to 10 :=0;
	signal chrono_usec2,chrono_umin2,chrono_dsec2,chrono_dmin2: integer range 0 to 10 :=0;
	signal chrono_usec3,chrono_umin3,chrono_dsec3,chrono_dmin3: integer range 0 to 10 :=0;
	signal chrono_sec_clk : std_logic :='0';
	signal chrono_min_clk : std_logic :='0';
	signal chrono_toggle : std_logic :='0'; -- 0 lorsque le chronomètre est en mode set, 1 lorsqu'il est en décompte
	
begin
	--FS1
	--Genere une clock de 1Hz (clk) et une clock d'affichage a partir d'une clock de 50MHz (clk1)
	process(clk1) 	
	begin
		if(clk1'event and clk1='1') then
			count <=count+1;
			if (count = 24999999) then 
				clk <= not clk;
				count <= "00000000000000000000000000"; 
			end if;
		end if;
	end process;
	
	--FS7 : AVSEC
	sec_clk <= count(22) when switch(0)='0' and switch(1)='0' and (button(0)='1' or button(1)='1')
	else clk;
	
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
					dsec<=dsec+1;
				end if;
			else
				Minute<='0';
				usec<=usec+1;
			end if;
		end if;
	end process;
	
	--FS9 : AVMIN
	min_clk <= count(22) when (switch(0)='0' and switch(1)='0' and (button(2)='1' or button(3)='1')) or (switch(0)='1' and switch(1)='0' and (button(0)='1' or button(1)='1'))
	else Minute;
	
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
					dmin<=dmin+1;
				end if;
			else
				Hour<='0';
				umin<=umin+1;
			end if;
		end if;
	end process;
	
	--FS10 : AVHOUR
	hour_clk <= count(22) when switch(0)='1' and switch(1)='0' and (button(2)='1' or button(3)='1')
	else Hour;
	
	--FS4 : Compteur des heures
	process(hour_clk)
	begin
		if(hour_clk'event and hour_clk='1') then
			--Modification des unités
			if(uhour=9) then
				uhour<=0;
				dhour<=dhour+1;
			elsif(uhour=3 and dhour=2) then
				uhour<=0;
				dhour<=0;
			else
				uhour<=uhour+1;
			end if;
		end if;
	end process;
	
	--Affichage
	count2<=count(15);
	
	--FS6 : Choix du cadran selon count2
	process(count2)
	begin
		if(count2'event and count2='1') then
			if(cadran=4) then
				cadran<=1;
			else
				cadran<=cadran+1;
			end if;
		end if;
	end process;
	
	-- Convertisseur 7 segments : traduit la valeur de value en segments à afficher	
	led<="1000000"	when value=0
	else "1111001" when value=1
	else "0100100"	when value=2
	else "0110000"	when value=3
	else "0011001"	when value=4
	else "0010010"	when value=5
	else "0000010"	when value=6
	else "1111000" when value=7
	else "0000000" when value=8
	else "0010000"	when value=9
	else "0001000" when value=10	
	else "1000000";
	
	--FS5 : Multiplexeur : Choix de la valeur de value à afficher en fonction des differents paramètres
	
	-- Mode MM:SS
	value <= usec when cadran=1 and switch(0)='0' and switch(1)='0' 
	else dsec when  cadran=2 and switch(0)='0' and switch(1)='0' 
	else umin when  cadran=3 and switch(0)='0' and switch(1)='0' 
	else dmin when  cadran=4 and switch(0)='0' and switch(1)='0' 

	-- Mode HH:MM
	else umin when cadran=1 and switch(0)='1' and switch(1)='0' 
	else dmin when  cadran=2 and switch(0)='1' and switch(1)='0' 
	else uhour when  cadran=3 and switch(0)='1' and switch(1)='0' 
	else dhour when  cadran=4 and switch(0)='1' and switch(1)='0' 
	
	-- Mode chrono
	else chrono_usec when cadran=1 and switch(1)='1' 
	else chrono_dsec when cadran=2 and switch(1)='1'
	else chrono_umin when cadran=3 and switch(1)='1'
	else chrono_dmin when cadran=4 and switch(1)='1';
	
	--FS6 : Démultiplexeur : Choix du cadran
	--Mode chrono set
	an <="1111" when chrono_toggle='0' and clk='0' and switch(1)='1'
	--Mode normal et chrono décompte
	else "1110" when cadran=1
	else "1101" when cadran=2
	else "1011" when cadran=3
	else "0111" when cadran=4;

	
			
	--BONUS
	-- Chronomètre
	-- Alarme
	-- Mode am/pm
	
	--FSB1 Test
	process(usec)
	begin
		-- TEST
		bin <= switch;
	end process;
	
	--Chronomètre
	
	--FSB1
	chrono_usec <= 0 when switch(1)='1' and button(3)='1' --RESET
	else chrono_usec2 when chrono_toggle='0' --SET
	else chrono_usec3 when chrono_toggle='1'; --DECOMPTE
	
	chrono_dsec <= 0 when switch(1)='1' and button(3)='1' --RESET
	else chrono_usec2 when chrono_toggle='0' --SET
	else chrono_usec3 when chrono_toggle='1'; --DECOMPTE
	
	chrono_umin <= 0 when switch(1)='1' and button(3)='1' --RESET
	else chrono_usec2 when chrono_toggle='0' --SET
	else chrono_usec3 when chrono_toggle='1'; --DECOMPTE
	
	chrono_dmin <= 0 when switch(1)='1' and button(3)='1' --RESET
	else chrono_usec2 when chrono_toggle='0' --SET
	else chrono_usec3 when chrono_toggle='1'; --DECOMPTE
	
	
	--FSB2 : AVSEC CHRONO
	chrono_sec_clk <= count(22) when switch(1)='1' and button(0)='1' and chrono_toggle='0'
	else '0';
	
	--FSB3 : Compteur de secondes du chrono
	process(chrono_sec_clk)
	begin
		if(chrono_sec_clk'event and chrono_sec_clk='1') then
			--Modification des unités
			if(chrono_usec2=9) then
				chrono_usec2<=0;
				if(chrono_dsec2=5) then
					chrono_dsec2<=0;
				else
					chrono_dsec2<=chrono_dsec2+1;
				end if;
			else
				chrono_usec2<=chrono_usec2+1;
			end if;
		end if;
	end process;
	
	--FSB4 : AVMIN CHRONO
	chrono_min_clk <= count(22) when switch(1)='1' and button(1)='1' and chrono_toggle='0'
	else '0';
	
	
	--FSB5 : Compteur de minutes du chrono
	process(chrono_min_clk)
	begin
		if(chrono_min_clk'event and chrono_min_clk='1') then
			--Modification des unités
			if(chrono_umin2=9) then
				chrono_umin2<=0;
				if(chrono_dmin2=5) then
					chrono_dmin2<=0;
				else
					chrono_dmin2<=chrono_dmin2+1;
				end if;
			else
				chrono_umin2<=chrono_umin2+1;
			end if;
		end if;
	end process;
	
	--FSB6 : Changement d'état du chrono
	
	process(chrono_toggle,button,switch)
	begin
		if(button(2)='1' and chrono_toggle='0' and switch(1)='1') then
			chrono_toggle<='1';
		elsif(button(3)='1' and switch(1)='1') then
			chrono_toggle<='0';
		end if;
	end process;

end Behavioral;