org 100h

;A: dx, Q: ax, M:bx, cnt: cx

mov ax, 06da9h
mov bx, 00c38h

mov cx, 16

divide:
    shl ax, 1
    rcl dx, 1
    
    push bx
    push dx
    push dx
    sub dx, bx    ;(1)
    test dx, dx    ;if A == 0
    jz success
    
    pop bx
    xor bx, dx    ;If the signs of A before and after operation (1) are the same 
    cmp bx, 8000h
    jc success

failure:
    ;Q0:0
    pop dx
    pop bx
    loop divide
    jmp endd  

success:
    inc ax    ;Q0:1
    add sp, 2
    pop bx
    loop divide
    jmp endd 

endd:
    ret

end


