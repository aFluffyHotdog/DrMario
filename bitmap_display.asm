##############################################################################
# Example: Displaying Pixels
#
# This file demonstrates how to draw pixels with different colours to the
# bitmap display.
##############################################################################

######################## Bitmap Display Configuration ########################
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
##############################################################################
    .data
ADDR_DSPL:
    .word 0x10008000

    .text
	.globl main

main:
        addi $t9, $zero, 24     # we are looping 24 times
        addi $t2, $zero, 0      # $t2 = loop variable i
        li $t1, 0x666666        # $t1 = grey
        lw $t0, ADDR_DSPL       # $t0 = base address for display
        addi $t0, $t0, 528      # add initial offset of x = right 4, y = down 4

START:  # setup to draw left border
        beq $t2, $t9, START2    # terminate loop when t2 = t9 or i = 24
UPDATE: 
        addi $t0, $t0, 128      # we shift where we write by 128 bits
        addi $t2, $t2, 1        # increment our loop variable
        sw $t1, 0($t0)          # we draw a grey square
        j START


START2: # setup to draw bottom border
        addi $t2, $zero, 0      # reset $t2 back to 0
        addi $t9, $zero, 16     # will only loop 16 times
        j LOOP2
LOOP2:
        beq $t2, $t9, START3    # terminate when i = 16
UPDATE2: 
        addi $t0, $t0, 4        # we shift where we write by 4 bits (+ 1 to the right)
        addi $t2, $t2, 1        # increment our loop variable
        sw $t1, 0($t0)
        j LOOP2
        
        
START3: # setup to draw right border
        addi $t2, $zero, 0      #reset $t2 back to 0
        addi $t9, $zero, 23     #will only loop 23 times (one pixelis already drawn in so we draw 1 less time)
        j LOOP3
LOOP3:
        beq $t2, $t9, START4      #terminate when i = 24
UPDATE3: 
        addi $t0, $t0, -128     #we shift where we write by 4 bits
        addi $t2, $t2, 1        #increment our loop variable
        sw $t1, 0($t0)
        j LOOP3
        
START4: # setup to draw right border
        addi $t2, $zero, 0      #reset $t2 back to 0
        addi $t9, $zero, 6     #will only loop 23 times
        j LOOP4
LOOP4:
        beq $t2, $t9, START5      #terminate when i = 24
UPDATE4: 
        addi $t0, $t0, -4     #we shift where we write by 4 bits
        addi $t2, $t2, 1        #increment our loop variable
        sw $t1, 0($t0)
        j LOOP4
        
START5: # setup to draw top left part + bottle neck
        addi $t0, $t0, -128	
        sw $t1, 0($t0)		#drew right lip
        addi $t0, $t0, 128
        addi $t2, $zero, 0      #reset $t2 back to 0
        addi $t9, $zero, 6      #will only loop 6 times
        addi $t0, $t0, -16      #jump over the bottle neck
        addi $t0, $t0, -128
        sw $t1, 0($t0)		#drew left lip
        addi $t0, $t0, 128
        sw $t1, 0($t0)
        j LOOP5
LOOP5:
        beq $t2, $t9, exit      #terminate when i = 24
UPDATE5: 
        addi $t0, $t0, -4     #we shift where we write by 4 bits
        addi $t2, $t2, 1        #increment our loop variable
        sw $t1, 0($t0)
        j LOOP5
exit:
    li $v0, 10                  # terminate the program gracefully
    # syscall
