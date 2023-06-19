title ""
  .model small
  .386
  .stack 64
  .data
  .code
inicio:
  mov    ax,@data
  mov    ds,ax
  
    mov     ax,0FFFFh
    mov     dx,0FFFFh
    mul     dx

    push    ax
    push    dx

    pop     ax
    call    dec2hex

    pop     ax
    call    dec2hex


salida:
  mov    ax,4C00h
  int 21h

dec2hex proc tiny
  push    bp
  mov     bp,sp
  
  mov     bx,16
@@loop_digitos:
  xor     dx,dx
  div     bx
  push    dx
  cmp     ax,0h
  jne     @@loop_digitos

  mov     ax,0200h
@@loop_imprimir:
  pop     dx
  or      dx,30h
  cmp     dx,3Ah
  jl      @@print
  add     dx,07h
@@print:
  int     21h
  cmp     bp,sp
  jne     @@loop_imprimir

  mov     dx,000Ah
  int 21h
  mov     dx,000Dh
  int 21h
  pop     bp
  ret
dec2hex endp

  end inicio