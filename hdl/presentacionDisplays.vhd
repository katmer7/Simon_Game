-- Interfaz de salida de los displays:
-- Representa la longitud, el recor, el numero de secuencia 
-- y la puntuacion

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity presentacionDisplays is
port(
   clk:					in	   std_logic;
	 nRst:				in	   std_logic;
	 tic_1ms:	in	   std_logic;
	 modo:				in	   std_logic; 
	 Lon:					in	   std_logic;
	 rec:					in	   std_logic;
	 start:			in	   std_logic;
	 mostrando_secuencia: in std_logic;
	 parpadeo_fin:			in	   std_logic;                              -- Indica que se ha terminado el juego y se muestra la puntuacion
	 tic_1s:		       in	   std_logic;
	 longitud_programada_bcd:	in	  std_logic_vector(15 downto 0);  -- Longitud prog del control conf
	 recor_bcd:					          in	  std_logic_vector(15 downto 0);  -- record del control conf
	 num_memoria_bcd:         in	  std_logic_vector(15 downto 0);  
	 cuenta_num_mostrado_bcd: in   std_logic_vector(15 downto 0);
	 posicion_secuencia_bcd:  in	  std_logic_vector(15 downto 0);  -- numero de color por el que se va en la ronda de control juego
	 puntuacion_out_bcd:		    in	  std_logic_vector(15 downto 0);  -- puntuacion final del control conf
	 
	 presentacion:			buffer std_logic_vector (7 downto 0);
	 mux_display:			 buffer std_logic_vector (7 downto 0)
	 );
	 
end entity;

architecture rtl of presentacionDisplays is
--Señal control de multiplexacion
	signal ctrl_mux: std_logic_vector(7 downto 0);
--Señal control de presentacion
	signal screen: std_logic_vector(4 downto 0);
--Señal de control de parpadeo 1 segundo
	signal parpadeo: std_logic;
	
--Señales para los numeros  
	-- variables para la programacion de la longitud
	signal longitud_prog_mill_bcd_sinceros: std_logic_vector(3 downto 0);
	signal longitud_prog_cent_bcd_sinceros:	 std_logic_vector(3 downto 0);
	signal longitud_prog_dec_bcd_sinceros: std_logic_vector(3 downto 0);
	signal longitud_prog_uni_bcd_sinceros: std_logic_vector(3 downto 0);
	-- variables para el numero de colores en la memoria
	signal num_memoria_uni_bcd_sinceros: std_logic_vector(3 downto 0);
	signal num_memoria_dec_bcd_sinceros:	 std_logic_vector(3 downto 0);
	signal num_memoria_cent_bcd_sinceros: std_logic_vector(3 downto 0);
	signal num_memoria_mill_bcd_sinceros: std_logic_vector(3 downto 0);
	-- variables para el color que se esta mostrando
	signal cuenta_uni_mostrado_bcd_sinceros: std_logic_vector(3 downto 0);
	signal cuenta_dec_mostrado_bcd_sinceros:	 std_logic_vector(3 downto 0);
	signal cuenta_cent_mostrado_bcd_sinceros: std_logic_vector(3 downto 0);
	signal cuenta_mill_mostrado_bcd_sinceros: std_logic_vector(3 downto 0);
	-- variables para la secuencia
	signal posicion_uni_secuencia_bcd_sinceros: std_logic_vector(3 downto 0);
	signal posicion_dec_secuencia_bcd_sinceros:	 std_logic_vector(3 downto 0);
	signal posicion_cent_secuencia_bcd_sinceros: std_logic_vector(3 downto 0);
	signal posicion_mill_secuencia_bcd_sinceros: std_logic_vector(3 downto 0);
	-- variables para el record
	signal recor_uni_bcd_sinceros: std_logic_vector(3 downto 0);
	signal recor_dec_bcd_sinceros:	 std_logic_vector(3 downto 0);
	signal recor_cent_bcd_sinceros: std_logic_vector(3 downto 0);
	signal recor_mill_bcd_sinceros: std_logic_vector(3 downto 0);	
	-- variables para la puntuacion final
	signal puntuacion_uni_out_bcd_sinceros: std_logic_vector(3 downto 0);
	signal puntuacion_dec_out_bcd_sinceros: std_logic_vector(3 downto 0);
	signal puntuacion_cent_out_bcd_sinceros: std_logic_vector(3 downto 0);
	signal puntuacion_mill_out_bcd_sinceros: std_logic_vector(3 downto 0);
		
--Señales de codificacion de letras
	signal letra_c: std_logic_vector(4 downto 0);
	signal letra_o: std_logic_vector(4 downto 0);
	signal letra_n: std_logic_vector(4 downto 0);
	signal letra_f: std_logic_vector(4 downto 0);
	signal letra_L: std_logic_vector(4 downto 0);
	signal letra_r: std_logic_vector(4 downto 0);
	signal letra_e: std_logic_vector(4 downto 0);
	signal espacio:	std_logic_vector(3 downto 0);
	
	begin 
--Codificacion de letras:

	letra_c <= "10001";
	letra_o <= "01011";
	letra_n <= "01100";
	letra_f <= "01101";
	letra_L <= "01110";
	letra_r <= "01111"; 
	letra_e <= "10000";
	espacio	<= "1010";


--Controla la multiplexacion pasando de un display a otro cada 1ms
	process(clk, nRst)
	begin
		if nRst = '0' then 
			ctrl_mux <= (0 => '0', others => '1');
		elsif clk'event and clk='1' then
			if tic_1ms = '1' then
				ctrl_mux <= ctrl_mux(6 downto 0) & ctrl_mux(7);
			end if;
		end if;
	end process;
	
--Control del parpadeo de 1 segundo
	parpadeo_1s : process(nRst,clk)
	begin
		if nRst <= '0' then
			parpadeo <= '0';
		elsif clk'event and clk = '1' then		
	   	if tic_1s = '1' then
		   	parpadeo <= not(parpadeo);
		  end if;
		 end if;
	end process; -- parpadeo_1s

--  CONTROL NUMEROS: 
-- LONGITUD PARA PONER A LA DERECHA DEL DISPLAY SIN CEROS SIGNIFICATIVOS CUANDO PROGRAM LON				
	longitud_prog_mill_bcd_sinceros <= longitud_programada_bcd(15 downto 12) when longitud_programada_bcd(15 downto 12) /= 0 else espacio;	
	longitud_prog_cent_bcd_sinceros <= longitud_programada_bcd(11 downto 8) when (longitud_programada_bcd(11 downto 8) /= 0 and longitud_programada_bcd(15 downto 12) = 0) or longitud_programada_bcd(15 downto 12) /= 0 else espacio;  	
	longitud_prog_dec_bcd_sinceros <=  longitud_programada_bcd(7 downto 4) when (longitud_programada_bcd(7 downto 4) /= 0 and longitud_programada_bcd(11 downto 8) = 0) or  longitud_programada_bcd(11 downto 8) /= 0 or longitud_programada_bcd(15 downto 12) /= 0 else espacio;	
	longitud_prog_uni_bcd_sinceros <=  longitud_programada_bcd(3 downto 0);
					      
-- NUM COLORES MEMORIA A LA IZQUIERDA (START = 1) SIN CEROS SIGNIFICATIVOS					      					      
	num_memoria_mill_bcd_sinceros <= num_memoria_bcd(15 downto 12) when num_memoria_bcd(15 downto 12) /= 0 else espacio;	
	num_memoria_cent_bcd_sinceros <= num_memoria_bcd(11 downto 8) when (num_memoria_bcd(11 downto 8) /= 0 and num_memoria_bcd(15 downto 12) = 0) or num_memoria_bcd(15 downto 12) /= 0 else espacio;  	
	num_memoria_dec_bcd_sinceros  <= num_memoria_bcd(7 downto 4) when (num_memoria_bcd(7 downto 4) /= 0 and num_memoria_bcd(11 downto 8) = 0) or  num_memoria_bcd(11 downto 8) /= 0 or num_memoria_bcd(15 downto 12) /= 0 else espacio;	
	num_memoria_uni_bcd_sinceros  <= num_memoria_bcd(3 downto 0);
					      				      
-- CUENTA NUM MOSTRANDO_SECUENCIA (START = 1) SIN CEROS SIGNIFICATIVOS					      					      
	cuenta_mill_mostrado_bcd_sinceros <= cuenta_num_mostrado_bcd(15 downto 12) when cuenta_num_mostrado_bcd(15 downto 12) /= 0 else espacio;	
	cuenta_cent_mostrado_bcd_sinceros <= cuenta_num_mostrado_bcd(11 downto 8) when (cuenta_num_mostrado_bcd(11 downto 8) /= 0 and cuenta_num_mostrado_bcd(15 downto 12) = 0) or cuenta_num_mostrado_bcd(15 downto 12) /= 0 else espacio;  	
	cuenta_dec_mostrado_bcd_sinceros  <= cuenta_num_mostrado_bcd(7 downto 4) when (cuenta_num_mostrado_bcd(7 downto 4) /= 0 and cuenta_num_mostrado_bcd(11 downto 8) = 0) or  cuenta_num_mostrado_bcd(11 downto 8) /= 0 or cuenta_num_mostrado_bcd(15 downto 12) /= 0 else espacio;	
	cuenta_uni_mostrado_bcd_sinceros  <= cuenta_num_mostrado_bcd(3 downto 0);				      

-- CUENTA NUM POSICON SECUENCIA(START = 1) SIN CEROS SIGNIFICATIVOS					      					      
	posicion_mill_secuencia_bcd_sinceros <= posicion_secuencia_bcd(15 downto 12) when posicion_secuencia_bcd(15 downto 12) /= 0 else espacio;	
	posicion_cent_secuencia_bcd_sinceros <= posicion_secuencia_bcd(11 downto 8) when (posicion_secuencia_bcd(11 downto 8) /= 0 and posicion_secuencia_bcd(15 downto 12) = 0) or posicion_secuencia_bcd(15 downto 12) /= 0 else espacio;  	
	posicion_dec_secuencia_bcd_sinceros  <= posicion_secuencia_bcd(7 downto 4) when (posicion_secuencia_bcd(7 downto 4) /= 0 and posicion_secuencia_bcd(11 downto 8) = 0) or  posicion_secuencia_bcd(11 downto 8) /= 0 or posicion_secuencia_bcd(15 downto 12) /= 0 else espacio;	
	posicion_uni_secuencia_bcd_sinceros  <= posicion_secuencia_bcd(3 downto 0);
				      
-- RECORD SIN CEROS SIGNIFICATIVOS					      					      
	recor_mill_bcd_sinceros <= recor_bcd(15 downto 12) when recor_bcd(15 downto 12) /= 0 else espacio;	
	recor_cent_bcd_sinceros <= recor_bcd(11 downto 8) when (recor_bcd(11 downto 8) /= 0 and recor_bcd(15 downto 12) = 0) or recor_bcd(15 downto 12) /= 0 else espacio;  	
	recor_dec_bcd_sinceros  <= recor_bcd(7 downto 4) when (recor_bcd(7 downto 4) /= 0 and recor_bcd(11 downto 8)  = 0) or  recor_bcd(11 downto 8)  /= 0 or recor_bcd(15 downto 12) /= 0 else espacio;	
	recor_uni_bcd_sinceros  <= recor_bcd(3 downto 0);
	
-- PUNTUACION SIN CEROS SIGNIFICATIVOS					      					      
	puntuacion_mill_out_bcd_sinceros <= puntuacion_out_bcd(15 downto 12) when puntuacion_out_bcd(15 downto 12) /= 0 else espacio;	
	puntuacion_cent_out_bcd_sinceros <= puntuacion_out_bcd(11 downto 8) when (puntuacion_out_bcd(11 downto 8) /= 0 and puntuacion_out_bcd(15 downto 12) = 0) or puntuacion_out_bcd(15 downto 12) /= 0 else espacio;  	
	puntuacion_dec_out_bcd_sinceros  <= puntuacion_out_bcd(7 downto 4) when (puntuacion_out_bcd(7 downto 4)	 /= 0 and puntuacion_out_bcd(11 downto 8) = 0) or  puntuacion_out_bcd(11 downto 8)  /= 0 or puntuacion_out_bcd(15 downto 12) /= 0 else espacio;	
	puntuacion_uni_out_bcd_sinceros  <= puntuacion_out_bcd(3 downto 0);			
				      

--Control de presentacion:
	--modo  -> estado Conf
	--Lon	 -> estado longitud
	--rec	 -> estado recor
	--start	 -> estado juego
	--parpadeo_fin	 -> estado fin partida

            -- Letras derecha
	screen <= letra_c when (modo = '1' and ctrl_mux = "11110111") or (rec = '1' and ctrl_mux = "11011111") else
            letra_o when (modo = '1' and ctrl_mux = "11111011") or (Lon = '1' and ctrl_mux = "10111111")	else
	          letra_n when (modo = '1' and ctrl_mux = "11111101") or (Lon = '1' and ctrl_mux = "11011111")	else	 
			      letra_f when modo = '1' and ctrl_mux =  "11111110" 	else
			      letra_L when Lon  = '1' and ctrl_mux =  "01111111" 	else
			      letra_r when rec  = '1' and ctrl_mux =  "01111111" 	else
			      letra_e when rec  = '1' and ctrl_mux =  "10111111" 	else
			  
			      -- numeros derecha
			         -- uni
			      '0' & longitud_prog_uni_bcd_sinceros       when Lon = '1'	   and ctrl_mux = "11111110"	else
			      '0' & cuenta_uni_mostrado_bcd_sinceros     when start = '1'  and mostrando_secuencia = '1' and ctrl_mux = "11111110"	else 
			      '0' & posicion_uni_secuencia_bcd_sinceros   when start = '1'  and ctrl_mux = "11111110"	else
			      '0' & recor_uni_bcd_sinceros               when rec ='1'				 and ctrl_mux = "11111110"	else  
			          -- dec
			      '0' & longitud_prog_dec_bcd_sinceros        when Lon = '1' 	 and ctrl_mux = "11111101"		else
			      '0' & cuenta_dec_mostrado_bcd_sinceros   when start = '1'  and mostrando_secuencia = '1' and ctrl_mux = "11111101"	else 
			      '0' & posicion_dec_secuencia_bcd_sinceros    when start = '1' and ctrl_mux = "11111101"		else
				    '0' & recor_dec_bcd_sinceros                when rec = '1'			and ctrl_mux = "11111101"		else
				        -- cent
				    '0' & longitud_prog_cent_bcd_sinceros       when Lon = '1' 	 and ctrl_mux = "11111011" else
				    '0' & cuenta_cent_mostrado_bcd_sinceros  when start = '1' and mostrando_secuencia = '1' and ctrl_mux = "11111011"	else 
				    '0' & posicion_cent_secuencia_bcd_sinceros   when start = '1' and ctrl_mux = "11111011"	else
				    '0' & recor_cent_bcd_sinceros                when rec = '1'			and ctrl_mux = "11111011"	else
                -- mill
            '0' & longitud_prog_mill_bcd_sinceros        when Lon = '1'   and ctrl_mux = "11110111"	 else
            '0' & cuenta_mill_mostrado_bcd_sinceros  when start = '1' and mostrando_secuencia = '1' and ctrl_mux = "11110111"	else 
			      '0' & posicion_mill_secuencia_bcd_sinceros   when start = '1' and ctrl_mux = "11110111"	else
				    '0' & recor_mill_bcd_sinceros               when rec = '1'			and ctrl_mux = "11110111" else 
			      
			      -- numeros izq mientras start = '1'
			      '0' & num_memoria_uni_bcd_sinceros   when start = '1' and ctrl_mux = "11101111" else
			      '0' & num_memoria_dec_bcd_sinceros   when start = '1' and ctrl_mux = "11011111" else
			      '0' & num_memoria_cent_bcd_sinceros  when start = '1' and ctrl_mux = "10111111" else
			      '0' & num_memoria_mill_bcd_sinceros  when start = '1' and ctrl_mux = "01111111" else
			      
			       -- numeros derecha mientras start = '0' y parpadeo_fin = '1' 
			      '0' & puntuacion_uni_out_bcd_sinceros  when parpadeo = '1' and start = '0' and parpadeo_fin = '1' and ctrl_mux = "11111110" else
			      '0' & puntuacion_dec_out_bcd_sinceros  when parpadeo = '1' and start = '0' and parpadeo_fin = '1' and ctrl_mux = "11111101" else
			      '0' & puntuacion_cent_out_bcd_sinceros when parpadeo = '1' and start = '0' and parpadeo_fin = '1' and ctrl_mux = "11111011" else
			      '0' & puntuacion_mill_out_bcd_sinceros when parpadeo = '1' and start = '0' and parpadeo_fin = '1' and ctrl_mux = "11110111" else
			      '0' & espacio ;
			  
	
	mux_display <= ctrl_mux;


----Decodificador al display	  
	process(screen)
	    begin
	    case screen is        		
	      when "00000" => presentacion <= "01111110"; -- 0 
	      when "00001" => presentacion <= "00110000"; -- 1
	      when "00010" => presentacion <= "01101101"; -- 2 
	      when "00011" => presentacion <= "01111001"; -- 3
	      when "00100" => presentacion <= "00110011"; -- 4
	      when "00101" => presentacion <= "01011011"; -- 5
	      when "00110" => presentacion <= "01011111"; -- 6
	      when "00111" => presentacion <= "01110000"; -- 7
	      when "01000" => presentacion <= "01111111"; -- 8
	      when "01001" => presentacion <= "01110011"; -- 9
	      when "01010" => presentacion <= "00000000"; -- espacio
	      when "01011" => presentacion <= "00011101"; -- letra o
	      when "01100" => presentacion <= "00010101"; -- letra n
	      when "01101" => presentacion <= "01000111"; -- letra f
	      when "01110" => presentacion <= "00001110"; -- letra L
	      when "01111" => presentacion <= "00000101"; -- letra r
	      when "10000" => presentacion <= "01001111"; -- letra e
	      when "10001" => presentacion <= "00001101"; -- letra c
	      when others => presentacion <= "XXXXXXXX";
	     end case;
	end process; 
end architecture;
			 
			  	
			  