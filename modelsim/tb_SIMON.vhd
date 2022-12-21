library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_SIMON is
end entity;

architecture tb of tb_SIMON is
  signal clk: std_logic;
  signal nRst: std_logic;
	signal columna: std_logic_vector(3 downto 0);
  signal fila: std_logic_vector(3 downto 0);
	signal presentacion:  std_logic_vector (7 downto 0);                                     
  signal barra_leds: std_logic_vector(2 downto 0);                        
  signal leds:	 std_logic_vector(2 downto 0);                       
  signal mux_display :  std_logic_vector (7 downto 0);      
  constant tclk: time := 20 ns;
  begin


 dut: entity Work.SIMON(struct)
    port map(clk => clk,
             nRst => nRst,
             columna => columna,
             fila => fila,
             presentacion => presentacion,
             barra_leds => barra_leds,
             leds => leds,
             mux_display => mux_display);
             
             
-- RELOJ
reloj : process
  begin 
    clk <= '1';
    wait for tclk/2;
    clk <= '0';
    wait for tclk/2;
end process ;        -- Fin proceso generar reloj 


--PRUEBAS
prueba : process
begin
 -- Inicizalizacion asincrona
 nRst <=  '0';
 columna <= (others => '0'); 
 wait for 5*tclk;
 wait until clk'event and clk='1';
 nRst    <= '1';
 -- Fin inicializacion asincrona

 -- Inicializacion sincrona 
 ---------------------------------------- CONF LONGITUD     
  columna <= "1110";  
 
 wait for 10*tclk; 
 wait until clk'event and clk='1'; 

 columna <= "1111";  


 wait for 400*tclk; 
 wait until clk'event and clk='1'; 

 assert false;
 report "fone"
 severity failure;



end process;
end tb;
