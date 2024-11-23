.global main
#####
#    140 bpm -> 140/60 =  2.333 beats per second
#    1/2.333 = 0.429 second per beat = 429 ms
#    429/ 16 = 26.8 so , a beat last roughly 27 frames
#
#
####
THEME_SONG:
.space 184 

load_theme:  # load all the notes of the theme in order, (might have to store duration too but we'll see)
la $s7, THEME_SONG
addi $t1, $zero, 43  # G
sw $t1, 0($s7)
addi $t1, $zero, 43  # G
sw $t1, 4($s7)
addi $t1, $zero, 46  # Bb
sw $t1, 8($s7)
addi $t1, $zero, 47  # B
sw $t1, 12($s7)
addi $t1, $zero, 48  # C
sw $t1, 16($s7)
addi $t1, $zero, 47  # B
sw $t1, 20($s7)
addi $t1, $zero, 46  # Bb
sw $t1, 24($s7)
addi $t1, $zero, 45  # A
sw $t1, 28($s7)
addi $t1, $zero, 43 # G
sw $t1, 32($s7)
addi $t1, $zero, 43 # G
sw $t1, 36($s7)
addi $t1, $zero, 46  # Bb
sw $t1, 40($s7)
addi $t1, $zero, 47  # B
sw $t1, 44($s7)
addi $t1, $zero, 48  # C
sw $t1, 48($s7)
addi $t1, $zero, 47  # B
sw $t1, 52($s7)
addi $t1, $zero, 46  # Bb
sw $t1, 56($s7)
addi $t1, $zero, 45  # A
sw $t1, 60($s7)


addi $t1, $zero, 70  # Bb
sw $t1, 64($s7)
addi $t1, $zero, 71 # B
sw $t1, 68($s7)
addi $t1, $zero, 70 # Bb
sw $t1, 72($s7)
addi $t1, $zero, 71 # B
sw $t1, 76($s7)
addi $t1, $zero, 69 # A
sw $t1, 80($s7)
addi $t1, $zero, 67 # G
sw $t1, 84($s7)
addi $t1, $zero, 67 # G
sw $t1, 88($s7)
addi $t1, $zero, 69 # A
sw $t1, 92($s7)
addi $t1, $zero, 70  # Bb
sw $t1, 96($s7)
addi $t1, $zero, 71 # B
sw $t1, 100($s7)
addi $t1, $zero, 70 # Bb
sw $t1, 104($s7)
addi $t1, $zero, 71 # B
sw $t1, 108($s7)
addi $t1, $zero, 69 # A
sw $t1, 112($s7)
addi $t1, $zero, 67 # G
sw $t1, 116($s7)
addi $t1, $zero, 67 # G
sw $t1, 120($s7)
addi $t1, $zero, 69 # A
sw $t1, 124($s7)
addi $t1, $zero, 70  # Bb
sw $t1, 128($s7)
addi $t1, $zero, 71 # B
sw $t1, 132($s7)
addi $t1, $zero, 70 # Bb
sw $t1, 136($s7)
addi $t1, $zero, 71 # B
sw $t1, 140($s7)
addi $t1, $zero, 69 # A
sw $t1, 144($s7)
addi $t1, $zero, 67 # G
sw $t1, 148($s7)
addi $t1, $zero, 67 # G
sw $t1, 152($s7)

addi $t1, $zero, 59 # B
sw $t1, 156($s7)
addi $t1, $zero, 59 # B
sw $t1, 160($s7)
addi $t1, $zero, 60 # C
sw $t1, 164($s7)
addi $t1, $zero, 60 # C
sw $t1, 168($s7)
addi $t1, $zero, 61 # C#
sw $t1, 172($s7)
addi $t1, $zero, 61 # C#
sw $t1, 176($s7)
addi $t1, $zero, 62 # D
sw $t1, 180($s7)
addi $t1, $zero, 62 # D
sw $t1, 184($s7)

# initiate frame counter
addi $t9, $zero, 0
main:
beq $t9, 13, play_music_prep # if 13 frames has passed




# refresh screen 60 times a second, sleep every 16ms
    li $v0, 32
	li $a0, 16
	syscall
    addi $t9, $t9, 1 # increment frame counter
    j main

play_music_prep:
addi $t9, $zero, 0 # reset frame counter to 0
beq $t8, 184, restart_theme


play_music:
 # if note reader reached the end reset s7 back to the address theme_song
# reset to 0 
add $t6, $s7, $t8  # add the beat counter
li $v0 31   # MIDI syscall
lw $a0, 0($t6)  #load note
li $a1, 13 # len in ms
li $a2, 12   # synth instrument
li $a3, 60  # volume
addi $t8, $t8, 4
syscall
j main

restart_theme:
addi, $t8, $zero, 0
j play_music


# li $v0 31   # MIDI syscall
# li $a0, 71  # middle C pitch
# li $a1, 214 # len in ms
# li $a2, 82   # synth instrument
# li $a3, 60  # volume
# syscall