; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt
; https://bluefallsky.tistory.com/entry/%EC%96%B4%EC%85%88%EB%B8%94%EB%A6%AC%EC%96%B4-INT-21h-%EC%A0%95%EB%A6%AC


; a +-*/ b = ?
org 100h

CRLF DB 0Dh,0Ah,'$'    ;Line Wrapping

start:
;input a
mov ah, 01h 
int 21h
cmp al, 0dh   ;Press Enter to exit
je ending
mov ah, 00h
sub al, 30h
push ax

;input +-*/
mov ah, 01h 
int 21h
mov ah, 00h
push ax

;input b
mov ah, 01h 
int 21h
mov ah, 00h
sub al, 30h
push ax

;Line Wrapping
lea dx, CRLF
mov ah, 09h
int 21h

call CAL
add sp, 6
lea dx, CRLF    ;Line Wrapping
mov ah, 09h
int 21h
jmp start

ending:
ret
   

CAL PROC
    
    mov bp, sp
    
    push ax
    push bx
    push cx
    push dx
    
    mov ax, [bp+6]    ;a
    mov bx, [bp+4]    ;+-*/
    mov cx, [bp+2]    ;b
    mov dx, 0000h   

    cmp ax, 00h
    jc error    ;if(ax < 0) error
    cmp ax, 10h
    jnc error    ;if(ax >= 10) error

    cmp cx, 00h
    jc error    ;if(cx < 0) error
    cmp cx, 10h
    jnc error    ;if(cx >= 10) error
    
    cmp bx, 2bh
    je f_add
    cmp bx, 2dh
    je f_sub
    cmp bx, 2ah
    je f_mul
    cmp bx, 2fh
    je f_div
    jmp error    ;if(bx != +-*/) error
    
    f_add:
    add al, cl
    jmp print
    
    f_sub:
    sub al, cl
    jmp print
    
    f_mul:
    mul cl
    jmp print
    
    f_div:    ;(16bit div)
    test cx, cx    ;if(cx == 0) error(divide by zoro)
    je error
    div cx
    jmp div_print
    
    error:
    mov ah, 0eh
    mov al, 'E'
    int 10h
    jmp cal_ending
    
    div_print:    ;ax: quotient, dx: remainder
    push dx
    push ax     
    mov ah, 0eh
    mov al, 'Q'
    int 10h
    mov al, ':'
    int 10h
    pop ax    ;quotient
    mov ah, 0eh
    add al, 30h    
    int 10h
    mov al, 20h    ;space
    int 10h
    mov al, 'R'
    int 10h
    mov al, ':'
    int 10h
    pop ax    ;remainder
    mov ah, 0eh
    add al, 30h    
    int 10h
    jmp cal_ending
      
    print:
    ;single digit calculate
    ;The result is up to double digits
    ;convert to ASCII by digit
    jns not_neg    ;if(sf == 1) NEG
    neg al
    push ax    ;print("-")
    mov ah, 0eh
    mov al, '-'
    int 10h
    pop ax
    
    not_neg:
    mov bx, 0ah
    div bx    ;result / 10 (16bit div)
    push dx    ;remainder(units)
    push ax    ;quotient(tens)
    
    pop ax    ;tens
    mov ah, 0eh
    add al, 30h
    int 10h
           
    pop ax    ;units
    mov ah, 0eh
    add al, 30h
    int 10h

    cal_ending:
    pop dx    
    pop cx
    pop bx
    pop ax
    
    mov sp, bp
    
    ret
    
CAL ENDP

   
end