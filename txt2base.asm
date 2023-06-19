LOCALS @@
title ""
  .model small
  .386
  .stack 64
  .data
baseDec		equ		0
baseHex		equ		1
baseBin		equ		2

resultadod	db		8 dup(0)
div_base	dw		10d
txtdec      db      "0254"
numdec      dw      ?
numhex      dw      ?
numbin      dw      ?
resultado   dw      0,0
basesel     db      0

diez		dw		10d
  .code
inicio:
    mov     ax,@data
    mov     ds,ax
  
    mov     ax,0FFFFh
    mov     dx,0FFFFh

	; mov		[div_base],16d

	mul		dx
	jnc		res_no_c

res_carry:
	mov		[resultado + 2],ax
	mov		[resultado],dx
	mov		bx,offset resultadod
	call 	NUM2DIGC
	jmp     salida


res_no_c:
	mov		[resultado],ax
	mov		bx,offset resultadod


salida:
  mov    ax,4C00h
  int 21h


NUM2DIGC proc tiny
  	push    bp
  	mov     bp,sp

	push    dx
	mov		cx,4h
	mov		si,8h
@@loop_digitos_ax:
	xor		dx,dx
	div		[div_base]
	mov		[resultadod + si],dl
	dec		si
	loop 	@@loop_digitos_ax

	pop		ax
	push	ax
	mov		cx,2h
@@loop_digitos_dx_1:
	xor		dx,dx
	xor		ah,ah
	div		[div_base]
	mov		[resultadod + si],dl
	dec		si
	loop	@@loop_digitos_dx_1

	pop		ax
	mov		al,ah
	mov		cx,2h
@@loop_digitos_dx_2:
	xor		dx,dx
	xor		ah,ah
	div		[div_base]
	mov		[resultadod + si],dl
	dec		si
	loop	@@loop_digitos_dx_2

  	pop		bp
  	ret
NUM2DIGC endp
  end inicio