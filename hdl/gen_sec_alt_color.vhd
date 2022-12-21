-- Generador aleatorio de colores
-- Se obtiene el valor del color aleatorio cuando se requiere
-- y además, dos señales de salida que indican la validación del color y cuando
-- se está disponible para poder coger otro color.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity gen_sec_alt_color is
  port (
	clk:  			in std_logic;
	nRst:			in std_logic;
	pick_clr:		in std_logic;						                           -- enable para generar color
    
	clr_picked: buffer std_logic_vector(1 downto 0);         -- Dato de entrada de la memoria
	clr_ready: buffer std_logic); 					                      -- activa habilitacion de escritura (WR) de la memoria				                 
end entity;  

architecture rtl of gen_sec_alt_color is	
 type 	t_estado is (rojo, verde, amarillo);
 signal 	estado: t_estado;

 begin

 process(clk, nRst)
 begin
	if nRst = '0' then
		 estado <= rojo ;
	elsif clk'event and clk ='1' then
	  
	  case estado is
		when rojo =>
			estado <= verde;
		when verde =>
			estado <= amarillo;
		when others =>
			estado <= rojo;
		end case;
	end if;
end process;  


-- Detectamos color
clr_picked <= "01" when estado = rojo and pick_clr ='1'
                  	else "10" when estado = verde	and pick_clr ='1'
			            	else "11" when estado = amarillo	and pick_clr ='1' 
                   else "00";

-- Color valido               
clr_ready <= '1' when clr_picked /= "00" and pick_clr ='1'
                 	else '0';

  
end architecture ; 