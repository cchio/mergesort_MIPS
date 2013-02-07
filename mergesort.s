 #==============================================================================
# File:         mergesort.s (PA 1)
#
# Description:  Skeleton for assembly mergesort routine. 
#       To complete this assignment, add the following functionality:
#
#       1. Call mergesort. (See mergesort.c)
#          Pass 3 arguments:
#
#          ARG 1: Pointer to the first element of the array
#          (referred to as "nums" in the C code)
#
#          ARG 2: Number of elements in the array
#
#          ARG 3: Temporary array storage
#                 
#          Remember to use the correct CALLING CONVENTIONS !!!
#          Pass all arguments in the conventional way!
#
#       2. Mergesort routine.
#          The routine is recursive by definition, so mergesort MUST 
#          call itself. There are also two helper functions to implement:
#          merge, and arrcpy.
#          Again, make sure that you use the correct calling conventions!
#
#==============================================================================

.data
HOW_MANY:   .asciiz "How many elements to be sorted? "
ENTER_ELEM: .asciiz "Enter next element: "
ANS:        .asciiz "The sorted list is:\n"
SPACE:      .asciiz " "
EOL:        .asciiz "\n"

.text
.globl main

#==========================================================================
main:
#==========================================================================

    #----------------------------------------------------------
    # Register Definitions
    #----------------------------------------------------------
    # $s0 - pointer to the first element of the array
    # $s1 - number of elements in the array
    # $s2 - number of bytes in the array
    # $s3 - pointer to the first element of tempArray
    #----------------------------------------------------------
    
    #---- Store the old values into stack ---------------------
    addiu   $sp, $sp, -32
    sw      $ra, 28($sp)

    #---- Prompt user for array size --------------------------
    li      $v0, 4              # print_string
    la      $a0, HOW_MANY       # "How many elements to be sorted? "
    syscall         
    li      $v0, 5              # read_int
    syscall 
    move    $s1, $v0            # save number of elements

    #---- Create dynamic array --------------------------------
    li      $v0, 9              # sbrk
    sll     $s2, $s1, 2         # number of bytes needed
    move    $a0, $s2            # set up the argument for sbrk
    syscall
    move    $s0, $v0            # the addr of allocated memory

    #---- Prompt user for array elements ----------------------
    addu    $t1, $s0, $s2       # address of end of the array
    move    $t0, $s0            # address of the current element
    j       read_loop_cond

read_loop:
   li      $v0, 4              # print_string
   la      $a0, ENTER_ELEM     # text to be displayed
   syscall
   li      $v0, 5              # read_int
   syscall
   sw      $v0, 0($t0)     
   addiu   $t0, $t0, 4

read_loop_cond:
    bne     $t0, $t1, read_loop

  #---- Allocating memory for tempArray-----------------------
    li      $v0, 9              # sbrk
    move    $a0, $s2            # set up the argument for sbrk
    syscall
    move    $s3, $v0            # the addr of allocated memory


    #---- Call Mergesort ---------------------------------------
    add     $a0, $zero, $s0     # storing int *array as $a0
    add     $a1, $zero, $s1     # storing int n as $a1
    add     $a2, $zero, $s3     # storing int *tempArray as $a2
    jal     mergesort

    #--------ALL THE MERGESORT OPERATIONS GO ON HERE!!----------

    #---- Print sorted array -----------------------------------
    li      $v0, 4              # print_string
    la      $a0, ANS            # "The sorted list is:\n"
    syscall

    #---- For loop to print array elements ----------------------
    
    #---- Iniliazing variables ----------------------------------
    move    $t0, $s0            # address of start of the array
    addu    $t1, $s0, $s2       # address of end of the array
    j       print_loop_cond

print_loop:
    li      $v0, 1              # print_integer
    lw      $a0, 0($t0)         # array[i]
    syscall
    li      $v0, 4              # print_string
    la      $a0, SPACE          # print a space
    syscall            
    addiu   $t0, $t0, 4         # increment array pointer

print_loop_cond:
    bne     $t0, $t1, print_loop

    li      $v0, 4              # print_string
    la      $a0, EOL            # "\n"
    syscall          

    #---- Exit -------------------------------------------------
    lw      $ra, 28($sp)
    addiu   $sp, $sp, 32
    j       $ra


mergesort:
    slti    $t0, $a1, 2             # $t0 = (n < 2)
    beq     $t0, $zero, skip        # if(n < 2) go back to main()
    jr      $ra                     # return
skip:
    addiu   $sp, $sp, -32           # shifting down stack pointer
    sw      $a0, 28($sp)            # save $a0, int *array
    sw      $a1, 24($sp)            # save $a1, int n
    sw      $a2, 20($sp)            # save $a2, int *tempArray
    sw      $ra, 16($sp)            # save $ra
    sw      $fp, 12($sp)            # save $fp
    addiu   $fp, $sp, 28            # set up $fp
    srl     $a1, $a1, 1             # storing n/2 as mid into 2nd argument
    jal     mergesort               # call recursive on first half

    lw      $a0, 28($sp)            # restore $a0, int *array
    lw      $a1, 24($sp)            # restore $a1, int n
    lw      $a2, 20($sp)            # restore $a2, int *tempArray
    srl     $t0, $a1, 1             # storing mid = n/2 into $t0
    sll     $t1, $t0, 2             # multiply mid by 4 (sizeof(int))
    add     $a0, $a0, $t1           # argument 1 set to addr of array+(mid*4)
    sub     $a1, $a1, $t0           # argument 2 set to n - mid
    jal     mergesort               # call recursive on second half

    lw      $a0, 28($sp)            # loading $a0, int *array
    lw      $a1, 24($sp)            # loading $a1, int n
    lw      $a2, 20($sp)            # loading $a2, int *tempArray
    srl     $a3, $a1, 1             # loading mid = n/2 into $a2
    jal     merge 

    lw      $ra, 16($sp)            # restore $ra
    lw      $fp, 12($sp)            # restore $fp
    addiu   $sp, $sp, 32            # pop frame
    jr      $ra                     # return from current instance of mergesort

merge:
    addiu   $sp, $sp, -32           # push frame
    sw      $ra, 28($sp)            # save $ra
    sw      $fp, 24($sp)            # save $fp
    sw      $s0, 20($sp)            # save $s0
    sw      $s1, 16($sp)            # save $s1
    sw      $s2, 12($sp)            # save $s2
    sw      $s3, 8($sp)             # save $s3
    sw      $s4, 4($sp)             # save $s4
    add     $s0, $zero, $zero       # $s0 = tpos = 0 ($s0 actually stores tpos*4)
    add     $s1, $zero, $zero       # $s1 = lpos = 0
    add     $s2, $zero, $zero       # $s2 = rpos = 0
    sub     $s3, $a1, $a3           # $s3 = n - mid = rn
    sll     $s4, $a3, 2             # $s4 = mid*4
    add     $s4, $a0, $s4           # $s4 = &array[mid] = &rarr
    
while_loop:
    slt     $t5, $s1, $a3           # $t5 = lpos < mid
    beq     $t5, $zero after_loop   # if lpos >= mid, goto after_loop (exit loop)
    slt     $t5, $s2, $s3           # $t5 = rpos < rn
    beq     $t5, $zero after_loop   # if rpos >= rn, goto after_loop (exit loop)
    sll     $t5, $s1, 2             # $t5 = lpos*4
    sll     $t6, $s2, 2             # $t6 = rpos*4
    add     $t7, $t5, $a0           # $t7 = &array[lpos]
    add     $t8, $t6, $s4           # $t8 = &rarr[rpos]
    lw      $t7, 0($t7)             # $t7 = array[lpos]
    lw      $t8, 0($t8)             # $t8 = rarr[rpos]
    slt     $t9, $t7, $t8           # $t9 = array[lpos] < rarr[rpos]
    beq     $t9, $zero, else_branch # if array[lpos] >= rarr[rpos] goto else_branch

if_branch:
    add     $t8, $a2, $s0           # $t8 = &tempArray[tpos]
    sw      $t7, 0($t8)             # tempArray[tpos] = array[lpos]
    addi    $s1, $s1, 1             # $s1 = lpos++
    addi    $s0, $s0, 4             # $s0 = tpos + 4
    j       while_loop              # goto next iteration of while loop

else_branch:
    add     $t7, $a2, $s0           # $t7 = &tempArray[tpos]
    sw      $t8, 0($t7)             # tempArray[tpos] = rarr[rpos]
    addi    $s2, $s2, 1             # $s2 = rpos++
    addi    $s0, $s0, 4             # $s0 = tpos + 4
    j       while_loop              # goto next iteration of while loop

after_loop:
    add     $t9, $a0, $zero         # $t9 = &array              (saving arguments)
    add     $t8, $a1, $zero         # $t8 = n                   (saving arguments)
    add     $t7, $a2, $zero         # $t7 = &tempArray          (saving arguments)
    add     $t6, $a3, $zero         # $t6 = mid                 (saving arguments)
    add     $a0, $a2, $s0           # $a0 = &tempArray[tpos]    (loading arguments)
    slt     $t0, $s1, $t6           # $t0 = lpos < mid
    bne     $t0, $zero, lpos_slt_mid# if lpos < mid, goto lpos_slt_mid
next_check:
    slt     $t0, $s2, $s3           # $t0 = rpos < rn
    bne     $t0, $zero, rpos_slt_rn # if rpos < rn, goto rpos_slt_rn
    j       exit_merge              # goto exit_merge
lpos_slt_mid:
    sll     $t0, $s1, 2             # $t0 = lpos*4
    add     $a1, $t9, $t0           # $a1 = array + lpos        (loading arguments)
    sub     $a2, $t6, $s1           # $a2 = mid - lpos          (loading arguments)
    jal     arr_cpy                 # procedure call to ArrCpy
    j       next_check              # go on to check if rpos < rn
rpos_slt_rn:         
    sll     $t0, $s2, 2             # $t0 = rpos*4
    add     $a1, $s4, $t0           # $a1 = rarr + rpos         (loading arguments)
    sub     $a2, $s3, $s2           # $a2 = rn - rpos           (loading arguments)
    jal     arr_cpy                 # procedure call to ArrCpy
    j       exit_merge              # goto exit_merge
exit_merge:
    add     $a0, $t9, $zero         # $a0 = &array              (loading arguments)
    add     $a1, $t7, $zero         # $a1 = &tempArray          (loading arguments)
    add     $a2, $t8, $zero         # $a2 = n                   (loading arguments)
    jal     arr_cpy                 # procedure call to ArrCpy

    lw      $ra, 28($sp)            # load $ra of Mergesort()
    lw      $fp, 24($sp)            # load $fp of Mergesort()
    lw      $s0, 20($sp)            # load $s0
    lw      $s1, 16($sp)            # load $s1
    lw      $s2, 12($sp)            # load $s2
    lw      $s3, 8($sp)             # load $s3
    lw      $s4, 4($sp)             # load $s4
    addiu   $sp, $sp, 32            # pop frame
    jr      $ra                     # exit

arr_cpy:                            # Leaf procedure with no frame
    add     $t0, $zero, $a2         # $t0 = n
    add     $t1, $zero, $zero       # $t1 = i
loop:
    slt     $t2, $t1, $t0           # $t2 = i < n
    beq     $t2, $zero, end         # goto end if i >= n
    sll     $t2, $t1, 2             # $t2 = i*4
    add     $t3, $a1, $t2           # $t3 = &src[i]
    lw      $t4, 0($t3)             # $t4 = src[i]
    add     $t3, $a0, $t2           # $t3 = &dst[i]
    sw      $t4, 0($t3)             # dst[i] = src[i]
    addi    $t1, $t1, 1             # AM I DOING THIS WRONG???
    j       loop                    # jump back to the top
end:
    jr      $ra                     # return
