--- TODO: FAZER OS SINAIS DE PEDESTRE PISCAREM
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
	
entity projeto_semaforo is 
	generic(
	   ---1s = 60hz
		---44s = 2640
		---48s = 2880
		---52s = 3120
		---56s = 3360
		---59s = 3540
		---63s = 3780
		---90s = 5400
		---93s = 5580
		---97s = 5820
		time_vermelho_vermelho_verde: POSITIVE := 26;--40; --44s
		time_vermelho_vermelho_amarelo: POSITIVE := 24;--0; --4s
		time_vermelho: POSITIVE := 24;--0; --4s
		time_vermelho1: POSITIVE := 24;--0; --4s
		time_vermelho2: POSITIVE := 18;--0; --3s
		time_vermelho3: POSITIVE := 24;--0; --4s
		time_verde: POSITIVE := 16;--20; --27s
		time_amarelo_verde_verde: POSITIVE := 18;--0; --3s
		time_vermelho_amarelo_verde: POSITIVE := 24;--0; --4S
		timeTEST: POSITIVE := 6;--0;
		timeMAX: POSITIVE := 2640);
		
	PORT(
		clk, stby, test: IN std_logic;
		nclk, nclk1: inout std_logic;
		r0, r1, r2, r3, r4 ,y0, y1, y2, y3, y4, g0, g1, g2, g3, g4,p1g, p2g, p3g, p4g, p5g, p1r,p2r,p3r,p4r,p5r: out std_logic); --- define as cores de cada sinal r vermelho, y amarelo e g verde
		--- Os sinais da  avenida maracana sao definidos por r1, y1, g1 e os da eurico rabello pela as demais variaveis com r,g, b
		--- os sinais de pedestre sao definidos pelas saidas com p
		
end projeto_semaforo;

architecture fsm of projeto_semaforo is 
	type state is (eurico_vermelho_vermelho_verde, eurico_vermelho_vermelho_amarelo, eurico_vermelho, eurico_vermelho1, eurico_vermelho2,
	eurico_vermelho3, eurico_verde, eurico_amarelo_verde_verde, eurico_vermelho_amarelo_verde, eurico_amarelo);
	SIGNAL pr_state, nx_state: state;
	SIGNAL timer: integer range 0 to timeMAX;
	SIGNAL cont: integer range 0 to 416666;
	SIGNAL cont_pedestre: integer range 0 to 30;
	SIGNAL clk1: std_logic := '0';
	SIGNAL clk2: std_logic := '0';
	SIGNAL ps1,ps2,ps3,ps4,ps5: std_logic;
BEGIN
 ---DIVISOR DE CLOCK
	PROCESS(clk)
		BEGIN
			IF(clk 'event and clk='1') THEN
				IF(cont < 416666) THEN
					cont <= cont + 1;
				ELSE
					cont <= 0;
					clk1 <= not clk1;
				END IF;
					nclk <= clk1;
			END IF;		
		END PROCESS;
		
	---DIVISOR DE CLOCK SINAL DE PEDESTRES
		PROCESS(nclk) -- @
			BEGIN
				IF(nclk 'event and nclk='1') THEN --@
					IF(cont_pedestre < 29) THEN
						cont_pedestre <= cont_pedestre + 1;
					ELSE
						cont_pedestre <=  0;
						clk2 <= not clk2;
					END IF;
						nclk1 <= clk2;
				END IF;
			END PROCESS;	
	
	PROCESS (clk) --@
		VARIABLE count : INTEGER RANGE 0 TO timeMAX;
	BEGIN
		IF (stby='1') THEN
			pr_state <= eurico_amarelo;
			count := 0;
			ELSIF (clk'EVENT AND clk='1') THEN
				count := count + 1;
				IF (count >=timer) THEN
					pr_state <= nx_state;
					count := 0;
				END IF;
			END IF;
	END PROCESS;

	---SEMAFORO
	PROCESS (pr_state, test)
	BEGIN
		CASE pr_state IS
			WHEN eurico_vermelho_vermelho_verde => 
		      r0<='0'; y0<='0'; g0<='1'; --- verde
				r1<='0'; y1<='0'; g1<='1'; --- verde 
				r2<='1'; y2<='0'; g2<='0'; --- vermelho
				r3<='1'; y3<='0'; g3<='0'; --- vermelho
				r4<='0'; y4<='0'; g4<='1'; --- verde
				p1g<='1'; p1r<='0'; ps1<='0'; --- verde
				p2g<='0'; p2r<='1'; ps2<='0'; --- vermelho
				p3g<='0'; p3r<='1'; ps3<='0'; --- vermelho
				p4g<='0'; p4r<='1'; ps4<='0';--- vermelho
				p5g<='0'; p5r<='1'; ps5<='0';--- vermelho
				nx_state <= eurico_vermelho_vermelho_amarelo;
				IF (test='0') THEN
					timer <= time_vermelho_vermelho_verde;
				ELSE
					timer <= timeTEST;
				END IF;
			WHEN eurico_vermelho_vermelho_amarelo => 
			   r0<='0'; y0<='1'; g0<='0'; --- amarelo
				r1<='0'; y1<='1'; g1<='0'; --- amarelo
				r2<='1'; y2<='0'; g2<='0'; --- vermelho
				r3<='1'; y3<='0'; g3<='0'; --- vermelho
				r4<='0'; y4<='1'; g4<='0'; --- amarelo
				p1g<='1'; p1r<='0'; ps1<='0'; --- verde
				p2g<='0'; p2r<='1'; ps2<='0';--- vermelho
				p3g<='0'; p3r<='1'; ps3<='0';--- vermelho
				p4g<='0'; p4r<='1'; ps4<='0';--- vermelho
				p5g<='0'; p5r<='1'; ps5<='0';--- vermelho
				nx_state <= eurico_vermelho;
				IF (test='0') THEN
					timer <= time_vermelho_vermelho_amarelo;
				ELSE
					timer <= timeTEST;
				END IF;
			WHEN eurico_vermelho => 
				r0<='1'; y0<='0'; g0<='0'; -- vermelho
				r1<='1'; y1<='0'; g1<='0'; --- vermelho
				r2<='1'; y2<='0'; g2<='0'; --- vermelho
				r3<='1'; y3<='0'; g3<='0'; --- vermelho
				r4<='1'; y4<='0'; g4<='0'; --- vermelho
				p1g<='1'; p1r<='0'; ps1<='0'; --- verde
				p2g<='1'; p2r<='0'; ps2<='0'; --- verde
				p3g<='1'; p3r<='0'; ps3<='0'; --- verde
				p4g<='1'; p4r<='0'; ps4<='0';--- verde
				p5g<='1'; p5r<='0'; ps5<='0';--- verde
				nx_state <= eurico_verde;
				IF (test='0') THEN
					timer <= time_vermelho;
				ELSE
					timer <= timeTEST;
				END IF;
				WHEN eurico_vermelho1 => ---- Possui contradições# 
				r0<='1'; y0<='0'; g0<='0'; --- vermelho
				r1<='1'; y1<='0'; g1<='0'; --- vermelho
				r2<='1'; y2<='0'; g2<='0'; --- vermelho
				r3<='1'; y3<='0'; g3<='0'; --- vermelho
				r4<='1'; y4<='0'; g4<='0'; --- vermelho
				--p1g<='0' ;p1r<='0'; ps1<='1'; --- piscando
				p1g<='0' ; ps1<='1'; --- CONSERTADO
				p2g<='1'; p2r<='0'; ps2<='0'; --- verde
				p3g<='1'; p3r<='0'; ps3<='0';--- verde
				p4g<='1'; p4r<='0'; ps4<='0'; --- verde
				--p5g<='0'; p5r<='0'; ps5<='1'; --- piscando
				p5g<='0'; ps5<='1'; --- piscando
				nx_state <= eurico_verde;
				IF (test='0') THEN
					timer <= time_vermelho1;
				ELSE
					timer <= timeTEST;
				END IF;
				IF (ps1 ='1') THEN
					p1r <= nclk1;
				  p5r <= nclk1;
				 END IF;	
				WHEN eurico_vermelho2 =>
				r0<='1'; y0<='0'; g0<='0'; --- vermelho
				r1<='1'; y1<='0'; g1<='0'; --- vermelho
				r2<='1'; y2<='0'; g2<='0'; --- vermelho
				r3<='1'; y3<='0'; g3<='0'; --- vermelho
				r4<='1'; y4<='0'; g4<='0'; --- vermelho
				p1g<='0'; p1r<='0'; ps1<='1'; --- piscando
				p2g<='0'; p2r<='0'; ps2<='1'; --- piscando
				p3g<='0'; p3r<='0'; ps3<='1'; --- piscando
				p4g<='0'; p4r<='0'; ps4<='1'; --- piscando
				p5g<='0'; p5r<='0'; ps5<='1'; --- piscando
				
				nx_state <= eurico_verde;
				IF (test='0') THEN
					timer <= time_vermelho2;
				ELSE
					timer <= timeTEST;
				END IF;
					IF(ps1 <='1') THEN
						p1r<= nclk1;
					   p2r<= nclk1;
					   p3r<= nclk1;
					   p4r<= nclk1;
					   p5r<= nclk1;
					END IF;	
				WHEN eurico_vermelho3 => 
				r0<='1'; y0<='0'; g0<='0'; --- vermelho
				r1<='1'; y1<='0'; g1<='0'; --- vermelho
				r2<='1'; y2<='0'; g2<='0'; --- vermelho
				r3<='1'; y3<='0'; g3<='0'; --- vermelho
				r4<='1'; y4<='0'; g4<='0'; --- vermelho
				p1g<='0'; p1r<='1'; ps1<='0'; --- vermelho
				p2g<='0'; p2r<='1'; ps2<='0'; --- vermelho
				p3g<='0'; p3r<='0'; ps3<='1'; --- piscando
				p4g<='0'; p4r<='0'; ps4<='1';--- piscando
				p5g<='0'; p5r<='1'; ps5<='0';--- vermelho
				nx_state <= eurico_verde;
				IF (test='0') THEN
					timer <= time_vermelho3;
				ELSE
					timer <= timeTEST;
				END IF;
					IF(ps3 <= '1') THEN
						p3r <= nclk1;
					   p4r <= nclk1;
					END IF;	
			WHEN eurico_verde => 
				r0<='1'; y0<='0'; g0<='0'; --- vermelho
				r1<='1'; y1<='0'; g1<='0'; --- vermelho
				r2<='0'; y2<='0'; g2<='1'; --- verde
				r3<='0'; y3<='0'; g3<='1'; --- verde
				r4<='0'; y4<='0'; g4<='1'; --- verde
				p1g<='0'; p1r<='1'; ps1<='0'; --- vermelho
				p2g<='0'; p2r<='1'; ps2<='0'; --- vermelho
				p3g<='0'; p3r<='1'; ps3<='0';--- vermelho
				p4g<='0'; p4r<='1'; ps4<='0'; --- vermelho
				p5g<='0'; p5r<='1'; ps5<='0'; --- vermelho
				nx_state <= eurico_amarelo_verde_verde;
				IF (test='0') THEN
					timer <= time_verde;
				ELSE
					timer <= timeTEST;
				END IF;
			WHEN eurico_amarelo_verde_verde =>
				r0<='1'; y0<='0'; g0<='0'; --- vermelho
				r1<='1'; y1<='0'; g1<='0'; --- vermelho
				r2<='0'; y2<='1'; g2<='0'; --- amarelo
				r3<='0'; y3<='0'; g3<='1'; --- verde 
				r4<='0'; y4<='0'; g4<='1'; --- verde
				p1g<='0'; p1r<='1'; ps1<='0'; --- vermelho
				p2g<='0'; p2r<='1'; ps1<='0';--- vermelho
				p3g<='0'; p3r<='1'; ps1<='0';--- vermelho
				p4g<='0'; p4r<='1'; ps1<='0';--- vermelho
				p5g<='0'; p5r<='1'; ps1<='0';--- vermelho
				timer <= timeTEST;
				nx_state <= eurico_vermelho_amarelo_verde;	
				IF (test='0') THEN
					timer <= time_amarelo_verde_verde;
				ELSE
					timer <= timeTEST;		
				END IF;	
			WHEN eurico_vermelho_amarelo_verde =>  
				r0<='0'; y0<='0'; g0<='1'; --- verde
				r1<='1'; y1<='0'; g1<='0'; --- vermelho
				r2<='1'; y2<='0'; g2<='0'; --- vermelho
				r3<='0'; y3<='1'; g3<='0'; --- amarelo
				r4<='0'; y4<='0'; g4<='1'; --- verde
				p1g<='1'; p1r<='0'; ps1<='0'; --- verde
				p2g<='0'; p2r<='1'; ps2<='0'; --- vermelho
				p3g<='0'; p3r<='1'; ps3<='0'; --- vermelho
				p4g<='0'; p4r<='1'; ps4<='0'; --- vermelho
				p5g<='0'; p5r<='1'; ps5<='0';--- vermelho
				nx_state <= eurico_vermelho_vermelho_verde;
				IF (test='0') THEN
					timer <= time_vermelho_amarelo_verde;
				ELSE
					timer <= timeTEST;
				END IF;
			WHEN eurico_amarelo =>  
				r1 <='0'; y1 <='1'; g1<='0'; --- amarelo
				r2 <='0'; y2 <='1'; g2<='0'; --- amarelo
				r3 <='0'; y3 <='1'; g3<='0'; --- amarelo
				r4 <='0'; y4 <='1'; g4<='0'; --- amarelo
				timer <= timeTEST;
				nx_state <= eurico_vermelho_vermelho_verde;
			
			END CASE;
		END PROCESS;
	END fsm;
	
		