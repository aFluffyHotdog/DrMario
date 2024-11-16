 ##############################################################################
# Example: Keyboard Input
#
# This file demonstrates how to read the keyboard to check if the keyboard
# key q was pressed.
##############################################################################
    .data
ADDR_KBRD:
    .word 0xffff0000                # address word for the keyboard

    .text 
	.globl main

main:
	li 		$v0, 32
	li 		$a0, 1
	syscall

    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    j main

keyboard_input:                     # A key is pressed
    lw $a0, 4($t0)                  # Load second word from keyboard
    
    ## Movement and Control Scanner ##
    # Move left 
    beq $a0, 0x87, move_left     # Check if the key W was pressed
    # Move right
    beq $a0, 0x65, move_right     # Check if the key A was pressed
    # Rotate
    beq $a0, 0x83, rotate     # Check if the key S was pressed
    # Drop
    beq $a0, 0x68, drop     # Check if the key D was pressed
    # Quit
    beq $a0, 0x71, quit     # Check if the key Q was pressed

    j main
    
## Movement and Control Functions
move_left: 

move_right:

rotate:

drop:

quit:
	# li $v0, 10                      # Quit gracefully
	# syscall
	


