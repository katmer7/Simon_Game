-- SIMON_SIN_TEC

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_SIMON_sin_tec is
end entity;
  
architecture tb of tb_SIMON_sin_tec is
  signal clk: std_logic;
  signal nRst: std_logic;
	signal tecla:           std_logic_vector(3 downto 0);
  signal tecla_valida_reg:  std_logic;
  signal duracion_pulso:    std_logic;
  signal flanco_bajada_col:  std_logic;
  signal columna_color:  std_logic_vector (1 downto 0);
      
      
  signal  presentacion:			 std_logic_vector (7 downto 0);
  signal  barra_leds:      std_logic_vector(2 downto 0);
  signal  leds:            std_logic_vector (2 downto 0);
	signal  mux_display:			  std_logic_vector (7 downto 0);
  constant tclk: time := 20 ns;
  begin
    
    
     dut: entity Work.SIMON_sin_tec(struct)
    port map(clk => clk,
             nRst => nRst,
             tecla => tecla,
             tecla_valida_reg => tecla_valida_reg,
             duracion_pulso => duracion_pulso,
             flanco_bajada_col => flanco_bajada_col,
             presentacion => presentacion,
             barra_leds => barra_leds,
             leds => leds,
             mux_display => mux_display,
             columna_color => columna_color);
             
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
 tecla <= (others => '0');
 tecla_valida_reg <= '0'; 
 duracion_pulso <= '0';
 flanco_bajada_col <= '0';
 columna_color <= (others => '0');
 wait for 5*tclk;
 wait until clk'event and clk='1';
 nRst    <= '1';
 -- Fin inicializacion asincrona      
  
 wait for 5*tclk;
 wait until clk'event and clk='1';
 tecla <= "1010";
 wait until clk'event and clk='1';
 tecla_valida_reg <= '1';
 wait until clk'event and clk='1';
 tecla_valida_reg <= '0';
 wait for 10*tclk;
 wait until clk'event and clk='1';
 flanco_bajada_col <= '1';
 wait until clk'event and clk='1';
 flanco_bajada_col <= '0';
 
 wait for 800*tclk;
 wait until clk'event and clk='1'; 
 columna_color <= "11";
 
 wait for 30*tclk;
 wait until clk'event and clk='1';
 flanco_bajada_col <= '1';
 wait until clk'event and clk='1';
 flanco_bajada_col <= '0';
  
  
 wait for 500*tclk;
 wait until clk'event and clk='1'; 
 tecla <= "1011";
 wait for 30*tclk;
 wait until clk'event and clk='1';
 flanco_bajada_col <= '1';
 wait until clk'event and clk='1';
 flanco_bajada_col <= '0';
  wait for 30*tclk;
 wait until clk'event and clk='1';
 columna_color <= "00";

 wait for 400*tclk;
 wait until clk'event and clk='1'; 
 columna_color <= "11";
 
 wait for 30*tclk;
 wait until clk'event and clk='1';
 flanco_bajada_col <= '1';
 wait until clk'event and clk='1';
 flanco_bajada_col <= '0';
 columna_color <= "00";

 wait for 80*tclk;
 wait until clk'event and clk='1';
 columna_color <= "01";
 wait for 30*tclk;
 wait until clk'event and clk='1';
 flanco_bajada_col <= '1';
 wait until clk'event and clk='1';
 flanco_bajada_col <= '0';
 columna_color <= "00";
 wait for 2000*tclk;
 wait until clk'event and clk='1'; 
 assert false
 report "done"
 severity failure;    
 end process;

end tb; 
       
             