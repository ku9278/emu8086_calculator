;32bit / 16bit
;A(0): si:bp
;Q(dividend): dx:ax
;M(divisor):bx
;cnt: cx
;resuit: quotient:Q, remainder:A

org 100h

mov dx, 04aaah
mov ax, 06da9h
mov si, 00000h
mov bp, 00000h
mov bx, 0000ah

mov cx, 32

divide:
    shl ax, 1
    rcl dx, 1
    rcl bp, 1
    rcl si, 1
    
    push bx
    push bp
    push si
    push si
    
    sub bp, bx    ;(1)
    jnc continue1    ;carry
    dec si
    
    continue1:
    pop bx
    test si, si    ;if A == 0
    jnz continue2
    test bp, bp
    jz success
    
    continue2:
    xor bx, si    ;If the signs of A before and after operation (1) are the same 
    cmp bx, 8000h
    jc success

failure:
    ;Q0:0
    pop si
    pop bp
    pop bx
    loop divide
    jmp endd  

success:
    inc ax    ;Q0:1
    add sp, 4
    pop bx
    loop divide
    jmp endd 

endd:
    ret

end
