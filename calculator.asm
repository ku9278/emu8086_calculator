;ah: sub_number
;al: input(push)
;bx: num1
;ch: (00:+,+), (10:-,+), (01:+,-), (11:-,-)
;cl: oprator
;dx: num2


DIVISION MACRO
    LOCAL divide, failure, success, endd
    
    ;32bit / 16bit
    ;A(0): di:si
    ;Q(dividend): dx:ax
    ;M(divisor):bx
    ;cnt: cx
    ;resuit: quotient:Q, remainder:A
    
    
    ;dx, ax, bx
    mov di, 00000h
    mov si, 00000h
    
    mov cx, 32
    
    
    divide:
        shl ax, 1
        rcl dx, 1
        rcl si, 1
        rcl di, 1
        
        push bx
        push si
        push di
        push di
        
        sub si, bx    ;(1)
        jnc continue1    ;carry
        dec di
        
        continue1:
        pop bx
        test di, di    ;if A == 0
        jnz continue2
        test si, si
        jz success
        
        continue2:
        xor bx, di    ;If the signs of A before and after operation (1) are the same 
        cmp bx, 8000h
        jc success
    
    
    failure:
        ;Q0:0
        pop di
        pop si
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
    
DIVISION ENDM


org 100h

CRLF DB 0Dh,0Ah,'$'    ;Line Wrapping


start:
    mov bp, 0fffch
    mov ax, 0100h
    mov bx, 0000h
    mov cx, 0000h
    mov dx, 0000h


input:
    mov ah, 01h
    int 21h
    cmp al, 08h    ;if(al == 08(ASCII backspace))
    je backspace
    cmp al, 1bh   ;Press Esc to exit
    je ending


input_push:
    push ax
    cmp al, 3dh    ;if(al == 3d(ASCII =))
    je check_minus_1
    jmp input
    
    
backspace:
    cmp sp, 0fffeh            ;checks if te user didnt just BackSpaced nothing
    jz input
    
    mov ah, 02h         ; DOS Display character call 
    mov dl, 20h         ; A space to clear old character 
    int 21h             ; Display it  
    mov dl, 08h         ; Another backspace character to move cursor back again
    int 21h             ; Display it
      
    pop ax
    jmp input
       
       
check_minus_1:
    mov ax, [bp]
    cmp bp, sp    
    je error    ;exception_handling_4
    
    cmp al, 2dh    ;if(al == 2d(ASCII -)) 
    je minus_1
     
     
check_num1:
    mov ax, [bp]
    cmp bp, sp    
    je error    ;exception_handling_4
    cmp al, 30h    ;if(al < 30(ASCII 0)) jmp op_check
    jc check_op
    cmp al, 40h    ;if(al >= 40(ASCII :)) jmp error
    jnc error    ;exception_handling_1
    
    push ax    ;bx * a + al
    mov ax, bx
    mov bx, 000ah
    mul bx
    jc error    ;exception_handling_5
    cmp ax, 8000h
    jnc error    ;exception_handling_5
    mov bx, ax
    pop ax
    mov ah, 00h
    sub al, 30h
    add bx, ax
    jc error    ;exception_handling_5
    cmp bx, 8000h
    jnc error    ;exception_handling_5
        
    sub bp, 2
    jmp check_num1


check_op:
    cmp al, 2bh    ;+
    je save_op
    cmp al, 2dh    ;-
    je save_op
    cmp al, 2ah    ;*
    je save_op
    cmp al, 2fh    ;/
    je save_op
    jmp error    ;exception_handling_1

     
save_op:
    mov cl, al
    
    sub bp, 2


check_minus_2:
    mov ax, [bp]
    cmp bp, sp    
    je error    ;exception_handling_4
    
    cmp al, 2dh    ;if(a == 2d(ASCII -)) 
    je minus_2
     
     
check_num2:            
    mov ax, [bp]
    cmp bp, sp
    je output
    cmp al, 30h    ;if(al < 30(ASCII 0)) jmp op_check
    jc error    ;exception_handling_2,4
    cmp al, 40h    ;if(al >= 40(ASCII :)) jmp error
    jnc error    ;exception_handling_1
    
    push ax    ;bx * a + al
    mov ax, dx
    mov dx, 000ah
    mul dx
    jc error    ;exception_handling_5
    cmp ax, 8000h
    jnc error    ;exception_handling_5
    mov dx, ax
    pop ax
    mov ah, 00h
    sub al, 30h
    add dx, ax
    jc error    ;exception_handling_5
    cmp dx, 8000h
    jnc error    ;exception_handling_5
     
    sub bp, 2 
    jmp check_num2


minus_1:
    add ch, 10h
    
    sub bp, 2
    jmp check_num1


minus_2:
    add ch, 01h
    
    sub bp, 2
    jmp check_num2
           
           
error:
    ;Line Wrapping
    lea dx, CRLF
    mov ah, 09h
    int 21h
   
    mov ah, 0eh
    mov al, 'E'
    int 10h 
    
    ;Line Wrapping
    lea dx, CRLF
    mov ah, 09h
    int 21h
    
    mov sp, 0fffeh
    jmp start


output:
    mov sp, 0fffeh
    
    push bx
    push cx
    push dx
    
    ;Line Wrapping
    lea dx, CRLF
    mov ah, 09h
    int 21h
    
    call CAL
    add sp, 6
    
    ;Line Wrapping
    lea dx, CRLF
    mov ah, 09h
    int 21h
    
    jmp start 


ending:
    mov sp, 0fffeh
    ret


;ax: num1, bh: minus, bl: operator, cx: num2
CAL PROC
    
    mov bp, sp
    
    push ax
    push bx
    push cx
    push dx
    
    mov ax, [bp+6]    ;num1
    mov bx, [bp+4]    ;minus. operator
    mov cx, [bp+2]    ;num2
    mov dx, 0000h
     
     
    num1_munus:
        cmp bh, 10h    ;
        jc num2_minus
        neg ax
        
        cmp bl, 2fh    ;16bit idiv
        jne num2_minus        
        mov dx, 0ffffh
    
    
    num2_minus:
        push ax
        cmp bh, 01h    ;
        lahf    ;load flags into ah(SF:ZF:0:AF:0:PF:1:CF)
        test ah, 10h
        pop ax
        jnz operator 
        neg cx
    
    
    operator:
        cmp bl, 2bh
        je func_add
        cmp bl, 2dh
        je func_sub
        cmp bl, 2ah
        je func_mul
        cmp bl, 2fh
        je func_div
    
    
    func_add:        
        add ax, cx
        
        test bh, bh
        jz print    ;if(bh == 00)
        jnp check_add_minus    ;if(bh == 01 or bh == 10)    

        add_minus: 
            neg ax
            push ax    ;print("-")
            mov ah, 0eh
            mov al, '-'
            int 10h
            pop ax                
            jmp print
        
        check_add_minus:
            cmp ax, 8000h
            jc print
            jmp add_minus
    
                        
    func_sub:
        sub ax, cx
        
        cmp bh, 01    ;if(bh == 01), pos - neg
        jz print
        test bh, bh    ;if(bh == 00 or bh == 11)
        jp check_sub_minus
        
        sub_minus: 
            neg ax
            push ax    ;print("-")
            mov ah, 0eh
            mov al, '-'
            int 10h
            pop ax                
            jmp print
        
        check_sub_minus:
            cmp ax, 8000h
            jc print
            jmp sub_minus
    
                
    func_mul:
        imul cx
        jmp mul_print
        
        
    func_div:
        test cx, cx    ;if(cx == 0)
        je cal_error    ;exception_handling_3
        
        idiv cx
        jmp div_print
    
    
    cal_error:
        mov ah, 0eh
        mov al, 'E'
        int 10h
        
        jmp return    
    
    
    mul_print:
        mov bx, 0ah
        
        cmp dx, 08000h            
        jc mul_digit    ;if(dx:ax < 0) NEG
        neg dx
        dec dx
        neg ax
        
        push ax    ;print("-")
        mov ah, 0eh
        mov al, '-'
        int 10h
        pop ax
        
        mul_digit:
            DIVISION    ;result / 0ah(10)
            push si    ;remainder(digit)
            test dx, dx
            jnz mul_digit
            test ax, ax    ;if(ax == 0)
            jnz mul_digit
        
        sub bp, 8
        
        mul_printing:
            pop ax
            mov ah, 0eh
            add al, 30h
            int 10h
            cmp sp, bp
            jnz mul_printing
            
        add bp, 8        
        
        jmp return             
     
     
    div_print:    ;ax: quotient, dx: remainder
        mov bx, 0ah
        
        push dx
        mov dx, 0000h
        push ax
        
        
        ;Q     
        mov ah, 0eh
        mov al, 'Q'
        int 10h
        mov al, ':'
        int 10h
        
        pop ax    ;quotient
        
        cmp ax, 08000h  
        jc q_digit    ;if(dx:ax < 0) NEG
        neg ax
        
        push ax    ;print("-")
        mov ah, 0eh
        mov al, '-'
        int 10h
        pop ax
        
        q_digit:
            div bx    ;result / 0ah(10)
            push dx    ;remainder(digit)
            mov dx, 0000h
            test ax, ax    ;if(ax == 0)
            jnz q_digit
            
        sub bp, 10
        
        q_printing:
            pop ax
            mov ah, 0eh
            add al, 30h
            int 10h
            cmp sp, bp
            jnz q_printing
            
        add bp, 10
        
        
        ;R
        mov ah, 0eh 
        mov al, 20h    ;space
        int 10h
        mov al, 'R'
        int 10h
        mov al, ':'
        int 10h
        
        pop ax    ;remainder
        
        cmp ax, 08000h  
        jc r_digit    ;if(dx:ax < 0) NEG
        neg ax
        
        push ax    ;print("-")
        mov ah, 0eh
        mov al, '-'
        int 10h
        pop ax
        
        r_digit:
            div bx    ;result / 0ah(10)
            push dx    ;remainder(digit)
            mov dx, 0000h
            test ax, ax    ;if(ax == 0)
            jnz r_digit
            
        sub bp, 8
        
        r_printing:
            pop ax
            mov ah, 0eh
            add al, 30h
            int 10h
            cmp sp, bp
            jnz r_printing
                
        add bp, 8
        
        jmp return       
    
    
    print:
        mov bx, 0ah
        
        digit:
            div bx    ;result / 0ah(10)
            push dx    ;remainder
            mov dx, 0000h
            test ax, ax    ;if(ax == 0)
            jnz digit
            
        sub bp, 8
        
        printing:
            pop ax
            mov ah, 0eh
            add al, 30h
            int 10h
            cmp sp, bp
            jnz printing
            
        add bp, 8
     
    return:
        pop dx
        pop cx
        pop bx
        pop ax
        
        mov sp, bp
        
        ret
    
CAL ENDP


end

