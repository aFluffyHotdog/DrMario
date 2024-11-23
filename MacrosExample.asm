 Macro:
  #macro exmaple
    .macro push %reg
        sub $sp, $sp, 4
        sw %reg, ($sp)
    .end_macro
    
    .macro pop %reg
        lw %reg, ($sp)
        add $sp, $sp, 4
    .end_macro

.text
li $a0, 42
push $a0
pop $a0

# 