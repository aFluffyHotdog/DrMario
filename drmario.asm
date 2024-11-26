################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Name, Student Number
# Student 2: Name, Student Number (if applicable)
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       TODO
# - Unit height in pixels:      TODO
# - Display width in pixels:    TODO
# - Display height in pixels:   TODO
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################


#######  TODO  #######
# - Game over
# - Pause Screen

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000

# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
    
THEME_SONG:
    .space 188

DIFFICULTY:
    .word 1   # 1 = easy, 2 = medium, 3 = hard
FRAME_COUNTER:
    .word 0    # used to store how many frames we've gone by (for gravity)
DROP_SPEED:
    .word 45  # 60 for easy, 45 for medium, 30 for hard

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    #################################################################
    ######### Display Section
    #################################################################
    # Initialize the game
    lw $s0, ADDR_DSPL       # Store display address into $s0
    li $t1, 0xaaaaaa        # Set color of line (grey)
    
    # Left border
    addi $a0, $zero, 4      # Set X coordinate for starting point
    addi $a1, $zero, 4      # Set Y coordinate for starting point
    addi $a2, $zero, 24     # Set length of line
    jal draw_vertical_line
    
    # bottom border
    addi $a0, $zero, 4      # Set X coordinate for starting point
    addi $a1, $zero, 27      # Set Y coordinate for starting point
    addi $a2, $zero, 16     # Set length of line
    jal draw_horizontal_line
    
    
    # right border
    addi $a0, $zero, 20      # Set X coordinate for starting point
    addi $a1, $zero, 4      # Set Y coordinate for starting point
    addi $a2, $zero, 24     # Set length of line
    jal draw_vertical_line
    
    # top left border
    addi $a0, $zero, 4      # Set X coordinate for starting point
    addi $a1, $zero, 4      # Set Y coordinate for starting point
    addi $a2, $zero, 6     # Set length of line
    jal draw_horizontal_line
    
    # left neck
    addi $a0, $zero, 9      # Set X coordinate for starting point
    addi $a1, $zero, 3      # Set Y coordinate for starting point
    addi $a2, $zero, 1     # Set length of line
    jal draw_vertical_line
    
    # right neck
    addi $a0, $zero, 15      # Set X coordinate for starting point
    addi $a1, $zero, 3      # Set Y coordinate for starting point
    addi $a2, $zero, 1     # Set length of line
    jal draw_vertical_line
    
    # top right border
    addi $a0, $zero, 15      # Set X coordinate for starting point
    addi $a1, $zero, 4      # Set Y coordinate for starting point
    addi $a2, $zero, 6     # Set length of line
    jal draw_horizontal_line
    
    jal load_theme
    jal init_pill
    
    lw $t0, DIFFICULTY
    easy_setup:
    bne $t0, 1, medium_setup
    jal init_virus
    jal init_virus
    jal init_virus  
    lw $t0, DROP_SPEED
    addi $t0, $zero, 60         # drop every 60 frames for easy
    sw $t0, DROP_SPEED
    j counter_setup
    medium_setup:   
    bne $t0, 2, hard_setup
    # 7 viruses for medium
    fall_back_setup:
    jal init_virus
    jal init_virus  
    jal init_virus  
    jal init_virus  
    jal init_virus  
    jal init_virus  
    jal init_virus  

    j counter_setup
    hard_setup:
    bne $t0, 3, fall_back_setup    # fallback to medium if user inputs an invalid number
    jal init_virus
    jal init_virus  
    jal init_virus  
    jal init_virus  
    jal init_virus  
    jal init_virus  
    jal init_virus
    jal init_virus  
    jal init_virus  
    jal init_virus  
    jal init_virus  
    jal init_virus
    lw $t0, DROP_SPEED
    addi $t0, $zero, 30         # drop every 30 frames for hard
    sw $t0, DROP_SPEED
    counter_setup:
    addi $t9, $zero, 0  # initiate frame counter
    addi $t8, $zero, 0  # initiate music counter
    jal score_display
    
    j game_loop
      
game_loop:
    li $v0, 32
	li $a0, 16
	syscall
	
	### counting frames (for timing purposes) ###
	lw $t0, FRAME_COUNTER                        # load how many frames we've run through
    beq $t0, 600, reset_frame_increase_speed    # reset every 600 frame to prevent overflowing and to increase drop speed
    addi $t0, $t0, 1                             # increment frame counter by 1
    sw $t0, FRAME_COUNTER                        # save frame counter
    div $t9, $t0, 13                             # divide frame counter by 13 to see if we should play new note
    mfhi $t9                                     # take the remainder
    beq $t9, 0, play_music_prep                  # play new note if remainder is 0
    

	game_loop_cont:
    addi $sp, $sp, -4           # save $t9 onto stack    
    sw $t8, 0($sp)              # store s8 for the music function
    lw $t0, FRAME_COUNTER                        # load how many frames we've run through
    lw $t9, DROP_SPEED                           # load drop speed
    div $t9, $t0, $t9                            # see if enough frames have passed to start dropping the pill
    mfhi $t9                                     # take the remainder (branching is down below to preserve control flow)
    beq $t9, 0, drop            # if enough frames have passed, drop block.

    li 		$v0, 32
	li 		$a0, 1             # check for keyboard press
	syscall    
	
	lw $t1, ADDR_KBRD               # $t1 = base address for keyboard
    lw $t8, 0($t1)                  # Load first word from keyboard
    beq $t8, 1, control_input      # If first word 1, key is pressed
    
	init_newpill_exit:             # for control flow's sake
	jal draw_pill                  # draw pill
	jal initiate_gravity           # move everything down
	
	lw $t8, 0($sp) # restore t8 from stack
	addi $sp, $sp, 4
	
    j game_loop   # loop back 
    
################################################################################
############################# Scoring System ###################################
################################################################################
score_display:
    addi $t7, $ra, 0
    addi $s1, $s1, 0    # The score uses the $s1 register thought the game
    
    # Draw Score Box
    j score_draw_box
    finish_score_draw_box:
    
    li $t1, 0xffffff    # color of the text
    # Draw Score Text
    j score_draw_text
    finish_score_draw_test:
    
    # Draw Score Digits
    j score_draw_digit
    finish_score_draw_digit:
    
    addi $ra, $t7, 0
    jr $ra
    
score_draw_text:
    addi $a0, $zero, 6      # Set X coordinate for starting point
    addi $a1, $zero, 35      # Set Y coordinate for starting point
    jal draw_s
    
    addi $a0, $zero, 10      # Set X coordinate for starting point
    addi $a1, $zero, 35      # Set Y coordinate for starting point
    jal draw_c
    
    addi $a0, $zero, 14      # Set X coordinate for starting point
    addi $a1, $zero, 35      # Set Y coordinate for starting point
    jal draw_o
    
    addi $a0, $zero, 18      # Set X coordinate for starting point
    addi $a1, $zero, 35      # Set Y coordinate for starting point
    jal draw_r
    
    addi $a0, $zero, 22      # Set X coordinate for starting point
    addi $a1, $zero, 35      # Set Y coordinate for starting point
    jal draw_e
    
    j finish_score_draw_test

score_draw_digit:
    # The thousands
    addi $t3, $zero, 1000      # Assign 1000 to $t3 to find the quotient of 4 digit score    
    # First Digit (from left to right)
    addi $a0, $zero, 8      # Set X coordinate for starting point
    addi $a1, $zero, 41      # Set Y coordinate for starting point
    div $s1, $t3             # From MARS docs: set the lo to quotient and hi to remainder
    mflo $t4                 # Assign the quotient to $t4
    jal score_draw_digit_state
    
    # The hundreds
    addi $t3, $zero, 100      # Assign 10 to $t3 to find the quotient of 3 digit score
    # Second Digit
    addi $a0, $zero, 12      # Set X coordinate for starting point
    addi $a1, $zero, 41      # Set Y coordinate for starting point
    mfhi $t4                 # Get the remainder from the previous division by 1000
    div $t4, $t3             # From MARS docs: set the lo to quotient and hi to remainder
    mflo $t4                 # Assign the quotient to $t4
    jal score_draw_digit_state
    
    # The tens
    addi $t3, $zero, 10      # Assign 10 to $t3 to find the quotient and remainder of 2 digit score
    # Third Digit
    addi $a0, $zero, 16      # Set X coordinate for starting point
    addi $a1, $zero, 41      # Set Y coordinate for starting point
    mfhi $t4                 # Get the remainder from the previous division by 100
    div $t4, $t3             # From MARS docs: set the lo to quotient and hi to remainder
    mflo $t4                 # Assign the quotient to $t4
    jal score_draw_digit_state
    
    # Fourth Digit
    addi $a0, $zero, 20      # Set X coordinate for starting point
    addi $a1, $zero, 41      # Set Y coordinate for starting point
    mfhi $t4                 # Assign the remainder to $t4
    jal score_draw_digit_state
            
    j finish_score_draw_digit

score_draw_digit_state:
    addi $t9, $ra, 0
    addi $t5, $zero, 0       # the counter to determine the digits to be drawn
    beq $t4, $t5, draw_0
    
    addi $t5, $zero, 1       # the counter to determine the digits to be drawn
    beq $t4, $t5, draw_1
    
    addi $t5, $zero, 2       # the counter to determine the digits to be drawn
    beq $t4, $t5, draw_2
    
    addi $t5, $zero, 3       # the counter to determine the digits to be drawn
    beq $t4, $t5, draw_3
    
    addi $t5, $zero, 4       # the counter to determine the digits to be drawn
    beq $t4, $t5, draw_4
    
    addi $t5, $zero, 5       # the counter to determine the digits to be drawn
    beq $t4, $t5, draw_5
    
    addi $t5, $zero, 6      # the counter to determine the digits to be drawn
    beq $t4, $t5, draw_6
    
    addi $t5, $zero, 7       # the counter to determine the digits to be drawn
    beq $t4, $t5, draw_7
    
    addi $t5, $zero, 8       # the counter to determine the digits to be drawn
    beq $t4, $t5, draw_8
    
    addi $t5, $zero, 9      # the counter to determine the digits to be drawn
    beq $t4, $t5, draw_9
    
    addi $ra, $t9, 0
    jr $ra
    
score_draw_box:
    # Reset Registers
    add $t0, $zero, 0
    add $t1, $zero, 0
    add $t2, $zero, 0
    add $t3, $zero, 0
    add $t4, $zero, 0
    add $t5, $zero, 0
    add $t6, $zero, 0
    
    ## Drawing Outer Box
    addi $a0, $zero, 4      # Set X coordinate for starting point
    addi $a1, $zero, 33      # Set Y coordinate for starting point
    
    
    li $t1, 0xc4b200        # color of the box
    add $t3, $zero, 22       # width in terms of unit
    add $t4, $zero, 14       # height in terms of unit
    jal draw_box
    
    # Reset Registers
    add $t0, $zero, 0
    add $t1, $zero, 0
    add $t2, $zero, 0
    add $t3, $zero, 0
    add $t4, $zero, 0
    add $t5, $zero, 0
    add $t6, $zero, 0
    
    ## Drawing Inner Box
    addi $a0, $zero, 5      # Set X coordinate for starting point
    addi $a1, $zero, 34      # Set Y coordinate for starting point
    
    li $t1, 0x023020        # color of the box
    add $t3, $zero, 20       # width in terms of unit
    add $t4, $zero, 12       # height in terms of unit
    jal draw_box

    j finish_score_draw_box

################################################################################
################################ Draw Digits ###################################
################################################################################
draw_9:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    sw $t1, 0($t2)          # draw (value of $t1) at current location of $t2
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    jr $ra

draw_8:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    sw $t1, 0($t2)          # draw (value of $t1) at current location of $t2
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    jr $ra
    
draw_7:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    sw $t1, 0($t2)          # draw (value of $t1) at current location of $t2
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    jr $ra
    
draw_6:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    sw $t1, 0($t2)          # draw (value of $t1) at current location of $t2
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    jr $ra
    
draw_5:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    sw $t1, 0($t2)          # draw (value of $t1) at current location of $t2
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    jr $ra
    
draw_4:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    sw $t1, 0($t2)          # draw (value of $t1) at current location of $t2
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    jr $ra
    
draw_3:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    sw $t1, 0($t2)          # draw (value of $t1) at current location of $t2
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    jr $ra

draw_2:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    sw $t1, 0($t2)          # draw (value of $t1) at current location of $t2
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    jr $ra

draw_1:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    jr $ra
    
draw_0:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    sw $t1, 0($t2)          # draw (value of $t1) at current location of $t2
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    jr $ra
    
            
################################################################################
############################# Draw Functions ###################################
################################################################################
    
draw_horizontal_line:   # params: a0, a1, a2 (x, y, len) messes with: a0, a1, a2, t2, t3
sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
sll $a2, $a2, 2         # convert line length to bytes (multiply by 4)
add $t3, $t2, $a2       # add this offset to $t2 then store in $t3 to figure out when to stop drawing

horizontal_line_start:
sw $t1, 0($t2)          # draw yellow at current location
addi $t2, $t2, 4        # move current location by 1 pixel (4 bytes)
beq $t2, $t3, horizontal_line_end  # break out of look if we've drawn all the pixels in the line
j horizontal_line_start # jump back to start of loop

horizontal_line_end:
jr $ra


draw_vertical_line:     # params: a0, a1, a2 (x, y, len) messes with: a0, a1, a2, t2, t3
sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
sll $a2, $a2, 7         # calculate the amount of bytes we'll go through ( 2^7 = 128 * rows )
add $t3, $t2, $a2       # add this offset to $t2 then store in $t3 to figure out when to stop drawing


vertical_line_start:
sw $t1, 0($t2)          # draw yellow at current location
addi $t2, $t2, 128      # move current location by 1 pixel (4 bytes)
beq $t2, $t3, vertical_line_end  # break out of look if we've drawn all the pixels in the line
j vertical_line_start   # jump back to start of loop

vertical_line_end:
jr $ra

## Draw Box Function
## Parameters: 
## $a0: Set X coordinate for starting point
## $a1: Set Y coordinate for starting point
## $t1: color of box (load intermediate)
## $t3: width in terms of unit
## $t4: height in terms of unit  
draw_box:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    
    mult $t3, $t3, 4            # multiply width by size which is 4 bytes
    add $t5, $t3, $t2         # add the width of box, store in $t3
    
    mult $t4, $t4, 128          # multiply height by size which is 128 bytes for each unit
    add $t6, $t4, $t2         # add the height of box, store in $t4
    
    addi $sp, $sp, -4           # change the stack pointer to write return of this function 
    sw $ra, 0($sp)              # save $ra onto stack 
    draw_box_line:
        sw $t1, 0($t2)                      # draw yellow (value of $t1) at current location of $t2
        bge $t2, $t5, draw_box_line_end     # break out of look if we've drawn all the pixels in the line
        addi $t2, $t2, 4                    # move current location by 1 pixel to the right (4 bytes)
        j draw_box_line                     # jump back to start of loop
    draw_box_line_end:
        bge $t2, $t6, return_draw_box
        addi $t2, $t2, 128
        sub $t2, $t2, $t3         # reset the x-coordinate
        add $t5, $t2, $t3        # add the width of box, store in $t5 (8 units right, each unit is 4 bytes)
        j draw_box_line        # jump back to start of loop
    
    return_draw_box:
    lw $ra, 0($sp)              # restore $ra
    addi $sp, $sp, 4           # reset pointer to the calling function
    jr $ra


init_virus:
li $v0 , 42             # randomize X value
li $a0 , 0 
li $a1 , 14
syscall                 # store in $a0
addi $a0, $a0, 5        # Add the X offset, for where the bottle starts
sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
add $t2, $s0, $a0       # add the X offset to $s0, store in $t2


li $v0 , 42             # randomize Y value
li $a0 , 0              # generate random number between 0 and 3
li $a1 , 16             # Add the Y offset, so that the pill only spawns in 3/4 of the bottle
syscall                 # store in $a0
addi $a1, $a0, 10       # Add the Y offset, for where the bottle starts
sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2

#### We're going to initiate virus colors a litttttttle bit differently #######1
li $t3, 0xffff01        # temporary yellow
li $t4, 0xff0001        # temporary red
li $t5, 0x0000f1        # temporary blue


li $v0 , 42             # randomize virus color
li $a0 , 0              
li $a1 , 3             
syscall                 # store in $a0
beq $a0, 0, virus_yellow     # draw yellow if a0 = 0
beq $a0, 1, virus_red        # draw red if a0 = 1
beq $a0, 2, virus_blue          # draw blue if a0 = 2
virus_yellow:
sw $t3, 0($t2)
jr $ra
virus_red:
sw $t4, 0($t2)
jr $ra
virus_blue:
sw $t5, 0($t2)
jr $ra

### Draws the pill at the spawn location and saves the properties of the 2 blocks
# block 1 color is in $s2
# block 2 color is in $s3
# block 1's memory address is in $s4
# block 2's memory address is in $s5
init_pill:      # params: a0, a1 (x, y) messes with: t3, t4, t5, v0, a0, a1, s2, s3, s4
addi $a0, $zero, 12     # Set x coordinate for starting point
addi $a1, $zero, 4      # Set y coordinate for starting point
addi $s6, $zero, 0      # Set the rotation state back to zero
    
sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
add $s4, $t2, $zero     # store block 1's position into $s4

##### Game Over #####
lw $t9, 0($s4)
bne $t9, $zero, game_over_state
    
li $v0 , 42             # let the system know we're randomizing
li $a0 , 0             # generate random number between 0 and 3
li $a1 , 3
syscall                 # store in $a0

li $t3, 0xffff00        # temporary yellow
li $t4, 0xff0000        # temporary red
li $t5, 0x0000ff        # temporary blue


beq $a0, 0, draw_yellow     # draw yellow if a0 = 0
beq $a0, 1, draw_red          # draw red if a0 = 1
beq $a0, 2, draw_blue          # draw blue if a0 = 2
jr $ra

draw_yellow:
sw $t3, 0($t2)
li $s2, 0xffff00        #store color into $s2
j init_second_block
draw_red:
sw $t4, 0($t2)
li $s2, 0xff0000        #store color into $s2
j init_second_block
draw_blue:
sw $t5, 0($t2)
li $s2, 0x0000ff        #store color into $s2
j init_second_block

init_second_block:
addi $t2, $t2, 128      # move to the second block
add $s5,  $t2, $zero    # store block 2's position in $s5
li $v0 , 42             # let the system know we're randomizing
li $a0 , 0             # generate random number between 0 and 3
li $a1 , 3
syscall                 # store in $a0

beq $a0, 0, draw_yellow2     # draw yellow if a0 = 0
beq $a0, 1, draw_red2          # draw red if a0 = 1
beq $a0, 2, draw_blue2          # draw blue if a0 = 2

draw_yellow2:
sw $t3, 0($t2)
li $s3, 0xffff00        #store color into $s3
jr $ra
draw_red2:
sw $t4, 0($t2)
li $s3, 0xff0000        #store color into $s3
jr $ra
draw_blue2:
sw $t5, 0($t2)
li $s3, 0x0000ff        #store color into $s3
jr $ra

draw_pill:
sw $s2, 0($s4)          # draw block 1
sw $s3, 0($s5)          # draw block 1
jr $ra

################################################################################
########################## Movement and Controls ###############################
################################################################################
control_input:                     # A key is pressed
    lw $a0, 4($t1)                  # Load second word from keyboard
    
    ## Movement and Control Scanner ##
    # Move left 
    beq $a0, 0x77, rotate        # Check if the key W was pressed
    # Move right
    beq $a0, 0x61, move_left     # Check if the key A was pressed
    # Rotate
    beq $a0, 0x73, drop          # Check if the key S was pressed
    # Drop
    beq $a0, 0x64, move_right    # Check if the key D was pressed
    # Quit
    beq $a0, 0x71, quit     # Check if the key Q was pressed
    
    # Pause
    beq $a0, 0x70, pause_state     # Check if the key p was pressed
    

    j game_loop
    
move_left:            
    sw $zero, 0($s4)         # clear first block
    sw $zero, 0($s5)         # clear second block
     
    addi $t6, $ra, 0         # store the return address of this function
    addi $t7, $zero, -4      # left collision to be used in collision funciton
    jal collision_check
    addi $ra, $t6, 0         # load the return address of this function
    bne $t9, $zero, return   # early return by not shifting position if there is a collision
    
    addi $s4, $s4, -4        # Shift the x-coordinate of the first pill block by 1 unit to the left
    addi $s5, $s5, -4        # Shift the x-coordinate of the second pill block by 1 unit to the left
    jr $ra

move_right:
    sw $zero, 0($s4)         # clear first block
    sw $zero, 0($s5)         # clear second block
    
    addi $t6, $ra, 0         # store the return address of this function
    addi $t7, $zero, 4      # left collision to be used in collision funciton
    jal collision_check
    addi $ra, $t6, 0         # load the return address of this function
    bne $t9, $zero, return   # early return by not shifting position if there is a collision
    
    addi $s4, $s4, 4         # Shift the x-coordinate of the first pill block by 1 unit to the right
    addi $s5, $s5, 4         # Shift the x-coordinate of the second pill block by 1 unit to the right
    jr $ra
    
rotate:
    #### TODO: Insert the beq logic here ####
    sw $zero, 0($s4)         # clear first block
    sw $zero, 0($s5)         # clear second block
    
    beq $s6, 0, rotate_1
    beq $s6, 1, rotate_2
    beq $s6, 2, rotate_3
    beq $s6, 3, rotate_4
    jr $ra
    
rotate_1:
    addi $t6, $ra, 0         # store the return address of this function
    addi $t7, $zero, -4      # top collision to be used in collision funciton
    jal collision_check
    addi $ra, $t6, 0         # load the return address of this function
    bne $t9, $zero, return   # early return by not rotating if there is a collision
    
    addi $s4, $s4, 124          # rotate from top to left
    addi $s6, $zero, 1          # increment rotation state
    jr $ra
    
rotate_2:
    addi $t6, $ra, 0         # store the return address of this function
    addi $t7, $zero, 128      # left collision to be used in collision funciton
    jal collision_check
    
    addi $ra, $t6, 0         # load the return address of this function
    bne $t9, $zero, return   # early return by not rotating if there is a collision
    
    addi $s4, $s4, 132        # rotate from left to bottom
    addi $s6, $zero, 2          # increment rotation state
    jr $ra
    
rotate_3:
    
    addi $t6, $ra, 0         # store the return address of this function
    addi $t7, $zero, 4      # right collision to be used in collision funciton
    jal collision_check
    addi $ra, $t6, 0         # load the return address of this function
    bne $t9, $zero, return   # early return by not rotating if there is a collision
    
    addi $s4, $s4, -124        # rotate from bottom to right
    addi $s6, $zero, 3          # increment rotation state
    jr $ra

rotate_4:
    addi $t6, $ra, 0         # store the return address of this function
    addi $t7, $zero, -128       # top collision to be used in collision funciton
    jal collision_check
    addi $ra, $t6, 0         # load the return address of this function
    bne $t9, $zero, return   # early return by not rotating position if there is a collision
    
    addi $s4, $s4, -132       # rotate from right to top
    addi $s6, $zero, 0          # increment rotation state
    jr $ra
    
drop:
    addi $t7, $zero, 128      # bottom collision to be used in collision funciton
    sw $zero, 0($s4)         # clear first block temporarily
    sw $zero, 0($s5)         # clear second block temporarily
    
    addi $t6, $ra, 0          # store the return address of this function
        ### Check if it collides with anything at the bottom
        jal collision_check       # updates $t9 to non zero if it collides from the current location
        beq $t9, $zero, shift_below
        
        ### Check if it collides with anything at the bottom
        jal draw_pill                   # redraw the pill
        # initialise a new pill if it collides with anything below it
        bne $t9, $zero, init_new_pill   # initialize a new pill 
    
    addi $ra, $t6, 0            # load the return address of this function

    shift_below:
        addi $ra, $t6, 0        # load the return address of this function
        addi $s4, $s4, 128      # Shift the y-coordinate of the first pill block by 1 unit below
        addi $s5, $s5, 128      # Shift the y-coordinate of the second pill block by 1 unit below
    jr $ra
    
    

init_new_pill:
    
    addi $sp, $sp, -4           # save $ra onto stack    
    
    sw $ra, 0($sp)
	jal check_clear_block1
	jal check_clear_block2
	lw $ra, 0($sp)              # restore $ra
    addi $sp, $sp, 4 
    addi $s4, $zero, 0          # Shift the y-coordinate of the first pill block by 1 unit below
    addi $s5, $zero, 0          # Shift the y-coordinate of the second pill block by 1 unit below
    jal init_pill               # initialize a new pill
    
    j init_newpill_exit

collision_check:    
    # load some register to specify direction + 4 or +128 for example
    # addi $t7, $t7, 4  # right collision block
    # addi $t7, $t7, -128  # top collision block
    # addi $t7, $t7, 128  # bottom collision block
    
    sw $zero, 0($s4)         # clear first block
    sw $zero, 0($s5)         # clear second block
    
    add $t9, $s5, $t7         # the collition detection block for the first pill block
    lw $t9, 0($t9)            # load the color value of the collision block
    bne $t9, $zero, return    # early return if anything is there at t9 where block 1 is going
    
    add $t9, $s4, $t7         # the collision detection block for the second pill block
    lw $t9, 0($t9)            # load the color value of the collision block
    
    jr $ra
    
quit:
	li $v0, 10                      # Quit gracefully
	syscall
    
return:
jr $ra

###### Big block for the check and clear stuff ######
check_clear_block1: 
    add $t3, $zero, $s2     #load block 1 color
    andi $t3, $t3, 0xfffff0 # mask block1's to make sure that it reads the same as the virus
    add $t4, $zero, $s4     #load block 1 pos, we'll use this as our read head
    addi $sp, $sp, -4           # initialize reading pointer     
    sw $t4, 0($sp)              # store original position into stack
    addi $t5, $zero, 0            # initialize our counter
    j check_left

check_clear_block2: 
    add $t3, $zero, $s3     #load block 1 color
    andi $t3, $t3, 0xfffff0 # mask block1's to make sure that it reads the same as the virus
    add $t4, $zero, $s5     #load block 1 pos, we'll use this as our read head
    addi $sp, $sp, -4           # initialize reading pointer     
    sw $t4, 0($sp)              # store original position into stack
    addi $t5, $zero, 0            # initialize our counter
    j check_left
      
check_left:
    lw $t6, 0($t4)                  # load color at current point into $t6
    andi $t6, $t6, 0xfffff0         # mask the current pixel's color to make sure we don't skip the virus
    bne $t3, $t6, restore_checker1    # while color is still the same as pill it was called on
        addi $t5, $t5, 1                # counter +1 
        addi $t4, $t4, -4               # traverse left
        j check_left                    # keep going left

restore_checker1:
    lw $t4, 0($sp)              # we reset the read head, restoring $t4
    addi $t4, $t4, +4         # traverse right first

check_right:
    lw $t6, 0($t4)              # load color at current point into $t6
    andi $t6, $t6, 0xfffff0         # mask the current pixel's color to make sure we don't skip the virus
    bne $t3, $t6, check_transition   # while color is still the same as pill it was called on
        addi $t5, $t5, 1            # counter +1 
        addi $t4, $t4, +4         # traverse down
        j check_right                  # keep going down

check_transition:
    bge $t5, 4, clear_horizontal_prep         # if counter >= 4,
    lw $t4, 0($sp)              # we reset the read head, restoring $t4
    addi $t5, $zero, 0          # reset the counter

check_up:
    lw $t6, 0($t4)              # load color at current point into $t6
    andi $t6, $t6, 0xfffff0         # mask the current pixel's color to make sure we don't skip the virus
    bne $t3, $t6, restore_check_head2    # while color is still the same as pill it was called on
        addi $t5, $t5, 1            # counter +1 
        addi $t4, $t4, -128         # traverse up
        j check_up                  # keep going up
    
restore_check_head2:
    lw $t4, 0($sp)              # we reset the read head, restoring $t4
    addi $t4, $t4, +128         # traverse down, since we already checked where we started

check_down:
    lw $t6, 0($t4)              # load color at current point into $t6
    andi $t6, $t6, 0xfffff0         # mask the current pixel's color to make sure we don't skip the virus
    bne $t3, $t6, check_if_four_vertical   # while color is still the same as pill it was called on
    addi $t5, $t5, 1            # counter +1 
    addi $t4, $t4, +128         # traverse down
    j check_down                  # keep going down

check_if_four_horizontal:
lw $t4, 0($sp)              # we reset the read head, restoring $t4
bge $t5, 4, clear_horizontal_prep         # if counter >= 4,
addi $sp, $sp, 4            # move stack pointer back up!!!! 
j check_transition

check_if_four_vertical:
bge $t5, 4, clear_vertical_prep         # if counter >= 4,
addi $sp, $sp, 4            # move stack pointer back up!!!! 
j temp_exit

clear_horizontal_prep:
lw $t4, 0($sp)              # we reset the read head, restoring $t4
lw $t6, 0($t4)                  # load color at current point into $t6
clear_left:
    lw $t3, 0($t4)                  # load color at current point into $t3
    bne $t3, $t6, restore_clear1    # while color is still the same as pill it was called on
    sw $zero, 0($t4)                # paint the screen at $t4 black
    ### start the move things above down loop ###
    addi $t5, $t4, 0                        # use $t5 as a pointer for where we are
    # jal move_things_down
        move_things_down:
        lw $t7, -128($t5)                       # use $t7 to store color above
        beq $t7, $zero, continue_clear_left     # while above is not black
        # TODO: check if it's a virus
        sw $t7, 0($t5)                          # write above pixel onto where t5 is
        sw $zero, -128($t5)                     # paint the above area zero.
        addi $t5, $t5, -128                     # traverse up
        j move_things_down
        
        
continue_clear_left:
    addi $t4, $t4, -4               # traverse left
    j clear_left                    # keep going left
    
restore_clear1:
lw $t4, 0($sp)              # we reset the read head, restoring $t4
addi $t4, $t4, 4            # shift head by 1 unit to the right, since we already checked the place we started
#TODO: reset the header

clear_right:
    lw $t3, 0($t4)                  # load color at current point into $t6
    bne $t3, $t6, temp_exit    # while color is still the same as pill it was called on
    sw $zero, 0($t4)                # paint the screen at $t4 black
    ### start the move things above down loop ###
    addi $t5, $t4, 0                        # use $t5 as a pointer for where we are
    # jal move_things_down
        move_things_down2:
        lw $t7, -128($t5)                       # use $t7 to store color above
        beq $t7, $zero, continue_clear_right     # while above is not black
        # TODO: check if it's a virus
        sw $t7, 0($t5)                          # write above pixel onto where t5 is
        sw $zero, -128($t5)                     # paint the above area zero
        addi $t5, $t5, -128                     # traverse up
        j move_things_down2
        
        
continue_clear_right:
    addi $t4, $t4, 4               # traverse right
    j clear_right                  # keep going right


clear_vertical_prep:
lw $t4, 0($sp)                  # we reset the read head, restoring $t4
lw $t6, 0($t4)                  # load color at current point into $t6
andi $t6, $t6, 0xfffff0         # mask the current pixel's color to make sure we don't skip the virus
addi $t5, $zero, 0              # initialize t5 as a counter of how much we've cleared

clear_up:
lw $t3, 0($t4)                  # load color at t4 current point to t3
andi $t3, $t3, 0xfffff0         # mask the current pixel's color to make sure we don't skip the virus
bne $t3, $t6, restore_clear2    # while color t3 is same as t6 else go to restore clear 2
sw $zero, 0($t4)                # paint the screen at t4 black
addi $t5, $t5, 1                # increment t5 by 1
addi $t4, $t4, -128             # increment t4 by -128 to move further up
j clear_up                      # loop

restore_clear2:
lw $t4, 0($sp)                # we reset the clear head, restoring $t4
addi $t4, $t4, 128            # shift head by 1 unit down, since we already cleared the place we started

clear_down:
lw $t3, 0($t4)                  # load color at t4 current point to t3
andi $t3, $t3, 0xfffff0         # mask the current pixel's color to make sure we don't skip the virus
bne $t3, $t6, finish_clearing # while color t3 is same as t6 else go to move things down 3
sw $zero, 0($t4)                # paint the screen at t4 black
addi $t5, $t5, 1                # increment t5 by 1
addi $t4, $t4, 128              # increment t4 by 128 to travel down
j clear_down

finish_clearing:
addi $sp, $sp, 4
jr $ra

temp_exit:
# addi $sp, $sp, 4           # restore stack pointer once we're done checking everrrrry thing 
jr $ra

################################################################################
############################ Gravity Functions #################################
################################################################################
initiate_gravity:
addi $t3, $s0, 660 # initiate pointer at top left of bottle x = 5, y =5
gravity_loop:
    beq $t3, 0x10008D00 , temp_exit # check if we're beyond bound of bottle o
    lw $t4, 0($t3)  # load color at current point
    beq $zero, $t4, gravity_loop_cont  # if curr not black, if curr is black: go to pointer +4
    # TODO: if curr not virus, else: go to pointer +4
    andi $t7, $t4, 0x0F     # check if current pixel is a virus (the last hex digit is a 1)
    beq $t7, 1, gravity_loop_cont
    beq $t3, $s4, gravity_loop_cont  # don't clear if we're checking the active pill
    beq $t3, $s5, gravity_loop_cont  # don't clear if we're checking the active pill   
    lw $t5, 128($t3) # load color below curr
    bne $t5, $zero, gravity_loop_cont  # increment if down below isn't black
    lw $t5, -4($t3) # load color to the left into t5
    beq $t5, 0, gravity_right_check # if the left is black go to check right
    bne $t5, 0xaaaaaa, gravity_loop_cont # then left should be wall then go to check right, else jump to increment
    gravity_right_check:
    lw $t5, 4($t3)  # load color to the right into t5
    beq $t5, $zero, move_shit_down_prep  # if right is black go to to move shit down, else check if wall
    bne $t5, 0xaaaaaa, gravity_loop_cont # if right is wall go to move shit down
        move_shit_down_prep:
        addi $t4, $t3, 0    # load $t3 into $t4 since we're going to be messing with it.
        move_shit_down:
        lw $t5, 128($t4)    # load a block below into t5
        bne $zero, $t5, gravity_loop_cont # while block below is black
        lw $t5, 0($t4)      # store color at current point into $t5
        sw $t5, 128($t4)    # write current pos to 128 below
        sw $zero, 0($t4)    # erase current pos
        addi $t4, $t4, 128  # increment t4
        j move_shit_down
    gravity_loop_cont:
    addi $t3, $t3, 4 # pointer + 4
    j gravity_loop
    

        
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
jr $ra

play_music_prep:
bge $t8, 46, restart_theme


play_music:
 # if note reader reached the end reset s7 back to the address theme_song
# reset to 0 
sll $t3, $t8, 2
add $t6, $s7, $t3  # add the beat counter
li $v0 31   # MIDI syscall
lw $a0, 0($t6)  #load note
li $a1, 13 # len in ms
li $a2, 12   # synth instrument
li $a3, 60  # volume
addi $t8, $t8, 1
syscall
j game_loop_cont

restart_theme:
addi, $t8, $zero, 0
addi, $t6, $zero, 0
j play_music

reset_frame_increase_speed:
sw $zero, FRAME_COUNTER     # once we've reached the frame counter limit, we reset the counter to avoid overflowing
lw $t4, DROP_SPEED          # load drop speed
blt $t4, 10, game_loop
subi $t4, $t4, 5           # increase it by 5 frames
sw $t4, DROP_SPEED          # store drop speed
j game_loop                  # jump back to game loop

################################################################################
############################## Restart State ###################################
################################################################################
restart_state:
    # clear the screen
    addi $t7, $ra, 0 
    
    # Reset Registers
    add $t0, $zero, 0
    add $t1, $zero, 0
    add $t2, $zero, 0
    add $t3, $zero, 0
    add $t4, $zero, 0
    add $t5, $zero, 0
    add $t6, $zero, 0
    
    ## Draw Black Box
    addi $a0, $zero, 1      # Set X coordinate for starting point
    addi $a1, $zero, 1      # Set Y coordinate for starting point
    
    li $t1, 0x000000        # color of the box
    add $t3, $zero, 64       # width in terms of unit
    add $t4, $zero, 64       # height in terms of unit
    jal draw_box
    
    addi $ra, $t7, 0
    
    j main

################################################################################
####################### Game Over State and Loop ###############################
################################################################################
game_over_state:
    # clear the screen
    addi $t7, $ra, 0 
    
    # Reset Registers
    add $t0, $zero, 0
    add $t1, $zero, 0
    add $t2, $zero, 0
    add $t3, $zero, 0
    add $t4, $zero, 0
    add $t5, $zero, 0
    add $t6, $zero, 0
    
    ## Draw Black Box
    addi $a0, $zero, 1      # Set X coordinate for starting point
    addi $a1, $zero, 1      # Set Y coordinate for starting point
    
    li $t1, 0x000000        # color of the box
    add $t3, $zero, 64       # height in terms of unit
    add $t4, $zero, 32       # height in terms of unit
    jal draw_box
    addi $ra, $t7, 0
    
    # top left border
    ## 16x16 is center
    addi $ra, $t7, 0
    
    jal draw_game_over_box
    
    ## Drawing Text
    li $t1, 0xffffff    # color of the text
    addi $a0, $zero, 5      # Set X coordinate for starting point
    addi $a1, $zero, 7      # Set Y coordinate for starting point
    jal draw_g_large
    
    addi $a0, $zero, 10      # Set X coordinate for starting point
    addi $a1, $zero, 7      # Set Y coordinate for starting point
    jal draw_a_large
    
    addi $a0, $zero, 15      # Set X coordinate for starting point
    addi $a1, $zero, 7      # Set Y coordinate for starting point
    jal draw_m_large
    
    addi $a0, $zero, 23      # Set X coordinate for starting point
    addi $a1, $zero, 7      # Set Y coordinate for starting point
    jal draw_e_large
    
    addi $a0, $zero, 7      # Set X coordinate for starting point
    addi $a1, $zero, 17      # Set Y coordinate for starting point
    jal draw_o_large
    
    addi $a0, $zero, 12      # Set X coordinate for starting point
    addi $a1, $zero, 17      # Set Y coordinate for starting point
    jal draw_v_large
    
    addi $a0, $zero, 17      # Set X coordinate for starting point
    addi $a1, $zero, 17      # Set Y coordinate for starting point
    jal draw_e_large
    
    addi $a0, $zero, 22      # Set X coordinate for starting point
    addi $a1, $zero, 17      # Set Y coordinate for starting point
    jal draw_r_large
    
    j game_over_loop

game_over_loop:
    li 		$v0, 32
	li 		$a0, 1             # check for keyboard press
	syscall    
	
	lw $t1, ADDR_KBRD               # $t1 = base address for keyboard
    lw $t8, 0($t1)                  # Load first word from keyboard
    beq $t8, 1, game_over_input
       
    j game_over_loop

game_over_input:
    lw $a0, 4($t1)                  # Load second word from keyboard
    beq $a0, 0x72, restart_state         # Check if the key R was pressed
    beq $a0, 0x71, quit         # Check if the key Q was pressed
    j game_over_loop
    
draw_game_over_box:
    addi $t7, $ra, 0 
    # Reset Registers
    add $t0, $zero, 0
    add $t1, $zero, 0
    add $t2, $zero, 0
    add $t3, $zero, 0
    add $t4, $zero, 0
    add $t5, $zero, 0
    add $t6, $zero, 0
    
    ## Drawing Outer Box
    addi $a0, $zero, 3      # Set X coordinate for starting point
    addi $a1, $zero, 5      # Set Y coordinate for starting point
    
    li $t1, 0xc4b200        # color of the box
    add $t3, $zero, 25       # width in terms of unit
    add $t4, $zero, 20       # height in terms of unit
    jal draw_box
    
    # Reset Registers
    add $t0, $zero, 0
    add $t1, $zero, 0
    add $t2, $zero, 0
    add $t3, $zero, 0
    add $t4, $zero, 0
    add $t5, $zero, 0
    add $t6, $zero, 0
    
    ## Drawing Inner Box
    addi $a0, $zero, 4      # Set X coordinate for starting point
    addi $a1, $zero, 6      # Set Y coordinate for starting point
    
    li $t1, 0x0000ff        # color of the box
    add $t3, $zero, 23       # width in terms of unit
    add $t4, $zero, 18       # height in terms of unit
    jal draw_box
    
    addi $ra, $t7, 0
    jr $ra
    
################################################################################
########################## Pause State and Loop ################################
################################################################################

pause_state:
    # top left border
    ## 16x16 is center
    jal draw_pause_box
    
    li $t1, 0xffffff    # color of the text
    addi $a0, $zero, 4      # Set X coordinate for starting point
    addi $a1, $zero, 52      # Set Y coordinate for starting point
    jal draw_p
    
    addi $a0, $zero, 8      # Set X coordinate for starting point
    addi $a1, $zero, 52      # Set Y coordinate for starting point
    jal draw_a
    
    addi $a0, $zero, 12      # Set X coordinate for starting point
    addi $a1, $zero, 52      # Set Y coordinate for starting point
    jal draw_u
    
    addi $a0, $zero, 16      # Set X coordinate for starting point
    addi $a1, $zero, 52      # Set Y coordinate for starting point
    jal draw_s
    
    addi $a0, $zero, 20      # Set X coordinate for starting point
    addi $a1, $zero, 52      # Set Y coordinate for starting point
    jal draw_e
    
    addi $a0, $zero, 24      # Set X coordinate for starting point
    addi $a1, $zero, 52      # Set Y coordinate for starting point
    jal draw_d
    
    j pause_loop

pause_loop:
    li 		$v0, 32
	li 		$a0, 1             # check for keyboard press
	syscall    
	
	lw $t1, ADDR_KBRD               # $t1 = base address for keyboard
    lw $t8, 0($t1)                  # Load first word from keyboard
    beq $t8, 1, pause_input
       
    j pause_loop

pause_input:
    lw $a0, 4($t1)                  # Load second word from keyboard
    beq $a0, 0x70, upause_state         # Check if the key p was pressed
    jr $ra
    
upause_state:
    add $t0, $zero, 0
    add $t1, $zero, 0
    add $t2, $zero, 0
    add $t3, $zero, 0
    add $t4, $zero, 0
    add $t5, $zero, 0
    add $t6, $zero, 0
    
    addi $a0, $zero, 3      # Set X coordinate for starting point
    addi $a0, $zero, 2      # Set X coordinate for starting point
    addi $a1, $zero, 50      # Set Y coordinate for starting point
    li $t1, 0x000000        # color of the box
    add $t3, $zero, 26       # width in terms of unit
    add $t4, $zero, 8       # height in terms of unit
    
    jal draw_box
     
    j game_loop
store_box:
    
draw_pause_box:  
    addi $t7, $ra, 0 
    
    # Reset Registers
    add $t0, $zero, 0
    add $t1, $zero, 0
    add $t2, $zero, 0
    add $t3, $zero, 0
    add $t4, $zero, 0
    add $t5, $zero, 0
    add $t6, $zero, 0
    
    ## Drawing Outer Box
    addi $a0, $zero, 2      # Set X coordinate for starting point
    addi $a1, $zero, 50      # Set Y coordinate for starting point
    
    li $t1, 0xc4b200        # color of the box
    add $t3, $zero, 26       # width in terms of unit
    add $t4, $zero, 8       # height in terms of unit
    jal draw_box
    
    # Reset Registers
    add $t0, $zero, 0
    add $t1, $zero, 0
    add $t2, $zero, 0
    add $t3, $zero, 0
    add $t4, $zero, 0
    add $t5, $zero, 0
    add $t6, $zero, 0
    
    ## Drawing Inner Box
    addi $a0, $zero, 3      # Set X coordinate for starting point
    addi $a1, $zero, 51      # Set Y coordinate for starting point
    
    li $t1, 0x0000ff        # color of the box
    add $t3, $zero, 24       # width in terms of unit
    add $t4, $zero, 6       # height in terms of unit
    jal draw_box
    
    ## Drawing Text
    # add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    # add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    
    addi $ra, $t7, 0
    
    jr $ra   



################################################################################
################################ Draw Letters ##################################
################################################################################
draw_r:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    
    jr $ra

draw_o:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    sw $t1, 0($t2)          # draw (value of $t1) at current location of $t2
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    jr $ra

draw_c:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    
    add $t2, $t2, 120
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    jr $ra



draw_d:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    sw $t1, 0($t2)      # draw (value of $t1) at current location of $t2
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    jr $ra
    
draw_e:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    
    add $t2, $t2, 120
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    jr $ra
    
draw_s:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    jr $ra
    
draw_u:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    sw $t1, 0($t2)      # draw (value of $t1) at current location of $t2
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    jr $ra
    
draw_a:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    jr $ra
    
draw_p:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    sw $t1, 0($t2)      # draw (value of $t1) at current location of $t2
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 8
    
    add $t2, $t2, 120
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    
    jr $ra
    
draw_r_large:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    
    jr $ra

    
draw_v_large:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    
    jr $ra

draw_o_large:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    
    jr $ra

    
draw_e_large:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    
    add $t2, $t2, 116
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    
    jr $ra

draw_m_large:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4   
    sw $t1, 0($t2)
    add $t2, $t2, 4   
    add $t2, $t2, 104
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 104
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 104
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 104
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 104
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 104
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    jr $ra

draw_a_large:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    
    jr $ra


draw_g_large:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    
    jr $ra

draw_8_large:
    sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
    sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
    add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
    add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
    sw $t1, 0($t2)      # draw (value of $t1) at current location of $t2
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 12
    sw $t1, 0($t2)
    add $t2, $t2, 116
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2)
    add $t2, $t2, 4
    sw $t1, 0($t2) 
    jr $ra
    

