library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bin_to_bcd is
port(longitud_prog_bin:  in   std_logic_vector (13 downto 0);  -- Longitud usuario
     recor:              in	  std_logic_vector(13 downto 0);   -- recor
     cuenta_num_mostrado: in std_logic_vector(13 downto 0);
     posicion_secuencia: in	  std_logic_vector(13 downto 0);   -- num color por el que se va jugando 
     num_colores:        in std_logic_vector(13 downto 0);     -- numero de colores que hay en la memoria 
     puntuacion_out:		   in	  std_logic_vector(13 downto 0);   -- puntuacion fin partida
     mostrando_secuencia: in std_logic;
     reset:              in std_logic;                         -- Reset de la memoria y longitud introducida por el teclado, también para resetear todos los valores bcd de salida
     rec:                in std_logic;
     start:              in std_logic;
     lon:                in std_logic;     
      
     num_memoria_bcd:         buffer  std_logic_vector(15 downto 0);
  	  longitud_programada_bcd:	buffer	 std_logic_vector(15 downto 0);  -- Longitud prog del control conf
	   recor_bcd:					          buffer	 std_logic_vector(15 downto 0);  -- record del control conf
	   cuenta_num_mostrado_bcd: buffer  std_logic_vector(15 downto 0);
	   posicion_secuencia_bcd:  buffer	 std_logic_vector(15 downto 0);  -- numero de color por el que se va en la ronda de control juego
	   puntuacion_out_bcd:		    buffer	 std_logic_vector(15 downto 0)  -- puntuacion final del control conf
	 
    );

end entity;

architecture rtl of bin_to_bcd is
-- señales para la longitud
signal auxiliar_cent: std_logic_vector (13 downto 0);
signal auxiliar_cent_max: std_logic_vector (9 downto 0);
signal auxiliar_dec: std_logic_vector (9 downto 0);
signal auxiliar_dec_max: std_logic_vector (6 downto 0);
signal auxiliar_uni: std_logic_vector (6 downto 0);
signal unidades_bcd: std_logic_vector (3 downto 0);
signal decenas_bcd:  std_logic_vector (3 downto 0);
signal centenas_bcd: std_logic_vector (3 downto 0);
signal millares_bcd: std_logic_vector (3 downto 0);

-- señales para recor, secuencia y puntuacion
signal dato_bin: std_logic_vector(13 downto 0);
signal auxiliar_cent_dato: std_logic_vector (13 downto 0);
signal auxiliar_cent_max_dato: std_logic_vector (9 downto 0);
signal auxiliar_dec_dato: std_logic_vector (9 downto 0);
signal auxiliar_dec_max_dato: std_logic_vector (6 downto 0);
signal auxiliar_uni_dato: std_logic_vector (6 downto 0);
signal unidades_bcd_dato: std_logic_vector (3 downto 0);
signal decenas_bcd_dato:  std_logic_vector (3 downto 0);
signal centenas_bcd_dato: std_logic_vector (3 downto 0);
signal millares_bcd_dato: std_logic_vector (3 downto 0);

begin


dato_bin <= recor                 when  rec = '1'   else
            cuenta_num_mostrado   when  start = '1' and mostrando_secuencia = '1' else
            posicion_secuencia    when  start = '1' else
            longitud_prog_bin     when  lon = '1'   else     
            puntuacion_out;

-- Para valores entre 1000 y 9999, restamos y obtenemos las centenas                
  auxiliar_cent_dato <=  "00000000000000"            when reset = '1' else 
                          dato_bin          when (dato_bin < 1000) else
                         (dato_bin - 1000)  when (2000 > dato_bin and dato_bin > 999)  else
                         (dato_bin - 2000)  when (3000 > dato_bin and dato_bin > 1999) else
                         (dato_bin - 3000)  when (4000 > dato_bin and dato_bin > 2999) else
                         (dato_bin - 4000)  when (5000 > dato_bin and dato_bin > 3999) else
                         (dato_bin - 5000)  when (6000 > dato_bin and dato_bin > 4999) else
                         (dato_bin - 6000)  when (7000 > dato_bin and dato_bin > 5999) else
                         (dato_bin - 7000)  when (8000 > dato_bin and dato_bin > 6999) else
                         (dato_bin - 8000)  when (9000 > dato_bin and dato_bin > 7999) else
                         (dato_bin - 9000);
 
 auxiliar_cent_max_dato <= auxiliar_cent_dato(9 downto 0);
-- Obtenidas las centenas, podemos sacar el valor de los millares.                
  millares_bcd_dato <= "0000"  when reset = '1' else
	                     "0000"  when (dato_bin < 1000) else
                       "0001"  when (2000 > dato_bin and dato_bin > 999)  else
                       "0010"  when (3000 > dato_bin and dato_bin > 1999) else
                       "0011"  when (4000 > dato_bin and dato_bin > 2999) else
                       "0100"  when (5000 > dato_bin and dato_bin > 3999) else
                       "0101"  when (6000 > dato_bin and dato_bin > 4999) else
                       "0110"  when (7000 > dato_bin and dato_bin > 5999) else
                       "0111"  when (8000 > dato_bin and dato_bin > 6999) else
                       "1000"  when (9000 > dato_bin and dato_bin > 7999) else
                       "1001";
                  
                                    
-----------------------------------------------                
-- Para valores entre 100 y 999, restamos y obtenemos las decenas  
  auxiliar_dec_dato <=  "0000000000"     when reset = '1' else 
                         auxiliar_cent_max_dato          when (auxiliar_cent_max_dato < 100) else
                        (auxiliar_cent_max_dato - 100)  when (200 > auxiliar_cent_max_dato and auxiliar_cent_max_dato > 99)  else
                        (auxiliar_cent_max_dato - 200)  when (300 > auxiliar_cent_max_dato and auxiliar_cent_max_dato > 199) else
                        (auxiliar_cent_max_dato - 300)  when (400 > auxiliar_cent_max_dato and auxiliar_cent_max_dato > 299) else
                        (auxiliar_cent_max_dato - 400)  when (500 > auxiliar_cent_max_dato and auxiliar_cent_max_dato > 399) else
                        (auxiliar_cent_max_dato - 500)  when (600 > auxiliar_cent_max_dato and auxiliar_cent_max_dato > 499) else
                        (auxiliar_cent_max_dato - 600)  when (700 > auxiliar_cent_max_dato and auxiliar_cent_max_dato > 599) else
                        (auxiliar_cent_max_dato - 700)  when (800 > auxiliar_cent_max_dato and auxiliar_cent_max_dato > 699) else
                        (auxiliar_cent_max_dato - 800)  when (900 > auxiliar_cent_max_dato and auxiliar_cent_max_dato > 799) else
                        (auxiliar_cent_max_dato - 900);
  
  auxiliar_dec_max_dato <= auxiliar_dec_dato(6 downto 0);              
-- Obtenidas las decenas, podemos sacar el valor de las centenas.                
  centenas_bcd_dato <= "0000"  when reset = '1' else
	                     "0000"  when (auxiliar_cent_max_dato < 100) else
                       "0001"  when (200 > auxiliar_cent_max_dato and auxiliar_cent_max_dato > 99)  else
                       "0010"  when (300 > auxiliar_cent_max_dato and auxiliar_cent_max_dato > 199) else
                       "0011"  when (400 > auxiliar_cent_max_dato and auxiliar_cent_max_dato > 299) else
                       "0100"  when (500 > auxiliar_cent_max_dato and auxiliar_cent_max_dato > 399) else
                       "0101"  when (600 > auxiliar_cent_max_dato and auxiliar_cent_max_dato > 499) else
                       "0110"  when (700 > auxiliar_cent_max_dato and auxiliar_cent_max_dato > 599) else
                       "0111"  when (800 > auxiliar_cent_max_dato and auxiliar_cent_max_dato > 699) else
                       "1000"  when (900 > auxiliar_cent_max_dato and auxiliar_cent_max_dato > 799) else
                       "1001";  
                  
   
-----------------------------------------------                
-- Para valores entre 10 y 99, restamos y obtenemos las decenas  
 
 auxiliar_uni_dato <=  "0000000"    when reset = '1' else 
                        auxiliar_dec_max_dato       when (auxiliar_dec_max_dato < 10) else
                       (auxiliar_dec_max_dato - 10) when (20 > auxiliar_dec_max_dato and auxiliar_dec_max_dato > 9) else
                       (auxiliar_dec_max_dato - 20) when (30 > auxiliar_dec_max_dato and auxiliar_dec_max_dato > 19) else
                       (auxiliar_dec_max_dato - 30) when (40 > auxiliar_dec_max_dato and auxiliar_dec_max_dato > 29) else
                       (auxiliar_dec_max_dato - 40) when (50 > auxiliar_dec_max_dato and auxiliar_dec_max_dato > 39) else
                       (auxiliar_dec_max_dato - 50) when (60 > auxiliar_dec_max_dato and auxiliar_dec_max_dato > 49) else
                       (auxiliar_dec_max_dato - 60) when (70 > auxiliar_dec_max_dato and auxiliar_dec_max_dato > 59) else
                       (auxiliar_dec_max_dato - 70) when (80 > auxiliar_dec_max_dato and auxiliar_dec_max_dato > 69) else
                       (auxiliar_dec_max_dato - 80) when (90 > auxiliar_dec_max_dato and auxiliar_dec_max_dato > 79) else
                       (auxiliar_dec_max_dato - 90); 
                 
 -- Obtenidas las unidades, podemos sacar el valor de las decenas.                
  decenas_bcd_dato <=  "0000"  when reset = '1' else
	                "0000"  when (auxiliar_dec_max_dato < 10) else
                  "0001"  when (20 > auxiliar_dec_max_dato and auxiliar_dec_max_dato > 9)  else
                  "0010"  when (30 > auxiliar_dec_max_dato and auxiliar_dec_max_dato > 19) else
                  "0011"  when (40 > auxiliar_dec_max_dato and auxiliar_dec_max_dato > 29) else
                  "0100"  when (50 > auxiliar_dec_max_dato and auxiliar_dec_max_dato > 39) else
                  "0101"  when (60 > auxiliar_dec_max_dato and auxiliar_dec_max_dato > 49) else
                  "0110"  when (70 > auxiliar_dec_max_dato and auxiliar_dec_max_dato > 59) else
                  "0111"  when (80 > auxiliar_dec_max_dato and auxiliar_dec_max_dato > 69) else
                  "1000"  when (90 > auxiliar_dec_max_dato and auxiliar_dec_max_dato > 79) else
                  "1001";  
 
 -- Valor unidades
  unidades_bcd_dato <= auxiliar_uni_dato(3 downto 0);
  
  
  recor_bcd <= millares_bcd_dato&centenas_bcd_dato&decenas_bcd_dato&unidades_bcd_dato;  
  cuenta_num_mostrado_bcd <= millares_bcd_dato&centenas_bcd_dato&decenas_bcd_dato&unidades_bcd_dato;   
  posicion_secuencia_bcd <= millares_bcd_dato&centenas_bcd_dato&decenas_bcd_dato&unidades_bcd_dato;
  longitud_programada_bcd <= millares_bcd_dato&centenas_bcd_dato&decenas_bcd_dato&unidades_bcd_dato;
  puntuacion_out_bcd <= millares_bcd_dato&centenas_bcd_dato&decenas_bcd_dato&unidades_bcd_dato;    
   
   
-----------------------------Num_colores_Memoria ( start = '1' )----------------------------------------------------------------                 
-- Para valores entre 1000 y 9999, restamos y obtenemos las centenas                
  auxiliar_cent <=  "00000000000000"            when reset = '1' else 
                     num_colores          when (num_colores < 1000) else
                    (num_colores - 1000)  when (2000 > num_colores and num_colores > 999)  else
                    (num_colores - 2000)  when (3000 > num_colores and num_colores > 1999) else
                    (num_colores - 3000)  when (4000 > num_colores and num_colores > 2999) else
                    (num_colores - 4000)  when (5000 > num_colores and num_colores > 3999) else
                    (num_colores - 5000)  when (6000 > num_colores and num_colores > 4999) else
                    (num_colores - 6000)  when (7000 > num_colores and num_colores > 5999) else
                    (num_colores - 7000)  when (8000 > num_colores and num_colores > 6999) else
                    (num_colores - 8000)  when (9000 > num_colores and num_colores > 7999) else
                    (num_colores - 9000);
 
 auxiliar_cent_max <= auxiliar_cent(9 downto 0);
-- Obtenidas las centenas, podemos sacar el valor de los millares.                
  millares_bcd <= "0000"  when reset = '1' else
	                "0000"  when (num_colores < 1000) else
                  "0001"  when (2000 > num_colores and num_colores > 999)  else
                  "0010"  when (3000 > num_colores and num_colores > 1999) else
                  "0011"  when (4000 > num_colores and num_colores > 2999) else
                  "0100"  when (5000 > num_colores and num_colores > 3999) else
                  "0101"  when (6000 > num_colores and num_colores > 4999) else
                  "0110"  when (7000 > num_colores and num_colores > 5999) else
                  "0111"  when (8000 > num_colores and num_colores > 6999) else
                  "1000"  when (9000 > num_colores and num_colores > 7999) else
                  "1001";
                  
                                    
-----------------------------------------------                
-- Para valores entre 100 y 999, restamos y obtenemos las decenas  
  auxiliar_dec <=  "0000000000"     when reset = '1' else 
                   auxiliar_cent_max          when (auxiliar_cent_max < 100) else
                  (auxiliar_cent_max - 100)  when (200 > auxiliar_cent_max and auxiliar_cent_max > 99)  else
                  (auxiliar_cent_max - 200)  when (300 > auxiliar_cent_max and auxiliar_cent_max > 199) else
                  (auxiliar_cent_max - 300)  when (400 > auxiliar_cent_max and auxiliar_cent_max > 299) else
                  (auxiliar_cent_max - 400)  when (500 > auxiliar_cent_max and auxiliar_cent_max > 399) else
                  (auxiliar_cent_max - 500)  when (600 > auxiliar_cent_max and auxiliar_cent_max > 499) else
                  (auxiliar_cent_max - 600)  when (700 > auxiliar_cent_max and auxiliar_cent_max > 599) else
                  (auxiliar_cent_max - 700)  when (800 > auxiliar_cent_max and auxiliar_cent_max > 699) else
                  (auxiliar_cent_max - 800)  when (900 > auxiliar_cent_max and auxiliar_cent_max > 799) else
                  (auxiliar_cent_max - 900);
  
  auxiliar_dec_max <= auxiliar_dec(6 downto 0);              
-- Obtenidas las decenas, podemos sacar el valor de las centenas.                
  centenas_bcd <= "0000"  when reset = '1' else
	                "0000"  when (auxiliar_cent_max < 100) else
                  "0001"  when (200 > auxiliar_cent_max and auxiliar_cent_max > 99)  else
                  "0010"  when (300 > auxiliar_cent_max and auxiliar_cent_max > 199) else
                  "0011"  when (400 > auxiliar_cent_max and auxiliar_cent_max > 299) else
                  "0100"  when (500 > auxiliar_cent_max and auxiliar_cent_max > 399) else
                  "0101"  when (600 > auxiliar_cent_max and auxiliar_cent_max > 499) else
                  "0110"  when (700 > auxiliar_cent_max and auxiliar_cent_max > 599) else
                  "0111"  when (800 > auxiliar_cent_max and auxiliar_cent_max > 699) else
                  "1000"  when (900 > auxiliar_cent_max and auxiliar_cent_max > 799) else
                  "1001";  
                  
   
-----------------------------------------------                
-- Para valores entre 10 y 99, restamos y obtenemos las decenas  
 
 auxiliar_uni <=  "0000000"    when reset = '1' else 
                  auxiliar_dec_max       when (auxiliar_dec_max < 10) else
                 (auxiliar_dec_max - 10) when (20 > auxiliar_dec_max and auxiliar_dec_max > 9) else
                 (auxiliar_dec_max - 20) when (30 > auxiliar_dec_max and auxiliar_dec_max > 19) else
                 (auxiliar_dec_max - 30) when (40 > auxiliar_dec_max and auxiliar_dec_max > 29) else
                 (auxiliar_dec_max - 40) when (50 > auxiliar_dec_max and auxiliar_dec_max > 39) else
                 (auxiliar_dec_max - 50) when (60 > auxiliar_dec_max and auxiliar_dec_max > 49) else
                 (auxiliar_dec_max - 60) when (70 > auxiliar_dec_max and auxiliar_dec_max > 59) else
                 (auxiliar_dec_max - 70) when (80 > auxiliar_dec_max and auxiliar_dec_max > 69) else
                 (auxiliar_dec_max - 80) when (90 > auxiliar_dec_max and auxiliar_dec_max > 79) else
                 (auxiliar_dec_max - 90); 
                 
 -- Obtenidas las unidades, podemos sacar el valor de las decenas.                
  decenas_bcd <=  "0000"  when reset = '1' else
	                "0000"  when (auxiliar_dec_max < 10) else
                  "0001"  when (20 > auxiliar_dec_max and auxiliar_dec_max > 9)  else
                  "0010"  when (30 > auxiliar_dec_max and auxiliar_dec_max > 19) else
                  "0011"  when (40 > auxiliar_dec_max and auxiliar_dec_max > 29) else
                  "0100"  when (50 > auxiliar_dec_max and auxiliar_dec_max > 39) else
                  "0101"  when (60 > auxiliar_dec_max and auxiliar_dec_max > 49) else
                  "0110"  when (70 > auxiliar_dec_max and auxiliar_dec_max > 59) else
                  "0111"  when (80 > auxiliar_dec_max and auxiliar_dec_max > 69) else
                  "1000"  when (90 > auxiliar_dec_max and auxiliar_dec_max > 79) else
                  "1001";  
 
 -- Valor unidades
  unidades_bcd <= auxiliar_uni(3 downto 0);
    
  num_memoria_bcd <= millares_bcd&centenas_bcd&decenas_bcd&unidades_bcd;
                                                                
 end rtl;                