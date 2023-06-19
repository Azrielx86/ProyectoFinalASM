LOCALS @@
title ""
  .model small
  .386
  .stack 64
  .data
string    db   "Hola Mundo!",0Ah,0Dh,'$'
  .code
; El número a imprimir estará en ax
print_dec proc tiny
  push    bp
  mov     bp,sp
  mov     bx,10
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
  int 21h
  cmp     bp,sp
  jne     @@loop_imprimir
  mov     dx,000Ah
  int 21h
  add     dx,0003h
  int 21h
  pop     bp
  ret
print_dec endp

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

dec2bin proc tiny
  push    bp
  mov     bp,sp
  xor     cx,cx
  mov     bx,2h
@@loop_digitos:
  xor     dx,dx
  div     bx
  push    dx
  inc     cx
  cmp     ax,0h
  jne     @@loop_digitos
; @loop_espacios:
  xor     dx,dx
  mov     ax,cx
  mov     bx,04h
  div     bx
  mov     cx,dx
  mov     dx,0h
@@loop_espacios:
  push    dx
  loop @@loop_espacios

  xor     cx,cx
  mov     ax,0200h
@@loop_imprimir:
  pop     dx
  or      dx,30h
  int 21h
  inc cx
  cmp     cx,4h
  jl      @@continue_loop
  mov     dx,' '
  xor     cx,cx
  int 21h
@@continue_loop:
  cmp     bp,sp
  jne     @@loop_imprimir

  mov     dx,0Ah
  int 21h
  mov     dx,0Dh
  int 21h
  pop     bp
  ret
dec2bin endp

inicio:
  mov    ax,@data
  mov    ds,ax

  mov    ax,3DACh
  call print_dec

  mov    ax,3DACh
  call dec2hex

  mov    ax,3DACh
  call dec2bin

salida:
  mov    ax,4C00h
  int 21h
  end inicio
