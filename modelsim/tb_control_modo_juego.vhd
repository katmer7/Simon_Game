-- Test bench del modo de juego.
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_control_modo_juego is

end entity;

architecture test of tb_control_modo_juego is

  signal clk: std_logic;
  signal nRst: std_logic;
	signal clr_ready:	 std_logic; 					                                    -- Habilitación de escritura (wr)
	signal start:  std_logic;                                              -- Habilitación para el inicio del modo juego
	signal we_mem:  std_logic;                                             -- Indica que la escritura se ha realizado
  signal full_programado:		std_logic;                                    -- Indica que se ha llegado a la longitud programada
  signal fin_lectura_secuencia: 	std_logic;                              -- Se termina de leer toda la memoria
  signal tic_1s:  std_logic;
  signal flanco_bajada_col:  std_logic;                                  -- Tic se ha dejado de pulsar COLUMNA
  signal tiempo_secuencia:  std_logic;                                   -- Forma de onda de 0.2 a '0' y 0.8 a '1' 
  signal columna_color :  std_logic_vector(1 downto 0);                  -- Columna pulsada
  signal d_out:  	std_logic_vector(1 downto 0);                          -- Color leído
       
   signal color_salida:  std_logic_vector(1 downto 0);                -- Color para la interfaz de salida	                                         
   signal pick_clr:	 std_logic;					                                  -- Señal para generar el color
   signal rst_time:  std_logic;                                       -- Señal para resetar el temporizador
   signal reset:  std_logic;                                          -- Señal para resetear la memoria y longitud
   signal rd:  std_logic;                                             -- Habilitación para la lectura
   signal nueva_lectura:  std_logic;                                  -- Indico nueva lectura, reseteo de addr
   signal mostrando_secuencia:  std_logic;                            -- Activado durante el estado de mostrar secuencia
   signal fin_partida:	 std_logic;                                    -- Indico al automata de CONF que se ha terminado la partida
   signal posicion_secuencia: std_logic_vector(13 downto 0);
   signal puntuacion:  std_logic_vector(13 downto 0);
  constant tclk: time := 20 ns;

  begin

  dut: entity Work.control_modo_juego(rtl)
    port map(clk => clk,
             nRst => nRst,
             clr_ready => clr_ready,
             start => start,
             we_mem => we_mem,
             full_programado => full_programado,
             fin_lectura_secuencia => fin_lectura_secuencia,
             tic_1s => tic_1s,
             tiempo_secuencia => tiempo_secuencia,
             flanco_bajada_col => flanco_bajada_col,
             columna_color => columna_color,
             d_out => d_out,
             
             color_salida => color_salida,
             pick_clr => pick_clr,
             rst_time => rst_time,
             rd => rd,
             nueva_lectura => nueva_lectura,
             mostrando_secuencia => mostrando_secuencia,
             fin_partida => fin_partida,
             puntuacion => puntuacion             
             );
      

  reloj : process
  begin 
    clk <= '1';
    wait for tclk/2;
    clk <= '0';
    wait for tclk/2;
  end process ;        -- Fin proceso generar reloj

-- PRUEBAS REALIZADAS:
-- 1. Generacion del pick_clr  
-- 2. Mostradamos una secuencia de 4 colores, comprobar que en la salida(color_salida), tenemos durante 2 ciclos el valor "00"
-- y durante 8 ciclos el valor del color. También se comprueba la señal RD
-- 3. Terminamos de mostrar las 4 lecturas y pasamos a detectar COL pulsada
-- 4. Deteccion del primer color de la memoria y la columna pulsada
-- 5. Se detecta pulsacion de columna, y cambio de estado para poder comprobar si el color es correcto o no
-- 6. Se comrpueba el segundo color
-- 7. Color incorrecto, comprobamos FIN.
-- 8. Comprobamos añadir un color
-- 9. se ha llegado a la longitud maxima y comprobacion de que se termina

  prueba : process
  begin
    -- Inicizalizacion asincrona
    reset <= '0';
    clr_ready <= '0';
    start <= '0';
    we_mem <= '0';
    full_programado <= '0';
    fin_lectura_secuencia <= '0';
    tic_1s <= '0';                     -- 10 ciclos son 1 segundo
    tiempo_secuencia <= '0';
    flanco_bajada_col <= '0';
    columna_color <= (others => '0');
    d_out <= (others => '0');
    
    nRst <=  '0';
    wait for 5*tclk;
    wait until clk'event and clk='1';
    nRst    <= '1';
    -- Fin inicializacion asincrona

    -- Inicializacion sincrona    
    ---------------------------------- 1. El automata CONF inicia STAR:
    start <= '1';  
    wait until clk'event and clk='1';    -- Se genera pick_clr
    we_mem <= '1';
    clr_ready <= '1';
    wait until clk'event and clk='1';
    we_mem <= '0';
    clr_ready <= '0';
   
    ---------------------------------- 2. Estado mostrar secuencia, 4 LECTURAS:
    -- Lectura 1 
    d_out <= "01";       
    wait for 3*tclk;                    -- 2 ciclos a nivel bajo (pongo 3 porq el automata manda resetear el timer y hay q esperar un estado mas)
    wait until clk'event and clk='1'; 
    tiempo_secuencia <= '1'; 
    wait for 7*tclk;                    -- 8 ciclos a nivel alto
    wait until clk'event and clk='1'; 
    tic_1s <= '1';
    wait until clk'event and clk='1';   -- cuando se cumple tic 1s, GENERA RD 1tclk.
    tic_1s <= '0';
    -- Lectura 2 
    d_out <= "10";
    tiempo_secuencia <= '0';            
    wait for 2*tclk;                    -- 2 ciclos a nivel bajo
    wait until clk'event and clk='1'; 
    tiempo_secuencia <= '1'; 
    wait for 7*tclk;                    -- 8 ciclos a nivel alto
    wait until clk'event and clk='1'; 
    tic_1s <= '1';
    wait until clk'event and clk='1';   -- cuando se cumple tic 1s, GENERA RD 1tclk.
    tic_1s <= '0';
    -- Lectura 3
    d_out <= "11";
    tiempo_secuencia <= '0';            
    wait for 2*tclk;                    -- 2 ciclos a nivel bajo
    wait until clk'event and clk='1'; 
    tiempo_secuencia <= '1'; 
    wait for 7*tclk;                    -- 8 ciclos a nivel alto
    wait until clk'event and clk='1'; 
    tic_1s <= '1';
    wait until clk'event and clk='1';   -- cuando se cumple tic 1s, GENERA RD 1tclk.
    tic_1s <= '0';
    -------------------------------------- 3. Terminamos de mostrar secuencia, terminado 4 LECTURAS
    -- Lectura 4  
    d_out <= "10";
    tiempo_secuencia <= '0';            
    wait until clk'event and clk='1';   -- 2 ciclos a nivel bajo
    fin_lectura_secuencia <= '1';
    wait until clk'event and clk='1';
    tiempo_secuencia <= '1'; 
    wait for 7*tclk;                    -- 8 ciclos a nivel alto 
    wait until clk'event and clk='1'; 
    tic_1s <= '1';
    wait until clk'event and clk='1';   -- cuando se cumple tic 1s, GENERA RD 1tclk.
    tic_1s <= '0';
    tiempo_secuencia <= '0'; 
    
    -------------------------------------- 4. Registramos el primer color de la memoria y COL pulsada
    wait until clk'event and clk='1';
    fin_lectura_secuencia <= '0';
    wait until clk'event and clk='1'; 
    d_out <= "01";
    wait for 5*tclk;
    wait until clk'event and clk='1';
    columna_color <= "01";  
    ------------------------------------- 5. comprobar
    wait for 6*tclk;
    wait until clk'event and clk='1';
    flanco_bajada_col <= '1';
    columna_color <= "00";
    wait until clk'event and clk='1';
    flanco_bajada_col <= '0';
    
    ------------------------------------- 6. compracion con el segundo color, deteccion de la tecla pulsada y comprobacion
    wait for 3*tclk;
    wait until clk'event and clk='1';
    d_out <= "10";
    wait for 5*tclk;
    wait until clk'event and clk='1';
    columna_color <= "10";  
    wait for 6*tclk;  -- comprobar
    wait until clk'event and clk='1';
    flanco_bajada_col <= '1';
    columna_color <= "00";
    wait until clk'event and clk='1';
    flanco_bajada_col <= '0';
    wait for 3*tclk;
    wait until clk'event and clk='1';
    
    ------------------------------------- 7. Tercer color y genera fallo
    d_out <= "11";
    wait for 5*tclk;
    wait until clk'event and clk='1';
    columna_color <= "10";  
    wait for 6*tclk;  -- comprobar
    wait until clk'event and clk='1';
    flanco_bajada_col <= '1';
    columna_color <= "00";
    wait until clk'event and clk='1';
    flanco_bajada_col <= '0';
    wait for 2*tclk;
    wait until clk'event and clk='1';
    start <= '0';
    wait for 20*tclk;
    wait until clk'event and clk='1';
    
    -------------------------------------
    ------------------------------------- 8. Empezar partida, completar secuencia y añadir nuevo color, full_programado = 0
    start <= '1';  
    wait until clk'event and clk='1';    -- Se genera pick_clr
    we_mem <= '1';
    clr_ready <= '1';
    wait until clk'event and clk='1';
    we_mem <= '0';
    clr_ready <= '0';
   ---------------------------------- 
    -- Lectura 1 
    d_out <= "01";       
    wait for 3*tclk;                    -- 2 ciclos a nivel bajo (pongo 3 porq el automata manda resetear el timer y hay q esperar un estado mas)
    wait until clk'event and clk='1'; 
    tiempo_secuencia <= '1'; 
    wait for 7*tclk;                    -- 8 ciclos a nivel alto
    wait until clk'event and clk='1'; 
    tic_1s <= '1';
    wait until clk'event and clk='1';   -- cuando se cumple tic 1s, GENERA RD 1tclk.
    tic_1s <= '0';
    -- Lectura 2 
    d_out <= "10";
    tiempo_secuencia <= '0';  
    wait for 2*tclk;                    -- 2 ciclos a nivel bajo
    wait until clk'event and clk='1'; 
    tiempo_secuencia <= '1'; 
    wait for 7*tclk;                    -- 8 ciclos a nivel alto
    wait until clk'event and clk='1'; 
    tic_1s <= '1';
    wait until clk'event and clk='1';   -- cuando se cumple tic 1s, GENERA RD 1tclk.
    tic_1s <= '0';
    -- Lectura 3
    d_out <= "11";
    tiempo_secuencia <= '0';            
    wait for 2*tclk;                    -- 2 ciclos a nivel bajo
    wait until clk'event and clk='1'; 
    tiempo_secuencia <= '1'; 
    wait for 7*tclk;                    -- 8 ciclos a nivel alto
    wait until clk'event and clk='1'; 
    tic_1s <= '1';
    wait until clk'event and clk='1';   
    tic_1s <= '0';
    -- Lectura 4  
    d_out <= "10";
    tiempo_secuencia <= '0';            
    wait until clk'event and clk='1';   -- 2 ciclos a nivel bajo
    fin_lectura_secuencia <= '1';
    wait until clk'event and clk='1';
    tiempo_secuencia <= '1'; 
    wait for 7*tclk;                    -- 8 ciclos a nivel alto 
    wait until clk'event and clk='1'; 
    tic_1s <= '1';
    wait until clk'event and clk='1';   
    tic_1s <= '0';
    tiempo_secuencia <= '0'; 
    
    ------------------------------------
    wait until clk'event and clk='1';
    fin_lectura_secuencia <= '0';
    wait until clk'event and clk='1'; 
    d_out <= "01";
    wait for 5*tclk;
    wait until clk'event and clk='1';
    columna_color <= "01";  
    -- ACERTAMOS COLOR 1
    wait for 6*tclk;
    wait until clk'event and clk='1';
    flanco_bajada_col <= '1';
    columna_color <= "00";
    wait until clk'event and clk='1';
    flanco_bajada_col <= '0';
    
    -- ACERTAMOS COLOR 2
    wait for 3*tclk;
    wait until clk'event and clk='1';
    d_out <= "10";
    wait for 5*tclk;
    wait until clk'event and clk='1';
    columna_color <= "10";  
    wait for 6*tclk;  
    wait until clk'event and clk='1';
    flanco_bajada_col <= '1';
    columna_color <= "00";
    wait until clk'event and clk='1';
    flanco_bajada_col <= '0';
    wait for 3*tclk;
    wait until clk'event and clk='1';
    -- ACERTAMOS COLOR 3
     d_out <= "11";
    wait for 5*tclk;
    wait until clk'event and clk='1';
    columna_color <= "11";  
    wait for 6*tclk;  -- comprobar
    wait until clk'event and clk='1';
    flanco_bajada_col <= '1';
    columna_color <= "00";
    wait until clk'event and clk='1';
    flanco_bajada_col <= '0';
    wait for 2*tclk;
    wait until clk'event and clk='1';
    -- ACERTAMOS COLOR 4
     d_out <= "10";
    wait for 5*tclk;
    wait until clk'event and clk='1';
    columna_color <= "10"; 
    wait until clk'event and clk='1';
    wait until clk'event and clk='1';     -- Activamos fin secuencia para poder introducir un nuevo color 
    fin_lectura_secuencia <= '1';
    wait for 4*tclk;  -- comprobar
    wait until clk'event and clk='1';
    flanco_bajada_col <= '1';
    columna_color <= "00";
    wait until clk'event and clk='1';
    flanco_bajada_col <= '0';
    wait for 2*tclk;
    wait until clk'event and clk='1';
    wait for 20*tclk;                    -- Esperamos añadir un nuevo color
    wait until clk'event and clk='1';
    columna_color <= "01";  
    wait until clk'event and clk='1';
    wait until clk'event and clk='1';
    wait until clk'event and clk='1';
    flanco_bajada_col <= '1';
    wait until clk'event and clk='1';
    columna_color <= "00"; 
    flanco_bajada_col <= '0';
    -------------------------------------
    ------------------------------------- 9. Nuevo color, full_programado
    wait until clk'event and clk='1';    -- Se genera pick_clr
    we_mem <= '1';
    clr_ready <= '1';
    wait until clk'event and clk='1';
    we_mem <= '0';
    clr_ready <= '0';
    fin_lectura_secuencia <= '0';
    
    -- Lectura 1 
    d_out <= "01";       
    wait for 2*tclk;                    -- 2 ciclos a nivel bajo (pongo 3 porq el automata manda resetear el timer y hay q esperar un estado mas)
    wait until clk'event and clk='1';
    wait until clk'event and clk='1'; 
    tiempo_secuencia <= '1'; 
    wait for 7*tclk;                    -- 8 ciclos a nivel alto
    wait until clk'event and clk='1'; 
    tic_1s <= '1';
    wait until clk'event and clk='1';   -- cuando se cumple tic 1s, GENERA RD 1tclk.
    tic_1s <= '0';
    -- Lectura 2 
    d_out <= "10";
    tiempo_secuencia <= '0';         
    wait for 2*tclk;                    -- 2 ciclos a nivel bajo
    wait until clk'event and clk='1'; 
    tiempo_secuencia <= '1'; 
    wait for 7*tclk;                    -- 8 ciclos a nivel alto
    wait until clk'event and clk='1'; 
    tic_1s <= '1';
    wait until clk'event and clk='1';   -- cuando se cumple tic 1s, GENERA RD 1tclk.
    tic_1s <= '0';
    -- Lectura 3
    d_out <= "11";
    tiempo_secuencia <= '0';            
    wait for 2*tclk;                    -- 2 ciclos a nivel bajo
    wait until clk'event and clk='1'; 
    tiempo_secuencia <= '1'; 
    wait for 7*tclk;                    -- 8 ciclos a nivel alto
    wait until clk'event and clk='1'; 
    tic_1s <= '1';
    wait until clk'event and clk='1';   
    tic_1s <= '0';
    -- Lectura 4  
    d_out <= "10";
    tiempo_secuencia <= '0';            
    wait until clk'event and clk='1';   -- 2 ciclos a nivel bajo
    fin_lectura_secuencia <= '1';
    wait until clk'event and clk='1';
    tiempo_secuencia <= '1'; 
    wait for 7*tclk;                    -- 8 ciclos a nivel alto 
    wait until clk'event and clk='1'; 
    tic_1s <= '1';
    wait until clk'event and clk='1';   
    tic_1s <= '0';
    tiempo_secuencia <= '0'; 
    
    ------------------------------------
    wait until clk'event and clk='1';
    fin_lectura_secuencia <= '0';
    wait until clk'event and clk='1'; 
    d_out <= "01";
    wait for 5*tclk;
    wait until clk'event and clk='1';
    columna_color <= "01";  
    -- ACERTAMOS COLOR 1
    wait for 6*tclk;
    wait until clk'event and clk='1';
    flanco_bajada_col <= '1';
    columna_color <= "00";
    wait until clk'event and clk='1';
    flanco_bajada_col <= '0';
    
    -- ACERTAMOS COLOR 2
    wait for 3*tclk;
    wait until clk'event and clk='1';
    d_out <= "10";
    wait for 5*tclk;
    wait until clk'event and clk='1';
    columna_color <= "10";  
    wait for 6*tclk;  
    wait until clk'event and clk='1';
    flanco_bajada_col <= '1';
    columna_color <= "00";
    wait until clk'event and clk='1';
    flanco_bajada_col <= '0';
    wait for 3*tclk;
    wait until clk'event and clk='1';
    -- ACERTAMOS COLOR 3
     d_out <= "11";
    wait for 5*tclk;
    wait until clk'event and clk='1';
    columna_color <= "11";  
    wait for 6*tclk;  -- comprobar
    wait until clk'event and clk='1';
    flanco_bajada_col <= '1';
    columna_color <= "00";
    wait until clk'event and clk='1';
    flanco_bajada_col <= '0';
    wait for 2*tclk;
    wait until clk'event and clk='1';
    -- ACERTAMOS COLOR 4
     d_out <= "10";
    wait for 5*tclk;
    wait until clk'event and clk='1';
    columna_color <= "10"; 
    wait until clk'event and clk='1';
    wait until clk'event and clk='1';     -- Activamos fin secuencia para poder introducir un nuevo color 
    fin_lectura_secuencia <= '1';
    full_programado <= '1';
    wait for 4*tclk;  -- comprobar
    wait until clk'event and clk='1';
    flanco_bajada_col <= '1';
    columna_color <= "00";
    wait until clk'event and clk='1';
    flanco_bajada_col <= '0';
    wait for 2*tclk;
    wait until clk'event and clk='1';
    start <= '0';
    fin_lectura_secuencia <= '0';
    full_programado <= '0';
    wait for 20*tclk;                    -- Esperamos añadir un nuevo color
    wait until clk'event and clk='1';

    assert false
    report "done"
    severity failure;
  end process; --fin proceso prueba
end architecture test; --fin test
  