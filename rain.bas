    set romsize 8k
    set kernel_options no_blank_lines readpaddle ; no_blank_lines means we lose missile0
    set optimization speed
    set optimization inlinerand
    set tv ntsc

__Start_Restart
    ; clear playfield
    pfclear

    ; clear audio
    AUDV0 = 0 : AUDV1 = 0

    ;  Clears all normal variables (we don't clear z because it's used for the RNG) and the extra 9.
    a = 0 : b = 0 : c = 0 : d = 0 : e = 0 : f = 0 : g = 0 : h = 0 : i = 0
    j = 0 : k = 0 : l = 0 : m = 0 : n = 0 : o = 0 : p = 0 : q = 0 : r = 0
    s = 0 : t = 0 : u = 0 : v = 0 : w = 0 : x = 0 : y = 0
    var0 = 0 : var1 = 0 : var2 = 0 : var3 = 0 : var4 = 0
    var5 = 0 : var6 = 0 : var7 = 0 : var8 = 0

    ;***************************************************************
    ;  Var for reset switch that allows us to prevent constant
    ;  resets if the switch is held for multiple frames

    dim _Bit0_Reset_Restrainer = r

    ; background color
    COLUBK = $00
    ; two-pixel wide ball and normal, single-color batariBasic playfield
    CTRLPF = $11
    scorecolor = $0E
    ; reset score
    score = 0

    dim rand16 = z
    dim bumpx = g
    dim bumpy = f
    ; fixed offsets from the top left of the screen used for movement/position logic throughout
    bumpx = 64
    bumpy = 39

    dim _ball_vel_x = c
    dim _ball_vel_y = d
    dim _ball_start = e
    dim _ball_repos = h

    ;***************************************************************
    ; variables that count the number of frames since the two
    ; raindrops hit the planet. used for playing short hit sounds
    dim _collision_countdown_0 = t
    dim _collision_countdown_1 = u

    ;***************************************************************
    ; starting positions for ball (meteoroid) and two raindrops
    ; all are off-screen so their movement routines will randomize
    ; their starting locations in the game loop

    ballx = bumpx + 2
    bally = 200 
    ballheight = 2
    _ball_start = rand&3

    player1x = 20
    player1y = 200

    _ball_vel_x = 0
    _ball_vel_y = 0

    missile1x = bumpx + 5
    missile1y = 200
    missile1height = 4

    ; require the paddle button to be pressed to start the game
    dim _game_started = w

 ; Xs are playfield color (green) and dots are background color (black)
 playfield:
................................ 
................................
................................
................................
................................
.............XXXX...............
.............XXXX...............
................................
................................
................................
................................
end

gameloop
    ;***************************************************************
    ; these values are set to 4 when either raindrop collides with
    ; the planet and count down each frame to zero. When they are
    ; non-zero, a hit sound plays. Since the system runs at 60fps,
    ; these sounds are quite short.
    if _collision_countdown_0 > 0 then _collision_countdown_0 = _collision_countdown_0 - 1
    if _collision_countdown_1 > 0 then _collision_countdown_1 = _collision_countdown_1 - 1
    if _collision_countdown_0 > 0 || _collision_countdown_1 > 0 then AUDC0 = 14 : AUDV0 = 8 : AUDF0 = 31 : goto __Skip_Quiet
    AUDV0 = 0
__Skip_Quiet 

    ; little guy
        player0:
    %11111
    %10001
    %10101
    %10001
    %11111
end

    ; raindrop that appears on left or right of planet
     player1:
   %111111
   %111111
end

    ; color of player 0 (player character) and missile 0 (nonexistent)
    COLUP0 = $CA
    ; color of player 1 (raindrop on left/right) and missile 1 (raindrop on top/bottom)
    COLUP1 = $BF
    ; color of playfield and ball (meteoroid)
    COLUPF = $C4
    ; missile 1 is two pixels wide and there is only one of them
    NUSIZ1 = $10
    drawscreen

    ; joy0right acts as the paddle button when using paddles
    if joy0right then _game_started = 1
    if _game_started = 0 then goto gameloop

    ; use the paddle location to move a guy around a square
    if paddle < 19 then player0x = paddle + bumpx : player0y = 0 + bumpy
    if paddle >= 19 && paddle < 36 then player0x = 18 + bumpx : player0y = paddle - 19 + bumpy
    if paddle >= 36 && paddle < 55 then player0x = 18 - (paddle - 36) + bumpx : player0y = 22 + bumpy
    if paddle >=55 && paddle < 76 then player0x = bumpx - 3 : player0y = 22 - (paddle - 55) + bumpy 
    
    ; Raindrop 1 (player1) spawn and movement logic

    if player1y < 200 then goto __Move_Drop_1 ; drop is in play, so skip spawn logic
    a = rand
    ; each frame that drop is not in play, roll to see if we want to spawn the drop
    ; doing this every frame means that even low probabilities will hit relatively quickly
    if a > 13 then goto __End_Drop_1
    player1y = 40 + (rand&15)
    if rand&1 > 0 then player1x = 20 : goto __End_Drop_1
    player1x = 120
    goto __End_Drop_1

__Move_Drop_1
    ; if the raindrop hits the planet, move raindrop offscreen, increment score, and set frame countdown to 4 for hit sound
    if collision(player1, playfield) then player1y = 200 : score = score + 1 : _collision_countdown_1 = 4 : goto __End_Drop_1
    if player1x < 64 then player1x = player1x + 1 : goto __End_Drop_1
    if player1x > 64 then player1x = player1x - 1

__End_Drop_1

    ; Raindrop 2 (missile 1) spawn and movement logic

    if missile1y < 200 then goto __Move_Drop_2 ; drop is in play, so skip spawn logic
    a = rand
    ; each frame that drop is not in play, roll to see if we want to spawn the drop
    ; doing this every frame means that even low probabilities will hit relatively quickly
    if a > 13 then goto __End_Drop_2
    missile1x = bumpx + 5 + (rand&15)
    if rand&1 > 0 then missile1y = 1 : goto __End_Drop_2
    missile1y = 120
    goto __End_Drop_2

__Move_Drop_2
    ; if the raindrop hits the planet, move raindrop offscreen, increment score, and set frame countdown to 4 for hit sound
    if collision(missile1, playfield) then missile1y = 200 : score = score + 1 : _collision_countdown_0 = 4 : goto __End_Drop_2
    ; 50 is just an arbitrary value located inside the "planet." Since it will always collide with the player or planet
    ; before reaching this value it is a safe value to use to determine if the raindrop should be moving up or down
    if missile1y < 50 then missile1y = missile1y + 1 : goto __End_Drop_2
    if missile1y > 50 then missile1y = missile1y - 1
 
__End_Drop_2

    ; Ball (meteoroid) movement logic
    ; Reposition ball if it has gone offscreen
    if ballx >= 1 && ballx <=155 && bally >= 1 && bally <= 100 then goto __Move_Ball
    score = score + 1
    if _ball_start = 0 then ballx = bumpx + 2 : bally = 1 : _ball_vel_x = 0 : _ball_vel_y = 1 : goto __Randomize_Start ; left side of top of screen
    if _ball_start = 1 then ballx = bumpx + 22 : bally = 100 : _ball_vel_x = 0 : _ball_vel_y = -1 : goto __Randomize_Start ; right side of bottom of screen
    if _ball_start = 2 then ballx = 1 : bally = bumpy - 1 : _ball_vel_x = 1 : _ball_vel_y = 0 : goto __Randomize_Start ; top of left side of screen
    if _ball_start = 3 then ballx = 155 : bally = bumpy + 21 : _ball_vel_x = -1 : _ball_vel_y = 0 ; bottom of right side of screen

__Randomize_Start
    _ball_start = rand&3
 
__Move_Ball 
    ballx = ballx + _ball_vel_x
    bally = bally + _ball_vel_y

    ; Game's over if you get hit once!

    if collision(player1, player0) then goto gameover_loop
    if collision(player0, ball) then goto gameover_loop
    if collision(player0, missile1) then goto gameover_loop


    ;***************************************************************
    ;
    ;  Reset switch check and end of main loop.
    ;
    ;  Any Atari 2600 program should restart when the reset  
    ;  switch is pressed. It is part of the usual standards
    ;  and procedures.
    ;
    ;```````````````````````````````````````````````````````````````
    ;  Turns off reset restrainer bit and jumps to beginning of
    ;  main loop if the reset switch is not pressed.
    ;
    if !switchreset then _Bit0_Reset_Restrainer{0} = 0 : goto gameloop

    ;```````````````````````````````````````````````````````````````
    ;  Jumps to beginning of main loop if the reset switch hasn't
    ;  been released after being pressed.
    ;
    if _Bit0_Reset_Restrainer{0} then goto gameloop

    ;```````````````````````````````````````````````````````````````
    ;  Restarts the program.
    ;
    goto __Start_Restart

gameover_loop
    drawscreen
    ; do an annoying buzzing sound forever when you die
    AUDC0 = 2 : AUDV0 = 8 : AUDF0 = 0
    ; joy0right is used as the paddle button when using paddles
    if joy0right || switchreset then goto __Start_Restart
    goto gameover_loop