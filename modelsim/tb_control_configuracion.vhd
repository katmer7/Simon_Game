-- Test bench del modo de configuracion de juego.
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_control_configuracion is

end entity;

architecture test of tb_control_configuracion is

  signal clk               : std_logic;
  signal nRst              : std_logic;
  signal fin_partida       : std_logic;
  signal tecla             : std_logic_vector(3 downto 0);    
  signal tecla_valida_reg  : std_logic;
  signal reset             : std_logic;
  signal start             : std_logic;
  signal modo              : std_logic;
  signal lon               : std_logic;
  signal rec               : std_logic;
  signal recor             : std_logic_vector(13 downto 0);
  signal puntuacion        : std_logic_vector(13 downto 0);
  signal puntuacion_out        : std_logic_vector(13 downto 0);
  signal longitud_programada: std_logic_vector(15 downto 0);
  constant tclk:       time := 20 ns;

  begin

  dut: entity Work.control_configuracion(rtl)
    port map(clk => clk,
             nRst => nRst,
             tecla => tecla,
             tecla_valida_reg => tecla_valida_reg,
             fin_partida => fin_partida,
             reset => reset,
             start => start,
             modo => modo,
             lon => lon,
             rec => rec,
             recor => recor,
             puntuacion => puntuacion,
             puntuacion_out => puntuacion_out,
             longitud_programada => longitud_programada
             );
      

  reloj : process
  begin
    clk <= '0';
    wait for tclk/2;
    clk <= '1';
    wait for tclk/2;
  end process ;        -- Fin proceso generar reloj

-- Resumen de pruebas:
-- 1. Acceso a la longitud
-- 2. Marcación de una tecla válida y tecla no válida, comprobación de más de 4 teclas.
-- 3. Eliminación de teclas
-- 4. Entrar en el modo record sin haber empezado una partida
-- 5. Comprobacion de todas las teclas
-- 6. Comprobacion del estado del juego
-- 7. comprobacion de record despues del juego
-- 8. Variación de la longitud

  prueba : process
  begin
    -- Inicizalizacion asincrona
    nRst <=  '0';
    reset <= '0';
    puntuacion <= (others => '0');
    wait for tclk;
    wait until clk'event and clk='1';
    nRst    <= '1';
    -- Fin inicializacion asincrona

    -- Inicializacion sincrona
    tecla <= "1010";
    tecla_valida_reg <= '0';
    fin_partida <= '0';
    puntuacion <= "00000000000100";

    wait for tclk;
    wait until clk'event and clk='1';

    --1. Acceso a configurar longitud, letra D
    tecla <= "1101";
    tecla_valida_reg <= '1';
    wait for  tclk;
    wait until clk'event and clk='1';

    --Prueba que la tecla no afecta si tecla valida no esta activa
    tecla <= "1110";
    tecla_valida_reg <= '0';
    wait for 2*tclk;
    wait until clk'event and clk='1';

    --2. Se marca un 1 sin borrar (201)
    tecla <= "0001";
    tecla_valida_reg <= '1';
    wait for  tclk;
    wait until clk'event and clk='1';
    tecla_valida_reg <= '0';
    wait for 2*tclk;
    wait until clk'event and clk='1';
 
    --Se pulsan la A tecla no valida
    tecla_valida_reg <= '1';
    tecla <= "1010";
    wait for  tclk;
    wait until clk'event and clk='1';
    tecla_valida_reg <= '0';
    wait for 2*tclk;
    wait until clk'event and clk='1';

    --Se marca un 2 sin borrar (2012)
    tecla <= "0010";
    tecla_valida_reg <= '1';
    wait for  tclk;
    wait until clk'event and clk='1';
    tecla_valida_reg <= '0';
    wait for 2*tclk;
    wait until clk'event and clk='1';

    --Se añade otro numero para comprobar que no registra mas de 4
    tecla_valida_reg <= '1';
    tecla <= "0101";
    wait for  tclk;
    wait until clk'event and clk = '1';
    tecla_valida_reg <= '0';
    wait for 2*tclk;
    wait until clk'event and clk='1';

    --3. Se pulsa 6 veces a borrar
    borrado1 : for i in 0 to 5 loop
      tecla_valida_reg <= '1';
      tecla <= "1011";
      wait for tclk;
      wait until clk'event and clk = '1';
      tecla_valida_reg <= '0';
      wait for tclk;
      wait until clk'event and clk = '1';
    end loop ; --fin borrado1

    --Se mete el numero 77
    tecla_valida_reg <= '1';
    tecla <= "0111";
    wait for  tclk;
    wait until clk'event and clk='1';
    tecla_valida_reg <= '0';
    wait for 2*tclk;
    wait until clk'event and clk='1';
    tecla_valida_reg <= '1';
    wait for  tclk;
    wait until clk'event and clk='1';
    tecla_valida_reg <= '0';
    wait for 2*tclk;
    wait until clk'event and clk='1';

    --Se sale del modo configurar longitud
    tecla_valida_reg <= '1';
    tecla <= "1110";
    wait for  tclk;
    wait until clk'event and clk='1';
    tecla_valida_reg <= '0';
    wait for 2*tclk;
    wait until clk'event and clk='1';

    --4. Se intenta entrar en modo record aunque no haya habido partida antes
    tecla_valida_reg <= '1';
    tecla <= "1111";
    wait for  tclk;
    wait until clk'event and clk='1';
    tecla_valida_reg <= '0';
    wait for 2*tclk;
    wait until clk'event and clk='1';

------------------------------------------
    --5. Se pulsan teclas diferentes a D, F y A
  tecleo : for i in 0 to 9 loop
    tecla_valida_reg <= '1';
    tecla <= tecla + 1;
    wait for  tclk;
    wait until clk'event and clk='1';
    tecla_valida_reg <= '0';
    wait for 2*tclk;
    wait until clk'event and clk='1';
  end loop ; --fin tecleo
------------------------------------------

    --6. Se entra en el modo de juego
    tecla_valida_reg <= '1';
    tecla <= "1010";
    wait for  tclk;
    wait until clk'event and clk='1';
    tecla_valida_reg <= '0';

    --Tiempo de juego
    wait for 10*tclk;
    wait until clk'event and clk='1';
    
    --Se acaba la partida
    fin_partida <= '1';
    reset <= '1';
    wait for 1*tclk;
    wait until clk'event and clk='1';

    --Se inicia una nueva partida (tecla F)
    fin_partida <= '0';
    reset <= '0';
    wait for 8*tclk;
    wait until clk'event and clk='1';
    tecla_valida_reg <= '1';
    tecla <= "1111";
    wait for  tclk;
    wait until clk'event and clk='1';
    tecla_valida_reg <= '0';

    --Tiempo de juego
    wait for 15*tclk;
    wait until clk'event and clk='1';
    puntuacion <= "00000000000010";  -- comprobar puntuacion
    --Se acaba la partida
    fin_partida <= '1';
    reset <= '1';
    wait for 1*tclk;
    wait until clk'event and clk='1';

    --7. Se vuelve al menu de configuracion (tecla E)
    fin_partida <= '0';
    reset <= '0';
    wait for  8*tclk;
    wait until clk'event and clk='1';
    tecla_valida_reg <= '1';
    tecla <= "1110";
    wait for tclk;
    wait until clk'event and clk='1';
    tecla_valida_reg <= '0';
    wait for 2*tclk;
    wait until clk'event and clk = '1';

    --Se accede al ultimo record
    tecla_valida_reg <= '1';
    tecla <= "1111";
    wait for  tclk;
    wait until clk'event and clk='1';
    tecla_valida_reg <= '0';
    wait for 2*tclk;
    wait until clk'event and clk = '1';

    --Se sale del menu de record
    tecla_valida_reg <= '1';
    tecla <= "1110";
    wait for  tclk;
    wait until clk'event and clk='1';
    tecla_valida_reg <= '0';
    wait for 2*tclk;
    wait until clk'event and clk = '1';

    --8. Se accede a configuracion de longitud
    tecla_valida_reg <= '1';
    tecla <= "1101";
    wait for  tclk;
    wait until clk'event and clk='1';
    tecla_valida_reg <= '0';
    wait for 2*tclk;
    wait until clk'event and clk = '1';

    --Se borra todo
    borrado : for i in 0 to 3 loop
      tecla_valida_reg <= '1';
      tecla <= "1011";
      wait for tclk;
      wait until clk'event and clk = '1';
      tecla_valida_reg <= '0';
      wait for tclk;
      wait until clk'event and clk = '1';
    end loop ; -- fin borrado 

    --Se sale de configurar la longitud
    tecla_valida_reg <= '1';
    tecla <= "1110";
    wait for  tclk;
    wait until clk'event and clk='1';
    tecla_valida_reg <= '0';
    wait for 2*tclk;
    wait until clk'event and clk = '1';

    wait for 10*tclk;
    wait until clk'event and clk = '1';
    
    assert false
    report "done"
    severity failure;
  end process; --fin proceso prueba
end architecture test; --fin test