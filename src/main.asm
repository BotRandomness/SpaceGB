INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]

    jp EntryPoint

    ds $150 - @, 0 ; Make room for the header

EntryPoint:
    ; Do not turn the LCD off outside of VBlank
WaitVBlank:
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank

	; Turn the LCD off (no damage)
	ld a, 0
	ld [rLCDC], a

	; Copy the SpaceShip tile
    ld de, SpaceShip
    ld hl, $8000
    ld bc, SpaceShipEnd - SpaceShip
    call Memcopy

    ; Copy the Asteroid tile
    ld de, Asteroid
    ld hl, $8010
    ld bc, AsteroidEnd - Asteroid
    call Memcopy

    ; Copy the tile data
    ld de, Tiles
    ld hl, $9000
    ld bc, TilesEnd - Tiles
    call Memcopy

    ; Copy the tilemap
    ld de, Tilemap
    ld hl, $9800
    ld bc, TilemapEnd - Tilemap
    call Memcopy

    ;OAMRAM + X: 0-3 SpaceShip, 4-7 Asteroid1, 8-11 Asteroid2, 12-15 Astroid3, 16-19 Astroid4, 20-23 Astroid5 

    ; Clear OAM (160 bytes for 40 sprites taking 4 bytes)
	ld a, 0
    ld b, 160
    ld hl, _OAMRAM
ClearOam:
    ld [hli], a
    dec b
    jp nz, ClearOam

    ; Initialize the SpaceShip sprite in OAM
    ld hl, _OAMRAM ; Loads address of OAM RAM into HL (pointer to the start of OAM where the sprite attributes)
    ld a, 69 + 16 ; Load Y pos
    ld [hli], a ; Store Y pos in OAM
    ld a, 52 + 8 ; Load X pos
    ld [hli], a ; Store X pos in OAM
    ld a, 0 ; Load TileID: 0 (this uses the first tile)
    ld [hli], a ; Store Tile ID in OAM
    ;ld a, %01000000
    ld [hli], a ;Store attributes in OAM (set to 0)

    ; Initialize the Asteroids sprite in OAM
    ld a, 0 + 16 ; Load Y pos
    ld [hli], a ; Store Y pos in OAM
    ld a, 52 + 8 ; Load X pos
    ld [hli], a ; Store X pos in OAM
    ld a, 1 ; Load TileID: 1
    ld [hli], a ; Store Tile ID in OAM
    ld a, %10000000
    ld [hli], a ;Store attributes in OAM (set to 0)

    ld a, 0 + 16 ; Load Y pos
    ld [hli], a ; Store Y pos in OAM
    ld a, 8 + 8 ; Load X pos
    ld [hli], a ; Store X pos in OAM
    ld a, 1 ; Load TileID: 1
    ld [hli], a ; Store Tile ID in OAM
    ld a, %10000000
    ld [hli], a ;Store attributes in OAM (set to 0)

    ld a, 100 + 16 ; Load Y pos
    ld [hli], a ; Store Y pos in OAM
    ld a, 80 + 8 ; Load X pos
    ld [hli], a ; Store X pos in OAM
    ld a, 1 ; Load TileID: 1
    ld [hli], a ; Store Tile ID in OAM
    ld a, %10000000
    ld [hli], a ;Store attributes in OAM (set to 0)

    ld a, 75 + 16 ; Load Y pos
    ld [hli], a ; Store Y pos in OAM
    ld a, 70 + 8 ; Load X pos
    ld [hli], a ; Store X pos in OAM
    ld a, 1 ; Load TileID: 1
    ld [hli], a ; Store Tile ID in OAM
    ld a, %10000000
    ld [hli], a ;Store attributes in OAM (set to 0)

    ld a, 95 + 16 ; Load Y pos
    ld [hli], a ; Store Y pos in OAM
    ld a, 30 + 8 ; Load X pos
    ld [hli], a ; Store X pos in OAM
    ld a, 1 ; Load TileID: 1
    ld [hli], a ; Store Tile ID in OAM
    ld a, %10000000
    ld [hli], a ;Store attributes in OAM (set to 0)


    ; Turn the LCD on
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a

    ; During the first (blank) frame, initialize display registers
    ld a, %11100100
    ld [rBGP], a
    ld a, %11100100
    ld [rOBP0], a

    ; Initialize global variables
    ld a, 0
    ld [wCurKeys], a
    ld [wNewKeys], a

Main:
	; Wait until it is not in VBlank
	ld a, [rLY]
	cp 144
	jp nc, Main
WaitVBlank2:
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank2

    ; Update to scroll background up
    ld a, [rSCY]
    dec a 
    ld [rSCY], a

    ; Update asteroid positions
    ld a, [_OAMRAM + 4]
    cp a, 150
    jp z, ResetAsteroid ; Reset asteroid if past on Y, with random X value
    add 2
    ld [_OAMRAM + 4], a
    jp Asteroid1Done
ResetAsteroid:
    ld a, 0
    ld [_OAMRAM + 4], a
    call Random2
    ld [_OAMRAM + 5], a
Asteroid1Done:
    ld a, [_OAMRAM + 8]
    cp a, 150
    jp z, ResetAsteroid2
    add 3
    ld [_OAMRAM + 8], a
    jp Asteroid2Done
ResetAsteroid2:
    ld a, 0
    ld [_OAMRAM + 8], a
    call Random
    ld [_OAMRAM + 9], a
Asteroid2Done:
    ld a, [_OAMRAM + 12]
    cp a, 150
    jp z, ResetAsteroid3
    add 2
    ld [_OAMRAM + 12], a
    jp Asteroid3Done
ResetAsteroid3:
    ld a, 0
    ld [_OAMRAM + 12], a
    call Random2
    ld [_OAMRAM + 13], a
Asteroid3Done:
    ld a, [_OAMRAM + 16]
    cp a, 150
    jp z, ResetAsteroid4
    add 2
    ld [_OAMRAM + 16], a
    jp Asteroid4Done
ResetAsteroid4:
    ld a, 0
    ld [_OAMRAM + 16], a
    call Random
    ld [_OAMRAM + 17], a
Asteroid4Done:
    ld a, [_OAMRAM + 20]
    cp a, 150
    jp z, ResetAsteroid5
    add 2
    ld [_OAMRAM + 20], a
    jp Asteroid5Done
ResetAsteroid5:
    ld a, 0
    ld [_OAMRAM + 20], a
    call Random
    ld [_OAMRAM + 21], a
Asteroid5Done:

    ; Get spaceship's Y and X
    ld a, [_OAMRAM + 0] ; Get spaceship Y
    ld b, a             ; Spaceship Y -> b
    ld a, [_OAMRAM + 1] ; Get spaceship X
    ld c, a             ; Spaceship X -> c

    ; Get for Asteroid Y and X, check collision
    ld a, [_OAMRAM + 4] ; Get asteroid Y
    ld d, a             ; Asteroid Y -> d
    ld a, [_OAMRAM + 5] ; Get asteroid X
    ld e, a             ; Asteroid X -> e
    call CheckCollision

    ld a, [_OAMRAM + 8]
    ld d, a
    ld a, [_OAMRAM + 9]
    ld e, a
    call CheckCollision

    ld a, [_OAMRAM + 12]
    ld d, a
    ld a, [_OAMRAM + 13]
    ld e, a
    call CheckCollision

    ld a, [_OAMRAM + 16]
    ld d, a
    ld a, [_OAMRAM + 17]
    ld e, a
    call CheckCollision

    ld a, [_OAMRAM + 20]
    ld d, a
    ld a, [_OAMRAM + 21]
    ld e, a
    call CheckCollision

	call UpdateKeys

CheckLeft:
    ld a, [wCurKeys]
    and a, PADF_LEFT
    jp z, CheckRight
LeftMove:
	ld a, [_OAMRAM + 1]
	dec a
    ;sub 2
    cp a, 16 - 1 ; If left side of screen, don't go further (tile 8x8, due to off by 8, 8+8)
    jp z, Main
	ld [_OAMRAM + 1], a
	jp Main
CheckRight:
    ld a, [wCurKeys]
    and a, PADF_RIGHT
    jp z, CheckUp
RightMove:
	ld a, [_OAMRAM + 1]
	inc a
    cp a, 160 - 56 + 1 ; If right side of screen, don't go further (160 screen width, 7 8x8 tiles to edge) 
    jp z, Main 
	ld [_OAMRAM + 1], a
    ; Test code below
	;ld a, [_OAMRAM + 0]
	;inc a
	;ld [_OAMRAM + 0], a
	;ld [_OAMRAM + 2], a ; Broken goes to next sprite ID, glitches out due to invaild sprite id being loaded beyond what's loaded?
	;ld [_OAMRAM + 3], a ; Flips and change pallets
	jp Main
CheckUp:
    ld a, [wCurKeys]
    and a, PADF_UP
    jp z, CheckDown
UpMove:
	ld a, [_OAMRAM + 0]
	dec a
    cp a, 16 - 1 ; If Up side of screen, don't go further (16 offset to screen)
    jp z, Main
	ld [_OAMRAM + 0], a
	jp Main
CheckDown:
    ld a, [wCurKeys]
    and a, PADF_DOWN
    jp z, ACheck
DownMove:
	ld a, [_OAMRAM + 0]
	inc a
    cp a, 154 ; If Down side of screen, don't go further
    jp z, Main 
	ld [_OAMRAM + 0], a
	jp Main
ACheck:
    ld a, [wCurKeys]
    and a, PADF_A
    jp z, BCheck
AFunction:
    ld a, [_OAMRAM + 0]
    sub 2 ; Boost power
    cp a, 16
    jp c, Main
    ld [_OAMRAM + 0], a
    jp Main
BCheck:
    ld a, [wCurKeys]
    and a, PADF_B
    jp z, Main
BFunction:
    ld a, [_OAMRAM + 0]
    add 2 ; Boost power
    cp a, 154
    jp nc, Main
    ld [_OAMRAM + 0], a
    jp Main 

; Checks overlap collision between 2 8x8 sprite tiles
; Param: reg b,c -> Y1, X1 (SpaceShip)
; Param: reg d,e -> Y2, X2 (Asteroid)
; Returns back if no collision, else resets game
CheckCollision:
    ; Asteroid right side >= Spaceship left side
    ld a, e          
    add 8 ; Asteroid's right side, X2 + 8
    cp c             
    jp c, NoCollision

    ; Spaceship right side >= Asteroid left side
    ld a, c
    add 8 ; Spaceship's right side, X1 + 8
    cp e
    jp c, NoCollision

    ; Asteroid bottom side >= Spaceship top side
    ld a, d
    add 8 ; Asteroid's bottom side, Y2 + 8
    cp b
    jp c, NoCollision

    ; Spaceship bottom side >= Asteroid top side
    ld a, b
    add 8 ; Spaceship's bottom side, Y1 + 8
    cp d
    jp c, NoCollision
CollisionDetected:
    ; Reset Y Scroll
    ld a, 0
    ld [rSCY], a

    ; Reset SpaceShip
    ld hl, _OAMRAM
    ld a, 69 + 16
    ld [hli], a
    ld a, 52 + 8
    ld [hli], a
    ld a, 0
    ld [hli], a
    ld [hli], a

    ; Reset Asteroids
    ld a, 0 + 16
    ld [hli], a
    ld a, 52 + 8
    ld [hli], a
    ld a, 1
    ld [hli], a
    ld a, %10000000
    ld [hli], a

    ld a, 0 + 16
    ld [hli], a
    ld a, 8 + 8
    ld [hli], a
    ld a, 1
    ld [hli], a
    ld a, %10000000
    ld [hli], a

    ld a, 100 + 16
    ld [hli], a
    ld a, 80 + 8
    ld [hli], a
    ld a, 1
    ld [hli], a
    ld a, %10000000
    ld [hli], a

    ld a, 75 + 16
    ld [hli], a
    ld a, 70 + 8
    ld [hli], a
    ld a, 1
    ld [hli], a
    ld a, %10000000
    ld [hli], a

    ld a, 95 + 16
    ld [hli], a
    ld a, 30 + 8
    ld [hli], a
    ld a, 1
    ld [hli], a
    ld a, %10000000
    ld [hli], a

    ;jp $100 ; Reset game (It does not work right, after reseting a few times it will get to blank screen, only happens when collision code is a "function", not when reused 4 times for each asteroid)
NoCollision:
    ret

; Generates random value between MIN and MAX (Now in 2 flavours!)
; Returns value in reg a
Random:
    ;Seed from rDiv
    ldh a, [rDIV]
    rlc a
    sra a

    and 52 - 15 ; MAX VALUE - MIN VALUE, Mask bits
    add 15 ; MIN VALUE, Shift range
    ret
Random2:
    ;Seed from rDiv
    ldh a, [rDIV]
    rrc a 
    srl a

    and 100 - 52 ; MAX VALUE - MIN VALUE, Mask bits
    add 52 ; MIN VALUE, Shift range
    ret

UpdateKeys:
  ; Poll half the controller
  ld a, P1F_GET_BTN
  call .onenibble
  ld b, a ; B7-4 = 1; B3-0 = unpressed buttons

  ; Poll the other half
  ld a, P1F_GET_DPAD
  call .onenibble
  swap a ; A3-0 = unpressed directions; A7-4 = 1
  xor a, b ; A = pressed buttons + directions
  ld b, a ; B = pressed buttons + directions

  ; And release the controller
  ld a, P1F_GET_NONE
  ldh [rP1], a

  ; Combine with previous wCurKeys to make wNewKeys
  ld a, [wCurKeys]
  xor a, b ; A = keys that changed state
  and a, b ; A = keys that changed to pressed
  ld [wNewKeys], a
  ld a, b
  ld [wCurKeys], a
  ret

.onenibble
  ldh [rP1], a ; switch the key matrix
  call .knownret ; burn 10 cycles calling a known ret
  ldh a, [rP1] ; ignore value while waiting for the key matrix to settle
  ldh a, [rP1]
  ldh a, [rP1] ; this read counts
  or a, $F0 ; A7-4 = 1; A3-0 = unpressed keys
.knownret
  ret

; Copy bytes from one area to another.
; Param de <- Source
; Param hl <- Destination
; Param bc <- Length
Memcopy:
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, Memcopy
    ret

SpaceShip:
	DB $00,$18,$18,$3C,$18,$A5,$18,$A5
	DB $18,$E7,$00,$FF,$00,$99,$00,$81
SpaceShipEnd:

Asteroid:
    DB $7E,$7E,$F7,$89,$CF,$B1,$DD,$A3
    DB $B9,$C7,$F7,$89,$E7,$99,$7E,$7E
AsteroidEnd:

Tiles:
    DB $00,$18,$18,$3C,$18,$A5,$18,$A5
    DB $18,$E7,$00,$FF,$00,$99,$00,$81
    DB $00,$FF,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$80,$00,$80,$00,$80,$00,$80
    DB $00,$80,$00,$80,$00,$80,$00,$80
    DB $00,$01,$00,$01,$00,$01,$00,$01
    DB $00,$01,$00,$01,$00,$01,$00,$01
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$FF
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    DB $CF,$3F,$CF,$3F,$CF,$3F,$CF,$3F
    DB $CF,$3F,$CF,$3F,$CF,$3F,$CF,$3F
    DB $F3,$FC,$F3,$FC,$F3,$FC,$F3,$FC
    DB $F3,$FC,$F3,$FC,$F3,$FC,$F3,$FC
    DB $00,$00,$00,$00,$04,$00,$0E,$00
    DB $04,$00,$40,$00,$E0,$00,$40,$00
    DB $00,$00,$40,$00,$E0,$00,$40,$00
    DB $02,$00,$07,$00,$02,$00,$00,$00
    DB $FF,$FF,$FF,$FF,$FF,$FF,$F8,$FF
    DB $F0,$FF,$F1,$FE,$F3,$FC,$F3,$FC
    DB $FF,$FF,$FF,$FF,$FF,$FF,$1F,$FF
    DB $0F,$FF,$8F,$7F,$CF,$3F,$CF,$3F
    DB $FF,$FF,$FF,$FF,$FF,$FF,$00,$FF
    DB $00,$FF,$FF,$00,$FF,$00,$FF,$00
    DB $F3,$FC,$F3,$FC,$F1,$FE,$F0,$FF
    DB $F8,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    DB $CF,$3F,$CF,$3F,$8F,$7F,$0F,$FF
    DB $1F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    DB $FF,$00,$FF,$00,$FF,$00,$00,$FF
    DB $00,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$01,$01,$01,$01,$01,$01
    DB $01,$01,$0F,$0F,$0F,$0F,$0F,$0F
    DB $00,$00,$FF,$FF,$FF,$FF,$FF,$FF
    DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    DB $00,$00,$FC,$FC,$FC,$FC,$FC,$FC
    DB $80,$80,$80,$80,$80,$80,$80,$80
    DB $FE,$FF,$FE,$FF,$FE,$FF,$E0,$FF
    DB $FF,$FF,$FF,$F0,$F0,$F0,$FF,$F0
    DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
    DB $FF,$FF,$FF,$00,$00,$00,$FF,$00
    DB $78,$F8,$78,$F8,$78,$F8,$07,$FF
    DB $FF,$FF,$FF,$0F,$0F,$0F,$FF,$0F
    DB $FF,$FF,$E0,$FF,$E0,$FF,$E0,$FF
    DB $E0,$FF,$E0,$FF,$E0,$FF,$E0,$FF
    DB $FF,$FF,$00,$FF,$00,$FF,$00,$FF
    DB $00,$FF,$00,$FF,$00,$80,$00,$80
    DB $FF,$FF,$00,$FF,$00,$FF,$00,$FF
    DB $00,$F3,$00,$F3,$00,$03,$00,$03
    DB $FF,$FF,$07,$FF,$07,$FF,$07,$FF
    DB $07,$FF,$07,$FF,$07,$FF,$07,$FF
    DB $1C,$1F,$1C,$1F,$1C,$1F,$03,$03
    DB $01,$01,$01,$01,$00,$00,$00,$00
    DB $00,$80,$00,$FF,$00,$FF,$00,$FF
    DB $FF,$FF,$FF,$FF,$00,$00,$00,$00
    DB $00,$03,$00,$FF,$00,$FF,$00,$FF
    DB $FF,$FF,$FF,$FF,$00,$00,$00,$00
    DB $38,$F8,$38,$F8,$38,$F8,$C0,$C0
    DB $80,$80,$80,$80,$00,$00,$00,$00
TilesEnd:
Tilemap:
    DB $07,$10,$10,$08,$10,$10,$08,$10,$08,$10
    DB $10,$08,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$08,$10,$10,$10,$10,$09,$10,$10,$10
    DB $10,$10,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$10,$10,$10,$10,$10,$10,$09,$10
    DB $10,$08,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$10,$09,$10,$10,$10,$10,$10,$10
    DB $10,$10,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$10,$10,$10,$10,$08,$10,$10,$10
    DB $10,$10,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$10,$10,$10,$10,$10,$10,$10,$09
    DB $10,$10,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$10,$08,$10,$10,$09,$10,$10,$10
    DB $10,$10,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$10,$10,$10,$10,$10,$10,$10,$10
    DB $10,$09,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$08,$10,$10,$10,$10,$10,$08,$10
    DB $10,$10,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$10,$10,$10,$08,$10,$10,$10,$10
    DB $10,$10,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$08,$10,$10,$10,$10,$10,$10,$09
    DB $10,$10,$10,$06,$0A,$0C,$0C,$0C,$0C,$0B
    DS 12
    DB $07,$10,$10,$10,$10,$10,$10,$10,$10,$10
    DB $10,$10,$10,$06,$07,$11,$12,$12,$13,$06
    DS 12
    DB $07,$10,$10,$10,$10,$09,$10,$10,$08,$10
    DB $10,$10,$10,$06,$07,$14,$15,$15,$16,$06
    DS 12
    DB $07,$10,$10,$10,$10,$10,$10,$10,$10,$10
    DB $10,$10,$10,$06,$07,$17,$18,$19,$1A,$06
    DS 12
    DB $07,$10,$10,$09,$10,$10,$10,$10,$10,$10
    DB $09,$10,$10,$06,$07,$1B,$1C,$1D,$1E,$06
    DS 12
    DB $07,$10,$10,$10,$10,$10,$10,$08,$10,$10
    DB $10,$10,$10,$06,$0D,$0F,$0F,$0F,$0F,$0E
    DS 12
    DB $07,$10,$10,$10,$10,$08,$10,$10,$10,$10
    DB $10,$10,$08,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$09,$10,$10,$10,$10,$09,$10,$10
    DB $08,$10,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$10,$10,$10,$10,$10,$10,$10,$10
    DB $10,$10,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$08,$10,$10,$09,$10,$09,$10,$10,$10
    DB $10,$10,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$10,$10,$10,$10,$10,$10,$09,$10
    DB $10,$08,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$10,$09,$10,$10,$10,$10,$10,$10
    DB $10,$10,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$10,$10,$10,$10,$08,$10,$10,$10
    DB $10,$10,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$10,$10,$10,$10,$10,$10,$10,$09
    DB $10,$10,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$10,$08,$10,$10,$09,$10,$10,$10
    DB $10,$10,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$10,$10,$10,$10,$10,$10,$10,$10
    DB $10,$09,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$08,$10,$10,$10,$10,$10,$08,$10
    DB $10,$10,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$10,$10,$10,$08,$10,$10,$10,$10
    DB $10,$10,$09,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$08,$10,$10,$10,$10,$10,$10,$09
    DB $10,$10,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$10,$08,$10,$10,$10,$10,$10,$10
    DB $10,$10,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$10,$10,$10,$09,$10,$10,$08,$10
    DB $10,$09,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
    DB $07,$10,$09,$10,$10,$10,$10,$10,$10,$10
    DB $09,$10,$10,$06,$05,$05,$05,$05,$05,$05
    DS 12
TilemapEnd:

SECTION "Input Variables", WRAM0
wCurKeys: db
wNewKeys: db