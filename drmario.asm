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

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!  
ADDR_KBRD:
    .word 0xffff0000                # address word for the keyboard

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

main:
    # Initialize the game
    li 		$v0, 32
	li 		$a0, 1
	syscall

# Run the game.
game_loop:
    # 1a. Check if key has been pressed
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    
    # 1b. Check which key has been pressed
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    
    
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop
	


##############################################################################
# Movement and Controls
##############################################################################
## Check which input is pressed
keyboard_input:                     # A key is pressed
    lw $a0, 4($t0)                  # Load second word from keyboard
    
    ## Movement and Control Scanner ##
    # Move left 
    beq $a0, 0x57, move_left     # Check if the key W was pressed
    # Move right
    beq $a0, 0x41, move_right     # Check if the key A was pressed
    # Rotate
    beq $a0, 0x53, rotate     # Check if the key S was pressed
    # Drop
    beq $a0, 0x44, drop     # Check if the key D was pressed
    # Quit
    beq $a0, 0x51, quit     # Check if the key D was pressed


## Movement and Control Functions
move_left: 
    
move_right:
    
rotate:
    
drop:
    
quit:
	li $v0, 10                      # Quit gracefully
	syscall
	
	
    