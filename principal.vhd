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
			piezo 	: out  STD_LOGIC;					  -- buzzer
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
	
	--COMPTE A REBOURS
	signal countdown_state : std_logic :='0'; -- 0 lorsque le chronomètre est en mode set, 1 lorsqu'il est en décompte
	signal countdown_done : std_logic:='0'; --'1' lorsque le décompte est terminé -> PULSE
	
	signal countdown_usec,countdown_umin,countdown_dsec,countdown_dmin: integer range 0 to 10 :=0;
	signal countdown_usec_set,countdown_umin_set,countdown_dsec_set,countdown_dmin_set: integer range 0 to 10 :=0;
	signal countdown_usec_cd,countdown_umin_cd,countdown_dsec_cd,countdown_dmin_cd: integer range 0 to 10 :=1;
	signal countdown_set_sec_clk : std_logic :='0';
	signal countdown_set_min_clk : std_logic :='0';
	signal countdown_sec_clk : std_logic :='0';
	signal countdown_min_clk : std_logic :='0';
	
	signal buzzer_end : integer range 0 to 5 :=0;
	signal buzzer_start : std_logic :='0';
	signal countdown_permut_state : std_logic :='0'; --PULSE
	signal buzzer_toggle : std_logic :='0';
	
	--Signaux messagers - permet de créer des pulses
	signal countdown_permut_state_receive : std_logic:='0';
	signal countdown_toggle_done : std_logic :='0';
	
	--MODE AM/PM
	signal AP_uhour,AP_dhour : integer range 0 to 10 :=0;
	signal AP_led : std_logic :='0';
	
	
	
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
	sec_clk <= count(22) when switch(0)='0' and switch(1)='0' and button(0)='1'
	else clk;
	
	--FS2 : Compteur de secondes
	process(sec_clk,button,switch)
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
		--RESET
		if(button(1)='1' and switch(0)='0' and switch(1)='0') then
			usec<=0;
			dsec<=0;
		end if;
	end process;
	
	--FS9 : AVMIN
	min_clk <= count(22) when (switch(0)='0' and switch(1)='0' and button(2)='1') or (switch(0)='1' and switch(1)='0' and button(0)='1')
	else Minute;
	
	--FS3 : Compteur de minutes
	process(min_clk,button,switch)
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
		--RESET
		if((button(3)='1' and switch(0)='0' and switch(1)='0') or ( button(1)='1' and switch(0)='1' and switch(1)='0')) then
			umin<=0;
			dmin<=0;
		end if;
	end process;
	
	--FS10 : AVHOUR
	hour_clk <= count(22) when switch(0)='1' and switch(1)='0' and button(2)='1'
	else Hour;
	
	--FS4 : Compteur des heures
	process(hour_clk,button,switch)
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
		if(button(3)='1' and switch(0)='1' and switch(1)='0') then
			uhour<=0;
			dhour<=0;
		end if;
	end process;
	
	--Affichage
	count2<=count(15);
	
	--Choix du cadran selon count2
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
	
	--FS6 : Démultiplexeur : Choix du cadran
	--Mode chrono set
	an <="1111" when countdown_state='0' and clk='0' and switch(1)='1'
	--Mode normal et chrono décompte
	else "1110" when cadran=1
	else "1101" when cadran=2
	else "1011" when cadran=3
	else "0111" when cadran=4;
	
	--FS5 : Multiplexeur : Choix de la valeur de value à afficher en fonction des differents paramètres
	
	-- Mode MM:SS
	value <= usec when cadran=1 and switch(0)='0' and switch(1)='0' 
	else dsec when  cadran=2 and switch(0)='0' and switch(1)='0' 
	else umin when  cadran=3 and switch(0)='0' and switch(1)='0' 
	else dmin when  cadran=4 and switch(0)='0' and switch(1)='0' 

	-- Mode HH:MM
	else umin when cadran=1 and switch(0)='1' and switch(1)='0' 
	else dmin when  cadran=2 and switch(0)='1' and switch(1)='0' 
	else uhour when  cadran=3 and switch(0)='1' and switch(1)='0' and switch(3)='0'
	else dhour when  cadran=4 and switch(0)='1' and switch(1)='0' and switch(3)='0'
	
	--Mode AM/PM
	else AP_uhour when  cadran=3 and switch(0)='1' and switch(1)='0' and switch(3)='1'
	else AP_dhour when  cadran=4 and switch(0)='1' and switch(1)='0' and switch(3)='1'
	
	-- Mode compte à rebours
	else countdown_usec when cadran=1 and switch(1)='1' 
	else countdown_dsec when cadran=2 and switch(1)='1'
	else countdown_umin when cadran=3 and switch(1)='1'
	else countdown_dmin when cadran=4 and switch(1)='1';
	

	--FSB1a :  Affichage LED
	bin <= "11111111" when AP_led='1' and switch(3)='1' and switch(1)='0'
	else "00000000" when AP_led='0' and switch(3)='1' and switch(1)='0'
	else switch;
	
	--COMPTE A REBOURS
	
	--FSB2 : Multiplexeur - Assignation des valeurs à afficher selon le mode du compte à rebours
	countdown_usec <= 0 when switch(1)='1' and button(3)='1' --RESET
	else countdown_usec_set when countdown_state='0' --SET
	else countdown_usec_cd when countdown_state='1'; --DECOMPTE
	
	countdown_dsec <= 0 when switch(1)='1' and button(3)='1' --RESET
	else countdown_dsec_set when countdown_state='0' --SET
	else countdown_dsec_cd when countdown_state='1'; --DECOMPTE
	
	countdown_umin <= 0 when switch(1)='1' and button(3)='1' --RESET
	else countdown_umin_set when countdown_state='0' --SET
	else countdown_umin_cd when countdown_state='1'; --DECOMPTE
	
	countdown_dmin <= 0 when switch(1)='1' and button(3)='1' --RESET
	else countdown_dmin_set when countdown_state='0' --SET
	else countdown_dmin_cd when countdown_state='1'; --DECOMPTE
	
	
	--FSB3a : AVSEC CHRONO
	countdown_set_sec_clk <= count(22) when switch(1)='1' and button(0)='1' and countdown_state='0'
	else '0';
	
	--FSB3b : Compteur de secondes du chrono
	process(countdown_set_sec_clk)
	begin
		if(countdown_set_sec_clk'event and countdown_set_sec_clk='1') then
			if(countdown_usec_set=9) then
				countdown_usec_set<=0;
				if(countdown_dsec_set=5) then
					countdown_dsec_set<=0;
				else
					countdown_dsec_set<=countdown_dsec_set+1;
				end if;
			else
				countdown_usec_set<=countdown_usec_set+1;
			end if;
		end if;
		--RESET
		if(button(3)='1') then
			countdown_usec_set<=0;
			countdown_dsec_set<=0;
		end if;
	end process;
	
	--FSB4a : AVMIN CHRONO
	countdown_set_min_clk <= count(22) when switch(1)='1' and button(1)='1' and countdown_state='0'
	else '0';
	
	--FSB4b : Compteur de minutes du chrono
	process(countdown_set_min_clk)
	begin
		if(countdown_set_min_clk'event and countdown_set_min_clk='1') then
			if(countdown_umin_set=9) then
				countdown_umin_set<=0;
				if(countdown_dmin_set=5) then
					countdown_dmin_set<=0;
				else
					countdown_dmin_set<=countdown_dmin_set+1;
				end if;
			else
				countdown_umin_set<=countdown_umin_set+1;
			end if;
		end if;
		--RESET
		if(button(3)='1') then
			countdown_umin_set<=0;
			countdown_dmin_set<=0;
		end if;
	end process;
	
	--FSB5 : Pulseur d'activation de la permutation des valeurs
	process(countdown_state)
	begin
		if(countdown_state'event and countdown_state='1') then --Lorsque front montant de l'état du compteur
			countdown_permut_state<='1'; --Activation de la permutation
		end if;
		if(countdown_permut_state_receive='1') then --Lorsque message de confirmation envoyé
			countdown_permut_state<='0'; --Desactivation de la permutation
		end if;
	end process;
	
	--FSB6 : Changement d'état du compte à rebours
	
	process(countdown_state,button,switch,countdown_done)
	begin
		if(button(2)='1' and switch(1)='1') then
			countdown_state<='1';
		elsif((button(3)='1' and switch(1)='1') or countdown_done='1' or switch(1)='0') then
			countdown_state<='0';
			countdown_toggle_done<='1';
		else
			countdown_toggle_done<='0';
		end if;
	end process;
	
	--FSB7a : AVSEC DECOMPT
	countdown_sec_clk <= clk when countdown_state<='1'
	else '0';
	
	
	--FSB7b : Décompteur de secondes du chrono
	process(countdown_sec_clk,countdown_permut_state,button,switch)
	begin
		if(countdown_sec_clk'event and countdown_sec_clk='1') then
			if(countdown_usec_cd=0) then
				countdown_usec_cd<=9;
				if(countdown_dsec_cd=0) then
					countdown_min_clk <='1';
					countdown_dsec_cd<=5;
				else
					countdown_dsec_cd<=countdown_dsec_cd-1;
					countdown_min_clk <='0';
				end if;
			else
				countdown_min_clk <='0';
				countdown_usec_cd<=countdown_usec_cd-1;
			end if;
		end if;
		--Permutation des valeurs SET/COUNTDOWN
		if(countdown_permut_state='1') then
			countdown_permut_state_receive<='1';
			countdown_usec_cd<=countdown_usec_set;
			countdown_dsec_cd<=countdown_dsec_set;
		else
			countdown_permut_state_receive<='0';
		end if;
		---RESET
		if(button(3)='1' and switch(1)='1') then
			countdown_usec_cd<=0;
			countdown_dsec_cd<=0;
		end if;
	end process;
	
	--FSB8 : Décompteur de minutes du chrono
	process(countdown_min_clk,countdown_permut_state,countdown_toggle_done,button,switch)
	begin
		if(countdown_min_clk'event and countdown_min_clk='1') then
			if(countdown_umin_cd=0) then
				countdown_umin_cd<=9;
				if(countdown_dmin_cd=0) then
					countdown_dmin_cd<=0;
					countdown_umin_cd<=0;
					countdown_done<='1'; --Envoie de la pulse que le compte à rebours a terminé.
				else
					countdown_dmin_cd<=countdown_dmin_cd-1;
				end if;
			else
				countdown_umin_cd<=countdown_umin_cd-1;
			end if;
		end if;
		--Permutation des valeurs SET/COUNTDOWN
		if(countdown_permut_state='1') then
			countdown_permut_state_receive<='1';
			countdown_umin_cd<=countdown_umin_set;
			countdown_dmin_cd<=countdown_dmin_set;
		else
			countdown_permut_state_receive<='0';
		end if;
		if(countdown_toggle_done='1') then
			countdown_done<='0';
		end if;
		--RESET
		if(button(3)='1' and switch(1)='1') then
			countdown_umin_cd<=0;
			countdown_dmin_cd<=0;
		end if;
	end process;
	
	-- FSB9 & FSB1b : Activation et desactivation du buzzer
	
	buzzer_start <= '1' when countdown_done='1' and button(3)='0' --Activation sur pulse non provoquée par le RESET
	else '0' when buzzer_end=0; --Desactivation à la fin du compteur
	
	piezo <= clk when buzzer_start='1'
	else count(22) when switch(2)='1' --FSB1b : Activation du buzzer sur levier
	else '0' when buzzer_end =0;
	
	--Repeater
	process(clk,buzzer_start, buzzer_end)
	begin
		if(clk'event and clk='1') then
			if(buzzer_end>0) then
				buzzer_end<=buzzer_end-1;
			end if;
		end if;
		--Activation du décompte
		if(buzzer_start='1' and buzzer_toggle='0') then
				buzzer_toggle<='1';
				buzzer_end<=4;
		end if;
		--Remise à l'état initial
		if(buzzer_end=0) then
		 buzzer_toggle<='0';
		end if;
	end process;
	
	--FSB10 : Mode AM/PM
	process(uhour,dhour,switch)
	begin
		if((uhour >= 2 and dhour =1) or dhour=2) then --mode PM
			AP_led<='1';
			--Changement de AP_dhour et AP_uhour : 4 états possibles
			if(dhour=1 and uhour<=9) then
				AP_dhour<=0;
				AP_uhour<=uhour-2;
			elsif(dhour=2 and uhour<=1) then
				AP_dhour<=0;
				AP_uhour<=uhour+8;
			elsif(dhour=2 and uhour<=3) then
				AP_dhour<=1;
				AP_uhour<=uhour-2;
			elsif(dhour=2 and uhour=4) then
				AP_dhour<=0;
				AP_uhour<=0;
			end if;
		else
			AP_led<='0';
			AP_dhour<=dhour;
			AP_uhour<=uhour;
		end if;
	end process;
end Behavioral;