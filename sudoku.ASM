data Segment para public 'data'

board  db 1,4,5,2,3,7,6,0,8
       db 6,2,7,1,8,9,3,4,5
       db 8,9,3,5,6,4,1,2,7
       db 2,1,6,4,7,8,9,5,3
       db 3,7,4,9,5,1,8,6,2
       db 5,8,9,3,2,6,4,7,1
       db 4,5,1,8,9,2,7,3,6
       db 9,6,2,7,1,3,5,8,4
       db 7,3,8,6,4,5,2,1,9,'$'

board2 db 0,0,0,0,0,0,0,0,0,10
       db 0,0,0,0,0,0,0,0,0,10
       db 0,0,0,0,0,0,0,0,0,10
       db 0,0,0,0,0,0,0,0,0,10
       db 0,0,0,0,0,0,0,0,0,10
       db 0,0,0,0,0,0,0,0,0,10
       db 0,0,0,0,0,0,0,0,0,10
       db 0,0,0,0,0,0,0,0,0,10
       db 0,0,0,0,0,0,0,0,0,'$'

data Ends

code Segment para public 'code'
.386
Assume CS:code,DS:data
START PROC FAR
push ds
xor ax,ax
push ax
mov ax,data
mov ds,ax

xor ax,ax
push ax
lea si,board ;load board address in si register (0)

L1:
mov al,[si]	;move each element from board array to al

cmp al,'$' ;stop when end of array
jz EN	;print the board if end of array

cmp al,0 ;find blank space
jz L6 ;jumps to l6 if blank space, i.e. 0

inc si ;else increment si
jmp L1 ;read the next entry

L6:
mov cx,09 ;used as a counter for the loop; each 0 entry has one

L2:
inc al ;al previous 0, next value to be checked is 1

call check ;check for validity of number
jc L3 ;jump if carry=1 (number is valid)
jnc L4 ;jump if carry=0 (invalid number)

L3: 
mov [si],al ;valid number, move it to the blank position
push ax ;push supposed number
dec cx ;decrement counter
push cx ;push its counter
mov bx,si
push bx ;push its index
inc si ;move to the next position in array
jmp L1

L4:            ;check for next number if not possible then
                ;bactrack
cmp cx,1 ;loop ending condition
jz L5 ;jump if equal
loop L2 ;if not zero jump to l2, increment si and check other number
L5:
mov ah,0
mov [si],ah ;move 0 to the blank space
Lh:
pop bx ;pop last entry index
lea si,board ;load starting address to si
add si,bx ;compute last entry address
pop cx ;pop its counter
pop ax ;pop last tried value
cmp cx,00 ;compare last blank space counter if equaltasm  to 0
jz Lx ;if 0 we tried all possibilities for this entry
jnz L2 ;else try the next value for this entry
Lx:
mov ah,0 
mov [si],ah ;put 0
jmp Lh ;backtrack to previous entry and try other value

EN:                ;printing the board
mov cx,81
lea si,board
ll:
mov al,[si]
add al,48
mov [si],al
inc si
loop ll
lea di,board2
lea si,board
l22:
mov cx,09
op:
mov al,[si]
mov [di],al
inc si
inc di
loop op
mov al,[di]
inc di
cmp al,'$'
jnz l22
lea si,board2
lea di,board2
mov ah,09
lea dx,board2
int 21h
jmp exit

check proc
push ax ;save ax value; al stores the current element to be checked
mov bx,si ;move current index to bx
push bx ;push current index
push cx ;push counter
xor bx,bx
mov bl,al ;move al in bl, al stores the value to be checked
xor ax,ax
mov ax,si ;move index to ax (si between 0 and 80 for 9x9 matrix)
mov bh,09
div bh ;div ax by bh, ah remainder, al quotient (ah column, al row)
mov bh,ah ;move column number in bh
lea si,board ;reset si to board starting address
mov cx,09
mov ah,00 ;clear column number from ah
mul cx ;multiply al (row number) by 9 to obtain the row starting index
add si,ax ;add result to so
mov ah,bh ;move column number back in ah
xor cx,cx
mov cx,09 ;check 9 entries on row starting at si

L8:	;check if supposed value is on row starting at si
mov bh,[si]
cmp bh,bl
jz L7 ;if value exists on this row, jump to L7
inc si
loop L8
mov al,ah ;move column to al
mov ah,00
lea si,board ;set si to starting address
add si,ax ;add si to al to obtain the starting column index
mov cx,09 ;check 9 entries on column

L10: ;check value on col
mov bh,[si]
cmp bh,bl ;if entry equals to supposed number, jump to exit
jz L7 ;jump to exit
add si,09 ;add 9 to si to jump on the next row
loop L10

xor ax,ax
mov al,bl ;move supposed number in al
pop cx ;pop counter
pop bx ;pop blank space index
push bx
push cx
xor cx,cx
mov bh,al ;move supposed number in bh
mov al,bl ;move blank space index in al
mov bl,27
push ax ;push blank space address
div bl ;divide index with 27 to obtain the row where first element of 3x3 sits
mov ah,00 ;erase the remainder
mul bl ;multiply quotient by 27 to obtain the row where 3x3 starts
pop cx ;pop blank space index
push ax ;push 3x3 starting row
mov ax,cx ;move blank space index in ax
mov bl,09
div bl ;divide by 9 to obtain the remainder, i.e. column where first element of 3x3 is
mov al,ah ;copy the remainder in al
mov ah,00 ;put 0 in ah
mov bl,03
div bl ;obtain coordinates of the element in its corresponding 3x3
mov ah,00 ;erase remainder
mul bl ;multiply row number of the element in 3x3 to obtain the offset for the first element in row
pop cx
add ax,cx ;move the index from first element of the row to first element of 3x3

lea si,board ;reset si to the starting address
add si,ax ;add the location of first element in 3x3 matrix where the blank space is

mov bl,[si] ;checks if the element is valid for the first row in 3x3 matrix
cmp bh,bl
jz L7
inc si ;move to the second element on the first row
mov bl,[si]
cmp bh,bl
jz L7
inc si ;move to the third element on the first row
mov bl,[si]
cmp bh,bl
jz L7

add si,09 ;jump to the second row
mov bl,[si] ;check the third element on the second row
cmp bh,bl
jz L7
dec si ;move to the second element on the second row
mov bl,[si]
cmp bh,bl
jz L7
dec si ;move to the first element on the second row
mov bl,[si]
cmp bh,bl
jz L7

add si,09 ;jump to the third row
mov bl,[si] ;check first
cmp bh,bl
jz L7
inc si ;move to second
mov bl,[si]
cmp bh,bl
jz L7
inc si ;move to third
mov bl,[si]
cmp bh,bl
jz L7

pop cx
pop bx
lea si,board
add si,bx
pop ax
stc ;set carry flag
jmp L11

L7: ;jumps here if no solution found
pop cx ;pop counter value
pop bx ;pop blank space index
lea si,board ;reset si
add si,bx ;move si to index of blank space
pop ax ;pop the current tried value
clc ;clear carry flag

L11:
ret
check Endp

exit:
mov ah,4ch ;exit
int 21h
ret
START ENDP
code Ends
End start
