-- Interfaz de salida de representacion de los leds

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity presentacionLeds is
port(
     clk:				 	in	   std_logic;
	   nRst:					in	   std_logic;
	   start:					  in	   std_logic;
	   duracion_pulso:			  	in	   std_logic;
	   mostrando_secuencia:	in	   std_logic;
	   color_salida:			 in	   std_logic_vector(1 downto 0);
	   columna_color:			in	   std_logic_vector(1 downto 0);
	   tic_1ms:         in std_logic;

	   leds:           buffer std_logic_vector (2 downto 0);
	   barra_leds:			  buffer std_logic_vector (2 downto 0)
	 );
end entity;

architecture rtl of presentacionLeds is
signal color_salida_aux: std_logic_vector(1 downto 0);
begin
  
--Control del color mostrado
	color_salida_aux <= color_salida  when mostrando_secuencia = '1' and start = '1' else
					            columna_color when duracion_pulso = '1'  and mostrando_secuencia = '0'  and start = '1' else
					            "00";

-- Decodificador de colores
	process(color_salida_aux)
	begin
	case(color_salida_aux) is
	     when "00" => barra_leds <= "111"; -- desactivado
	     when "01" => barra_leds <= "011"; -- barra roja
	     when "10" => barra_leds <= "101"; -- barra amarilla
	     when "11" => barra_leds <= "110"; -- barra verde
	     when others => barra_leds <= "XXX";
	    end case;
end process;


leds <= "111" when color_salida_aux /= "00"
              else "000";


end architecture ; -- rtl
