----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:34:40 11/05/2024 
-- Design Name: 
-- Module Name:    VGAdisplay - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGAdisplay is
   Port ( 
        clk       : in  STD_LOGIC;
        DAC_CLK   : out std_logic;    
        H         : out std_logic;    -- h sync  
        V         : out std_logic;    -- v sync
        Rout      : out std_logic_vector(7 downto 0);  
        Gout      : out std_logic_vector(7 downto 0);  
        Bout      : out std_logic_vector(7 downto 0);
        SW0       : in  std_logic;    -- On-board switch 0
        SW1       : in  std_logic;    -- On-board switch 1
        SW2       : in  std_logic;    -- On-board switch 2
        SW3       : in  std_logic     -- On-board switch 3
    );
end VGAdisplay;

architecture Behavioral of VGAdisplay is
    -- VGA timing constants for 640x480 resolution
    constant H_SYNC_PULSE      : integer := 96;
    constant H_BACK_PORCH      : integer := 48;
    constant H_DISPLAY_AREA    : integer := 640;
    constant H_FRONT_PORCH     : integer := 16;
    constant H_TOTAL_CYCLES    : integer := 800;

    constant V_SYNC_PULSE      : integer := 2;
    constant V_BACK_PORCH      : integer := 33;
    constant V_DISPLAY_AREA    : integer := 480;
    constant V_FRONT_PORCH     : integer := 10;
    constant V_TOTAL_LINES     : integer := 525;
	 
	 --constant ball_start_H 		:	integer	:= 474;
	 --constant ball_start_V 		:	integer	:= 260;
	 constant ball_len			:	integer	:= 20;
	 constant player_speed		:	integer	:= 2;
	 

    -- Signals for horizontal and vertical counters
	 signal HPos : integer range 0 to 640;
    signal VPos : integer range 0 to 480;
	 signal ball_h : integer := 312;
    signal ball_v : integer := 232;
	 signal bDH : Integer := 1;
	 signal bDV : integer := 1;

		
	-- paddles
	signal paddlewidth : Integer := 12;
	signal paddleheight : Integer := 90;
	signal leftPaddlePosY : Integer := 37;
	signal rightPaddlePosY : Integer := 37;

	signal leftPaddlePosX : Integer := 40;
	signal rightPaddlePosX : Integer := 600;


    -- Signals for pixel clock divider
    signal pixel_clk : std_logic := '0';
    signal clk_div   : integer := 0;

    -- Video active area indicators
    signal h_active, v_active : std_logic;
	 signal hsync, vsync, delay : Integer := 0;


begin
    -- Clock divider process to generate 25 MHz pixel clock from 50 MHz input
    process(clk)
    begin
        if rising_edge(clk) then
            pixel_clk <= not pixel_clk;
				DAC_CLK <= pixel_clk;				    
        end if;
		
    end process;

    -- Connect the divided clock to DAC_CLK

--    -- Horizontal and Vertical Counters using pixel clock
--    process(pixel_clk)
--    begin
--        if rising_edge(pixel_clk) then
--            if HPos < H_TOTAL_CYCLES - 1 then
--                HPos <= HPos + 1;
--            else
--                HPos <= 0;
--                if VPos < V_TOTAL_LINES - 1 then
--                    VPos <= VPos + 1;
--                else
--                    VPos <= 0;
--                end if;
--            end if;
--        end if;
--    end process;

    -- Generate HSYNC and VSYNC signals based on counters
	 PROCESS (pixel_clk)
    BEGIN
        -- Syncing
        IF rising_edge(pixel_clk) THEN
            IF (hsync = 800) THEN
                vsync <= vsync + 1;
                hsync <= 0;
            ELSE
                hsync <= hsync + 1;
            END IF;
            IF (vsync = 524) THEN
                vsync <= 0;
            END IF;
            -- Sync Pulse 64
            IF (hsync >= 656 AND hsync <= 751) THEN
                H <= '0';
            ELSE
                H <= '1';
            END IF;
            -- Sync Pulse
            IF (vsync >= 490 AND vsync <= 491) THEN
                V <= '0';
            ELSE
                V <= '1';
            END IF;
        END IF;
    END PROCESS;

--    H <= '0' when (HPos < H_SYNC_PULSE) else '1';
--    V <= '0' when (VPos < V_SYNC_PULSE) else '1';
--
--    -- Active display area indicators
--    h_active <= '1' when (HPos >= (H_SYNC_PULSE + H_BACK_PORCH) and HPos < (H_SYNC_PULSE + H_BACK_PORCH + H_DISPLAY_AREA)) else '0';
--    v_active <= '1' when (VPos >= (V_SYNC_PULSE + V_BACK_PORCH) and VPos < (V_SYNC_PULSE + V_BACK_PORCH + V_DISPLAY_AREA)) else '0';

    -- RGB Color Signals for Static Background and Borders
    process(pixel_clk, HPos, VPos)
	begin
		 -- Check if within display area
		 if rising_edge(pixel_clk) then
				HPos <= hsync;
				VPos <= vsync;
				--white top and bottom bar
				IF (HPos >= 25 AND HPos <= 615 AND ((VPos >= 25 AND VPos <= 36) OR (VPos >= 448 AND VPos <= 459))) THEN
                ROUT <= "11111111";
                GOUT <= "11111111";
                BOUT <= "11111111";
            -- white sidebars
            ELSIF (((HPos >= 25 AND HPos <= 36) OR (HPos >= 604 AND HPos <= 615)) AND ((VPos >= 36 AND VPos <= 126) OR (VPos >= 358 AND VPos <= 448))) THEN
                ROUT <= "11111111";
                GOUT <= "11111111";
                BOUT <= "11111111";
            --dotted middle line
            ELSIF ((HPos > 316 AND HPos < 320) AND VPos >= 37 AND VPos < 448) AND (((VPos - 35) mod 64) > 32) THEN
                ROUT <= "00000000";
                GOUT <= "00000000";
                BOUT <= "00000000";
            -- else green
            ELSIF (HPos > 0 AND HPos < 640 AND VPos > 0 AND VPos < 480) THEN
                ROUT <= "00000000";
                GOUT <= "11111111";
                BOUT <= "00000000";
            ELSE --outside game area black
                ROUT <= (OTHERS => '0');
                GOUT <= (OTHERS => '0');
                BOUT <= (OTHERS => '0');
            END IF;
				
				--paddle section
				--left paddle (blue team)
				IF ((HPos > leftPaddlePosX AND HPos < leftPaddlePosX + paddlewidth) AND (VPos > leftPaddlePosY AND VPos < leftPaddlePosY + paddleheight) ) THEN
					ROUT <= "00000000";
					GOUT <= "00000000";
					BOUT <= "11111111";
				END IF;
				--right paddle (red team)
				IF ((HPos < rightPaddlePosX AND HPos > rightPaddlePosX - paddlewidth) AND (VPos > rightPaddlePosY AND VPos < rightPaddlePosY + paddleheight) ) THEN
					ROUT <= "11111111";
					GOUT <= "00000000";
					BOUT <= "00000000";
				--rightPaddlePosY <= rightPaddlePosY - 1;
				end if;
		--paddle movement
				--right down
				IF (SW2 = '1' and HPos >= 10 and HPos <= 10 and VPos >= 10 and VPos <= 11 and rightPaddlePosY < 446 - paddleheight and SW3 = '1') THEN
					rightPaddlePosY <= rightPaddlePosY + 1;
				END IF;
				--right up
				IF (SW2 = '0' and HPos >= 10 and HPos <= 10 and VPos >= 10 and VPos <= 11 and rightPaddlePosY > 37 and SW3 = '1') THEN
					rightPaddlePosY <= rightPaddlePosY - 1;
				END IF;
				
				--left down
				IF (SW0 = '1' and HPos >= 10 and HPos <= 10 and VPos >= 10 and VPos <= 11 and leftPaddlePosY < 446 - paddleheight and SW1 = '1') THEN
					leftPaddlePosY <= leftPaddlePosY + 1;
				END IF;
				--left up
				IF (SW0 = '0' and HPos >= 10 and HPos <= 10 and VPos >= 10 and VPos <= 11 and leftPaddlePosY > 37 and SW1 = '1') THEN
					leftPaddlePosY <= leftPaddlePosY - 1;
				END IF;
 
--BALL LOGIC SECTION
				IF (HPos > ball_h and HPos< ball_h + ball_len and VPos > ball_v and VPos < ball_v + ball_len) THEN
				--check if goal
					IF ((ball_h < 26 + ball_len - 6) OR (ball_h > 604 - ball_len + 6)) THEN
						ROUT <= "11111111";
						GOUT <= "00000000";
						BOUT <= "00000000";
							IF ((ball_h > 610) OR (ball_h < 14)) THEN
								ball_h <= 312;
								ball_v <= 232;
							END IF;
					ELSE
						ROUT <= "11111111";
						GOUT <= "00000000";
						BOUT <= "11111111";
					END IF;
				END IF;

				IF (HPos >= 10 and HPos <= 10 and VPos >= 10 and VPos <= 10) THEN
				--which X way
					IF bDH > 0 THEN
						ball_h <= ball_h + 1;
					ELSE
						ball_h <= ball_h - 1;
					END IF;

				--which y way
					IF bDV > 0 THEN
						ball_v <= ball_v + 1;
					ELSE
						ball_v <= ball_v - 1;
					END IF;
				----------------------------
				--Switch vars, Y
				IF (ball_v < 37) THEN
				bDV <= 1;
				END IF;
				IF (ball_v > 446 - ball_len) THEN

				bDV <= 0;

				END IF;
				-------------------------------
				-- for X--walls

				-- AND ((ball_v < nettop) AND (ball_v > netbottom))
				IF (ball_H > 604 - ball_len AND (((ball_v < 126) OR (ball_v > 348)))) THEN

				bDH <= 0;

				END IF;

				IF (ball_H < 26 + ball_len AND (((ball_v < 126) OR (ball_v > 358)))) THEN

				bDH <= 1;

				END IF;

				--left paddle hit
				IF(ball_H < leftPaddlePosX + paddlewidth AND (ball_v > leftPaddlePosY AND ball_v < leftPaddlePosY + paddleheight)) THEN

				bDH <= 1;

				END IF;

				--right paddle hit
				IF(ball_H > rightPaddlePosX - 2*paddlewidth  AND (ball_v > rightPaddlePosY AND ball_v < rightPaddlePosY + paddleheight )) THEN

				bDH <= 0;

				END IF;

				END IF;




		 end if;
		 
	end process;

end Behavioral;