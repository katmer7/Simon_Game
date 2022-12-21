library ieee;
use ieee.std_logic_1164.all;

entity tb_presentacionDisplay is

end entity;

architecture test of tb_presentacionDisplay is

signal clk:                 std_logic;
signal nRst:                std_logic;
signal tic_mux_1ms:         std_logic;
signal modo:                std_logic;
signal Lon:                 std_logic;
signal rec:                 std_logic;
signal start:               std_logic;
signal reset:               std_logic;
signal tic_1s:               std_logic;
signal longitud_programada: std_logic_vector(15 downto 0);
signal recor:               std_logic_vector(15 downto 0);
signal posicion_secuencia:  std_logic_vector(15 downto 0);
signal puntuacion:          std_logic_vector(15 downto 0);
signal presentacion:        std_logic_vector (6 downto 0);
signal mux_display:         std_logic_vector (7 downto 0);
  constant tclk:       time := 20 ns;

  begin

  dut: entity Work.presentacionDisplays(rtl)
    port map(clk                 => clk,
             nRst                => nRst,
             tic_mux_1ms         => tic_mux_1ms,
             modo                => modo,
             Lon                 => Lon,
             rec                 => rec,
             start               => start,
             reset               => reset,
             tic_1s              => tic_1s,
             longitud_programada => longitud_programada,
             recor               => recor,
             posicion_secuencia  => posicion_secuencia,
             puntuacion          => puntuacion,
             presentacion        => presentacion,
             mux_display         => mux_display
             );
      
  --Se genera escalado para la lectura del test
  tic_1ms : process
  begin
    tic_mux_1ms <= '0';
    wait for tclk*5;
    tic_mux_1ms <= '1';
    wait for tclk;
end process ;        -- Fin proceso generar tic_1ms

tic_de1s : process
  begin
    tic_1s <= '0';
    wait for tclk*50;
    tic_1s <= '1';
    wait for tclk;
end process ;        -- Fin proceso generar tic_1ms

  reloj : process
  begin
    clk <= '0';
    wait for tclk/2;
    clk <= '1';
    wait for tclk;
  end process ;        -- Fin proceso generar reloj

  prueba : process
  begin
    -- Inicizalizacion asincrona
    nRst         <=  '0';
    wait for tclk;
    wait until clk'event and clk='1';
    nRst    <= '1';
    -- Fin inicialización asíncrona

    -- Inicializacion sincrona
    modo                <= '1';
    Lon                 <= '0';
    rec                 <= '0';
    start               <= '0';
    reset               <= '0';
    longitud_programada <= "0000000000100000";
    recor              <= "0000000000000000";
    posicion_secuencia  <= "0000000000000000";
    puntuacion          <= "0000000000000000";

    --Pasa el tiempo  para que se enciendan todos los displays

    wait for 45*tclk;
    wait until clk'event and clk='1';

    --Pasamos al modo de configurar longitud

    modo                <= '0';
    Lon                 <= '1';

    --Pasa el tiempo  para que se enciendan todos los displays

    wait for 45*tclk;
    wait until clk'event and clk='1';
    
    --Se borra un numero de la longitud

    longitud_programada <= "0000000000000010";

    --Pasa el tiempo  para que se enciendan todos los displays

    wait for 45*tclk;
    wait until clk'event and clk='1';

    --Se añaden 3 numeros
    longitud_programada <= "0010010100110000";

    --Pasa el tiempo  para que se enciendan todos los displays

    wait for 45*tclk;
    wait until clk'event and clk='1';

    --Pasamos a modo config de nuevo

    modo                <= '1';
    Lon                 <= '0';
    --Pasa el tiempo  para que se enciendan todos los displays

    wait for 45*tclk;
    wait until clk'event and clk='1';

    --Pasamos al modo partida

    modo                  <= '0';
    start                 <= '1';

    --Pasa el tiempo  para que se enciendan todos los displays

    wait for 45*tclk;
    wait until clk'event and clk='1';

    --Se avanza unas posiciones de secuencia y la puntuacion

    posicion_secuencia  <= "0000000000000100";
    puntuacion          <= "0000000000010000";

    --Pasa el tiempo  para que se enciendan todos los displays

    wait for 45*tclk;
    wait until clk'event and clk='1';

    --Se avanza unas posiciones de secuencia y la puntuacion

    posicion_secuencia  <= "0000100000110011";
    puntuacion          <= "0111000001000011";

    --Pasa el tiempo  para que se enciendan todos los displays

    wait for 45*tclk;
    wait until clk'event and clk='1';

    --Acaba la partida 

    start <= '0';
    reset <= '1';
    recor <= puntuacion;

    --Pasa el tiempo  para que se enciendan todos los displays y se comprueba que se encienden con el tic de 1 segundo

    wait for 300*tclk;
    wait until clk'event and clk='1';

    --Se vuelve al modo configuracion

    reset <= '0';
    modo <= '1';

    --Pasa el tiempo  para que se enciendan todos los displays

    wait for 45*tclk;
    wait until clk'event and clk='1';

    --Se va al modo recor

    rec <= '1';
    modo <= '0';

    --Pasa el tiempo  para que se enciendan todos los displays 2 veces

    wait for 90*tclk;
    wait until clk'event and clk='1';

   assert false
    report "fone"
    severity failure;

  end process; --fin proceso prueba
 end test; --fin del test
   
