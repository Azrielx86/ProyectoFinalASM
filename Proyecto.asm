LOCALS @@
title "EyPC 2023-II Grupo 2 Proyecto - Base"
	.model small
	.386
	.stack 64
;Macros
;clear - Limpia pantalla
clear macro
	mov ax,0003h 	;ah = 00h, selecciona modo video
					;al = 03h. Modo texto, 16 colores
	int 10h		;llama interrupcion 10h con opcion 00h. 
				;Establece modo de video limpiando pantalla
endm
;posiciona_cursor - Cambia la posición del cursor a la especificada con 'renglon' y 'columna' 
posiciona_cursor macro renglon,columna
	mov dh,renglon	;dh = renglon
	mov dl,columna	;dl = columna
	mov bx,0
	mov ax,0200h 	;preparar ax para interrupcion, opcion 02h
	int 10h 		;interrupcion 10h y opcion 02h. Cambia posicion del cursor
endm 
;inicializa_ds - Inicializa el valor del registro DS
inicializa_ds 	macro
	mov ax,@data
	mov ds,ax
endm
;muestra_cursor_mouse - Establece la visibilidad del cursor del mouser
muestra_cursor_mouse	macro
	mov ax,1		;opcion 0001h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm
;oculta_cursor_teclado - Oculta la visibilidad del cursor del teclado
oculta_cursor_teclado	macro
	mov ah,01h 		;Opcion 01h
	mov cx,2607h 	;Parametro necesario para ocultar cursor
	int 10h 		;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm
;apaga_cursor_parpadeo - Deshabilita el parpadeo del cursor cuando se imprimen caracteres con fondo de color
;Habilita 16 colores de fondo
apaga_cursor_parpadeo	macro
	mov ax,1003h 		;Opcion 1003h
	xor bl,bl 			;BL = 0, parámetro para int 10h opción 1003h
  	int 10h 			;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm
;imprime_caracter_color - Imprime un caracter de cierto color en pantalla especificado por 'caracter' y 'color'. Los colores disponibles están en la lista a continuacion;
; Colores:
; 00h: Negro
; 01h: Azul
; 02h: Verde
; 03h: Cyan
; 04h: Rojo
; 05h: Magenta
; 06h: Cafe
; 07h: Gris Claro
; 08h: Gris Oscuro
; 09h: Azul Claro
; 0Ah: Verde Claro
; 0Bh: Cyan Claro
; 0Ch: Rojo Claro
; 0Dh: Magenta Claro
; 0Eh: Amarillo
; 0Fh: Blanco
; utiliza int 10h opcion 09h
imprime_caracter_color macro caracter,bg_color,color
	mov ah,09h				;preparar AH para interrupcion, opcion 09h
	mov al,caracter 		;DL = caracter a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,bg_color         ;BL (4 bits mas significativos) = color de fondo del caracter
    xor bl,color 	    	;BL (4 bits menos significativos) = color del caracter
    
	mov cx,1				;CX = numero de veces que se imprime el caracter
							;CX es un argumento necesario para opcion 09h de int 10h
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm
;lee_mouse - Revisa el estado del mouse
;Devuelve:
;;BX - estado de los botones
;;;Si BX = 0000h, ningun boton presionado
;;;Si BX = 0001h, boton izquierdo presionado
;;;Si BX = 0002h, boton derecho presionado
;;;Si BX = 0003h, boton izquierdo y derecho presionados
; (400,120) => 80x25 =>Columna: 400 x 80 / 640 = 50; Renglon: (120 x 25 / 200) = 15 => 50,15
;;CX - columna en la que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;;DX - renglon en el que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
lee_mouse	macro
	mov ax,0003h
	int 33h
endm
;comprueba_mouse - Revisa si el driver del mouse existe
comprueba_mouse 	macro
	mov ax,0		;opcion 0
	int 33h			;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
					;Si AX = 0000h, no existe el driver. Si AX = FFFFh, existe driver
endm
	.data
;Constantes de colores de modo de video
cNegro 			equ		00h
cAzul 			equ		01h
cVerde 			equ 	02h
cCyan 			equ 	03h
cRojo 			equ 	04h
cMagenta 		equ		05h
cCafe 			equ 	06h
cGrisClaro		equ		07h
cGrisOscuro		equ		08h
cAzulClaro		equ		09h
cVerdeClaro		equ		0Ah
cCyanClaro		equ		0Bh
cRojoClaro		equ		0Ch
cMagentaClaro	equ		0Dh
cAmarillo 		equ		0Eh
cBlanco 		equ		0Fh
;Valores de color para fondo de carácter
bgNegro 		equ		00h
bgAzul 			equ		10h
bgVerde 		equ 	20h
bgCyan 			equ 	30h
bgRojo 			equ 	40h
bgMagenta 		equ		50h
bgCafe 			equ 	60h
bgGrisClaro		equ		70h
bgGrisOscuro	equ		80h
bgAzulClaro		equ		90h
bgVerdeClaro	equ		0A0h
bgCyanClaro		equ		0B0h
bgRojoClaro		equ		0C0h
bgMagentaClaro	equ		0D0h
bgAmarillo 		equ		0E0h
bgBlanco 		equ		0F0h

digitos		equ		4

baseDec		equ		0
baseHex		equ		1
baseBin		equ		2

resultado	dw		0,0 			;resultado es un arreglo de 2 datos tipo word
									;el primer dato [resultado] puede guardar el contenido del resultado para la suma, resta, cociente de division o residuo de division
									;el segundo dato [resultado+2], en conjunto con [resultado] pueden almacenar la multiplicacion de dos numeros de 16 bits
bf_result	db 		digitos*2 dup(0)    ; Buffer para los dígitos del resultado
num1 		db 		digitos dup(0) 		; primer numero, en cada localidad guarda 1 digito, puede ser hasta 4 digitos
num2 		db 		digitos dup(0)		; segundo numero, en cada localidad guarda 1 digito, puede ser hasta 4 digitos
num1h		dw		0                   ; Valor numérico de los caracteres de num1
num2h		dw		0                   ; Valor numérico de los caracteres de num2
conta1 		dw 		0
conta2 		dw 		0
operador 	db 		0       ; Variable para almacenar el operador utilizado en la operación
num_boton 	db 		0
num_impr 	db 		0       ; Variable temporal para imprimir el carácter
baseSel		db		0		; Variable para guardar la base seleccionada

;Auxiliares para calculo de digitos de un numero decimal de hasta 5 digitos
diezmil		dw		10000d
mil			dw		1000d
cien 		dw 		100d
diez		dw		10d
dhex		dw		16d
dbin        dw		2d
;Auxiliar para calculo de coordenadas del mouse
ocho		db 		8
;Cuando el driver del mouse no esta disponible
no_mouse		db 	'No se encuentra driver de mouse. Presione [enter] para salir$'
error_zero      db  0ADh,"Divisi",0A2h,"n entre cero! [Enter para continuar]$"
ez_len          equ $ - error_zero

;MARCO PRINCIPAL DE LA INTERFAZ GRAFICA
;Caracteres del marco superior
;columnas		000,	001		002		003		004		005		006		007		008		009		010		011		012		013		014		015		016		017		018		019		020		021		022		023		024		025		026		027		028		029		030		031		032		033		034		035		036		037		038		039		040		041		042		043		044		045		046		047		048		049		050		051		052		053		054		055		056		057		058		059		060		061		062		063		064		065		066		067		068		069		070		071		072		073		074		075		076		077		078		079
marco_sup	db	201,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	'C',	'A',	'L',	'C',	'U',	'L',	'A',	'D',	'O',	'R',	'A',	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	'[',	'X',	']',	187
;Caracter del marco lateral
marco_lat	db	186
;Caracteres del marco inferior
marco_inf	db	200,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	188

;MARCO DE LA CALCULADORA
;Caracteres del marco superior
;					000,	001		002		003		004		005		006		007		008		009		010		011		012		013		014		015		016		017		018		019		020		021		022		023		024		025		026		027		028		029		030		031		032		033		034		035		036		037		038		039		040		041		042		043		044		045		046		047		048		049
marco_sup_cal	db	201,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	187
;Caracter del marco lateral
marco_lat_cal	db	186
;Caracter del marco de cruce superior
marco_csup_cal	db	203
;Caracter del marco de cruce inferior
marco_cinf_cal	db	202
;Caracter del marco de cruce izquierdo
marco_cizq_cal	db	204
;Caracter del marco de cruce derecho
marco_cder_cal	db	185
;Caracteres del marco inferior
marco_inf_cal	db	200,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	188
;Caracter del marco horizontal interno
marco_hint_cal	db	205
;Caracter del marco vertical interno
marco_vint_cal	db	186

;MARCO DE BOTON
;Caracteres del marco superior
;					000,	001		002		003		004
marco_sup_bot	db	218,	196,	196,	196,	191
;Caracter del marco lateral
marco_lat_bot	db	179
;Caracteres del marco inferior
marco_inf_bot	db	192,	196,	196,	196,	217

;Variables que sirven de parametros para el procedimiento IMPRIME_BOTON
boton_caracter 	            db 		0
boton_renglon 	            db 		0
boton_columna 	            db 		0
boton_color		            db 		0
boton_caracter_color		db 		0

;Variables tipo byte auxiliares cuando se manejan renglones y columnas dentro de la pantalla
ren_aux 		db 		0
col_aux			db 		0

	.code
inicio:
	inicializa_ds
	comprueba_mouse		;macro para revisar driver de mouse
	xor ax,0FFFFh		;compara el valor de AX con FFFFh, si el resultado es zero, entonces existe el driver de mouse
	jz imprime_ui		;Si existe el driver del mouse, entonces salta a 'imprime_ui'
	;Si no existe el driver del mouse entonces se ejecutan las siguientes instrucciones
	lea dx,[no_mouse]
	mov ax,0900h	;opcion 9 para interrupcion 21h
	int 21h			;interrupcion 21h. Imprime cadena.
	jmp teclado		;salta a 'teclado'
imprime_ui:
	clear 					;limpia pantalla
	oculta_cursor_teclado	;oculta cursor del mouse
	apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
	call MARCO_UI 			;procedimiento que dibuja marco de la interfaz
	call CALCULADORA_UI 	;procedimiento que dibuja la calculadora dentro de la interfaz
	muestra_cursor_mouse 	;hace visible el cursor del mouse
;Revisar que el boton izquierdo del mouse no este presionado
;Si el boton no esta suelto no continua
mouse_no_clic:
	lee_mouse
	test bx,0001h
	jnz mouse_no_clic
;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
mouse:
	lee_mouse
	test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
	jz mouse 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse
	
	;Leer la posicion del mouse y hacer la conversion a resolucion
	;80x25 (columnas x renglones) en modo texto
	mov ax,dx 			;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
	div [ocho] 			;Division de 8 bits
						;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov dx,ax 			;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)
	

	mov ax,cx 			;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
	div [ocho] 			;Division de 8 bits
						;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov cx,ax 			;Copia AX en CX. AX es un valor entre 0 y 79 (columna)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Aqui va la lógica de la posicion del mouse;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Si el mouse fue presionado en el renglon 0
	;se va a revisar si fue dentro del boton [X]
	cmp dx,0
	je botonX
	;Si el mouse fue presionado antes del renglon 7
	;no hay nada que revisar
	cmp dx,7
	jb mouse_no_clic
	;Si el mouse fue presionado despues del renglon 21
	;no hay nada que revisar
	cmp dx,21
	jg mouse_no_clic
	;Si el mouse fue presionado antes de la columna 17
	;no hay nada que revisar
	cmp cx,17
	jb mouse_no_clic
	;Si el mouse fue presionado despues de la columna 62
	;no hay nada que revisar
	cmp cx,62
	jg mouse_no_clic

	;Si el mouse fue presionado antes de la columna 21 y despues de la 17
	;es posible se haya presionado en un boton de base numerica
	cmp cx,21
	jbe botones_base_num

	;Si el mouse fue presionado antes de la columna 24 y despues de la 21
	;se presiono en un espacio vacio
	cmp cx,24
	jb jmp_mouse_no_clic

	;Si el mouse fue presionado antes o dentro de la columna 28 y despues de la 24
	;revisar si fue dentro de un boton
	;Botones entre columnas 24 y 28: '7', '4', '1', 'C'
	cmp cx,28
	jbe botones_7_4_1_0

	; Segunda columna
	cmp cx,30
	jb jmp_mouse_no_clic

	cmp cx,34
	jbe botones_8_5_2_A

	; Tercer columna
	cmp cx,36
	jb jmp_mouse_no_clic

	cmp cx,40
	jbe botones_9_6_3_B

	; Cuarta columna
	cmp cx,42
	jb jmp_mouse_no_clic

	cmp cx,46
	jbe botones_F_E_D_C

	; Quinta columna
	cmp cx,51
	jb jmp_mouse_no_clic

	cmp cx,55
	jbe botones_SUM_MUL_MOD

	; Sexta columna
	cmp cx,57
	jb jmp_mouse_no_clic

	cmp cx,62
	jbe botones_MIN_DIV_EQU

jmp_mouse_no_clic:
	jmp mouse_no_clic

botones_base_num:
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'Dec'
	cmp dx,9
	jbe botonDec
	cmp dx,10
	je mouse_no_clic

	cmp dx,13
	jbe botonHex
	cmp dx,14
	je mouse_no_clic

	cmp dx,17
	jbe botonBin

	cmp dx,18
	je mouse_no_clic

botones_7_4_1_0:
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '7'
	cmp dx,9
	jbe boton7

	;renglon 12 es espacio vacio
	cmp dx,10
	je mouse_no_clic

	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '4'
	cmp dx,13
	jbe boton4

	;renglon 16 es espacio vacio
	cmp dx,14
	je mouse_no_clic

	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '1'
	cmp dx,17
	jbe boton1

	;renglon 20 es espacio vacio
	cmp dx,18
	je mouse_no_clic

	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '0'
	cmp dx,21
	jbe boton0
	
	;Si no es ninguno de los anteriores
	jmp mouse_no_clic

; | Agregados los demás botones
botones_8_5_2_A:
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '8'
	cmp dx,9
	jbe boton8
	;renglon 12 es espacio vacio
	cmp dx,10
	je mouse_no_clic
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '5'
	cmp dx,13
	jbe boton5
	;renglon 16 es espacio vacio
	cmp dx,14
	je mouse_no_clic
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '2'
	cmp dx,17
	jbe boton2
	;renglon 20 es espacio vacio
	cmp dx,18
	je mouse_no_clic
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'A'
	cmp dx,21
	jbe botonA

botones_9_6_3_B:
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '9'
	cmp dx,9
	jbe boton9
	;renglon 12 es espacio vacio
	cmp dx,10
	je mouse_no_clic
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '6'
	cmp dx,13
	jbe boton6
	;renglon 16 es espacio vacio
	cmp dx,14
	je mouse_no_clic
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '3'
	cmp dx,17
	jbe boton3
	;renglon 20 es espacio vacio
	cmp dx,18
	je mouse_no_clic
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'B'
	cmp dx,21
	jbe botonB

botones_F_E_D_C:
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'F'
	cmp dx,9
	jbe botonF
	;renglon 12 es espacio vacio
	cmp dx,10
	je mouse_no_clic
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'E'
	cmp dx,13
	jbe botonE
	;renglon 16 es espacio vacio
	cmp dx,14
	je mouse_no_clic
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'D'
	cmp dx,17
	jbe botonD
	;renglon 20 es espacio vacio
	cmp dx,18
	je mouse_no_clic
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'C'
	cmp dx,21
	jbe botonC

botones_SUM_MUL_MOD:
;renglon es espacio vacio
	cmp dx,8
	jbe mouse_no_clic
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'F'
	cmp dx,11
	jbe botonSuma
	;renglon es espacio vacio
	cmp dx,12
	je mouse_no_clic
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'E'
	cmp dx,15
	jbe botonMult
;renglon es espacio vacio
	cmp dx,16
	je mouse_no_clic
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'D'
	cmp dx,19
	jbe botonDivR

botones_MIN_DIV_EQU:
;renglon es espacio vacio
	cmp dx,8
	jbe mouse_no_clic
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'F'
	cmp dx,11
	jbe botonResta
;renglon es espacio vacio
	cmp dx,12
	je mouse_no_clic
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'E'
	cmp dx,15
	jbe botonDivC
;renglon es espacio vacio
	cmp dx,16
	je mouse_no_clic
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'D'
	cmp dx,19
	jbe botonIgual

	;Si no es ninguno de los anteriores
	jmp mouse_no_clic
;Dependiendo la posicion del mouse
;se salta a la seccion correspondiente
botonX:
	jmp botonX_1
boton0:
    jmp boton0_1
boton1:
    jmp boton1_1

;===============================================================================;
; Para los botones del 2 al 9, se comprueba primero en qué base está, ya que    ;
; pueden ser tanto decimales como hexadecimales. Primero se comprueba si está   ;
; en base decimal, en caso de que no esté la selección en decimal, se puede     ;
; asumir que tampoco está en hexadecimal, por lo que directamente pasa a ser    ;
; un boton deshabilitado.                                                       ;
; Si no está seleccionado el modo decimal, se procede a hacer una segunda       ;
; comparación, verificando si se está en modo decimal, en caso de que no        ;
; esté en modo decimal, directamtente pasa a ser un botón deshabilitado.        ;
;===============================================================================;
boton2:
    cmp [baseSel],baseHex
    je boton2_is_enabled
    cmp [baseSel],baseDec
    jne mouse_no_clic
boton2_is_enabled:
    jmp boton2_1

boton3:
    cmp [baseSel],baseHex
    je boton3_is_enabled
    cmp [baseSel],baseDec
    jne mouse_no_clic
boton3_is_enabled:
    jmp boton3_1

boton4:
    cmp [baseSel],baseHex
    je boton4_is_enabled
    cmp [baseSel],baseDec
    jne mouse_no_clic
boton4_is_enabled:
    jmp boton4_1

boton5:
    cmp [baseSel],baseHex
    je boton5_is_enabled
    cmp [baseSel],baseDec
    jne mouse_no_clic
boton5_is_enabled:
    jmp boton5_1

boton6:
    cmp [baseSel],baseHex
    je boton6_is_enabled
    cmp [baseSel],baseDec
    jne mouse_no_clic
boton6_is_enabled:
    jmp boton6_1

boton7:
    cmp [baseSel],baseHex
    je boton7_is_enabled
    cmp [baseSel],baseDec
    jne mouse_no_clic
boton7_is_enabled:
    jmp boton7_1

boton8:
    cmp [baseSel],baseHex
    je boton8_is_enabled
    cmp [baseSel],baseDec
    jne mouse_no_clic
boton8_is_enabled:
    jmp boton8_1
	
boton9:
	cmp [baseSel],baseHex
	je boton9_is_enabled
	cmp [baseSel],baseDec
	jne mouse_no_clic
boton9_is_enabled:
    jmp boton9_1

;===============================================================================;
; En el caso de los botones para hexadecimal (A-F), únicamente se comprueba si  ;
; está seleccionado el modo hexadecimal, en caso de que no esté seleccionado,   ;
; omite los clicks, ya que son botones deshabilitados.                          ;
;===============================================================================;
botonA:
	cmp [baseSel],baseHex
	jne	mouse_no_clic
    jmp botonA_1
botonB:
	cmp [baseSel],baseHex
	jne	mouse_no_clic
    jmp botonB_1
botonC:
	cmp [baseSel],baseHex
	jne	mouse_no_clic
    jmp botonC_1
botonD:
	cmp [baseSel],baseHex
	jne	mouse_no_clic
    jmp botonD_1
botonE:
	cmp [baseSel],baseHex
	jne	mouse_no_clic
    jmp botonE_1
botonF:
	cmp [baseSel],baseHex
	jne	mouse_no_clic
    jmp botonF_1
;===============================================================================;
; Para los botones de operaciones, únicamente se pasa el evento del click a     ;
; la etiqueta correspondiente.                                                  ;
;===============================================================================;
botonSuma:
	jmp botonSuma_1
botonResta:
	jmp botonResta_1
botonMult:
	jmp botonMult_1
botonDivC:
	jmp	botonDivC_1
botonDivR:
	jmp	botonDivR_1
botonIgual:
	jmp	botonIgual_1

;===============================================================================;
; Para cambiar de base, se han agregado cuatro constantes para cada base, como  ;
; están declaradas en la sección de datos, estas corresponden a:                ;
; 0 - Base Decimal                                                              ;
; 1 - Base Hexadecimal                                                          ;
; 2 - Base Binaria                                                              ;
; Además, se agregó una variable "baseSel", la cual corresponde a la base       ;
; seleccionada, esta variable únicamente cambia en esta sección del código.     ;
; Una vez seleccionada la base, se limpia la pantalla de la calculadora, y se   ;
; marca el botón (o modo) seleccionado.                                         ;
;===============================================================================;
botonDec:
	mov			[baseSel],baseDec
	call 		LIMPIA_PANTALLA_CALC
	jmp 		mouse_no_clic
botonHex:
	mov			[baseSel],baseHex
	call 		LIMPIA_PANTALLA_CALC
	jmp 		mouse_no_clic
botonBin:
	mov			[baseSel],baseBin
	call 		LIMPIA_PANTALLA_CALC
	jmp 		mouse_no_clic
;Logica para revisar si el mouse fue presionado en [X]
;[X] se encuentra en renglon 0 y entre columnas 76 y 79
botonX_1:
	cmp cx,76
	jge botonX_2
	jmp mouse_no_clic
botonX_2:
	cmp cx,78
	jbe botonX_3
	jmp mouse_no_clic
botonX_3:
	;Se cumplieron todas las condiciones
	jmp salir

;===============================================================================;
; Cada que se presiona un botón, la variable "num_botón" toma el valor de este  ;
; y se va directamente a la etiqueta que lee el primer operador.                ;
;===============================================================================;
boton0_1:
	mov	num_boton,0
	jmp jmp_lee_oper1
boton1_1:
    mov num_boton,1
    jmp jmp_lee_oper1
boton2_1:
    mov num_boton,2
    jmp jmp_lee_oper1
boton3_1:
    mov num_boton,3
    jmp jmp_lee_oper1
boton4_1:
    mov num_boton,4
    jmp jmp_lee_oper1
boton5_1:
    mov num_boton,5
    jmp jmp_lee_oper1
boton6_1:
    mov num_boton,6
    jmp jmp_lee_oper1
boton7_1:
    mov num_boton,7
    jmp jmp_lee_oper1
boton8_1:
    mov num_boton,8
    jmp jmp_lee_oper1
boton9_1:
    mov num_boton,9
    jmp jmp_lee_oper1
botonA_1:
    mov num_boton,10
    jmp jmp_lee_oper1
botonB_1:
    mov num_boton,11
    jmp jmp_lee_oper1
botonC_1:
    mov num_boton,12
    jmp jmp_lee_oper1
botonD_1:
    mov num_boton,13
    jmp jmp_lee_oper1
botonE_1:
    mov num_boton,14
    jmp jmp_lee_oper1
botonF_1:
    mov num_boton,15
    jmp jmp_lee_oper1
;===============================================================================;
; Para el caso de los botones de los operadores, al dar click en uno de estos,  ;
; se le asigna el carácter de la operación que se realizará, y directamente     ;
; continúa el programa en espera de la segunda operación.                       ;
;===============================================================================;
botonSuma_1:
	mov operador,"+"
	jmp mouse_no_clic
botonResta_1:
	mov operador,"-"
	jmp mouse_no_clic
botonMult_1:
	mov operador,"*"
	jmp mouse_no_clic
botonDivC_1:
	mov operador,"/"
	jmp mouse_no_clic
botonDivR_1:
	mov operador,"%"
	jmp mouse_no_clic
;===============================================================================;
; Al dar click en el botón "igual", comienza a convertir todas las entradas en  ;
; números que la computadora pueda operar.                                      ;
;===============================================================================;
botonIgual_1:
;Salto auxiliar para hacer un salto más largo
;!===============================================================================;
; Para convertir los dígitos almacenados a números, en ambos
	mov 	bx,offset num1			; Dirección en memoria del número 1
	mov		cx,[conta1]
	call 	DIG2DEC
	mov		[num1h],ax

	mov		bx,offset num2			; Dirección en memoria del número 2
	mov		cx,[conta2]
	call 	DIG2DEC
	mov 	[num2h],ax

	mov		[resultado],0

    mov     cx,4d
	cmp 	[operador],"+"
	je		operacion_sumar

	cmp 	[operador],"-"
	je 		operacion_restar

    cmp     [operador],"*"
    je      operacion_multiplicar

    cmp     [operador],"/"
    je      operacion_dividir

    cmp     [operador],"%"
    je      operacion_modulo

	jmp 	mouse_no_clic

; Salto auxiliar para leer los operadores.
jmp_lee_oper1:
	jmp 	lee_oper1

;===============================================================================;
lee_oper1:
	cmp [operador],0	;compara el valor del operador que puede ser 0, '+', '-', '*', '/', '%'
	jne lee_oper2 		;Si el comparador es diferente de 0, entonces lee el segundo numero
	cmp [conta1],4 		;compara si el contador para num1 llego al maximo
	jae no_lee_num 		;si conta1 es mayor o igual a 4, entonces se ha alcanzado el numero de digitos
						;y no hace nada
	mov al,num_boton	;valor del boton presionado en AL
	mov di,[conta1] 	;copia el valor de conta1 en registro indice DI
	mov [num1+di],al 	;num1 es un arreglo de tipo byte
						;se utiliza di para acceder el elemento di-esimo del arreglo num1
						;se guarda el valor del boton presionado en el arreglo
	inc [conta1] 		;incrementa conta1 por numero correctamente leido
	
	;Se imprime el numero del arreglo num1 de acuerdo a conta1
	xor di,di 			;limpia DI para utilizarlo
	mov cx,[conta1] 	;prepara CX para loop de acuerdo al numero de digitos introducidos
	mov [ren_aux],3 	;variable ren_aux para hacer operaciones en pantalla 
						;ren_aux se mantiene fijo a lo largo del siguiente loop
imprime_num1:
	push cx 				;guarda el valor de CX en la pila
	mov [col_aux],58d 		;variable col_aux para hacer operaciones en pantalla 
							;para recorrer la pantalla al imprimir el numero
	sub [col_aux],cl 		;Para calcular la columna en donde comienza a imprimir en pantalla de acuerdo a CX
	posiciona_cursor [ren_aux],[col_aux] 	;Posiciona el cursor en pantalla usando ren_aux y col_aux
	mov cl,[num1+di] 		;copia el digito en CL

	or cl,30h				;Pasa valor ASCII
	cmp	cl,3Ah
	jb  imprime_num1_dec
	add cl,07h
imprime_num1_dec:
	imprime_caracter_color cl,bgNegro,cBlanco	;Imprime caracter en CL, color blanco
	inc di 					;incrementa DI para recorrer el arreglo num1
	pop cx 					;recupera el valor de CX al inicio del loop
	loop imprime_num1 		

	jmp mouse_no_clic

;===============================================================================;
lee_oper2:
	cmp [conta2],4 		;compara si el contador para num2 llego al maximo
	jae no_lee_num 		;si conta2 es mayor o igual a 4, entonces se ha alcanzado el numero de digitos
						;y no hace nada
	mov 	al,num_boton
	mov		di,[conta2]
	mov		[num2+di],al
	inc		[conta2]

	xor		di,di
	mov		cx,[conta2]
	mov		[ren_aux],4

imprime_num2:
	push	cx
	mov		[col_aux],58d
	sub		[col_aux],cl
	posiciona_cursor [ren_aux],[col_aux]
	mov		cl,[num2+di]
	or		cl,30h
	cmp		cl,3Ah
	jb		imprime_num2_dec
	add 	cl,07h
imprime_num2_dec:
	imprime_caracter_color cl,bgNegro,cBlanco
	inc		di
	pop		cx
	loop	imprime_num2

no_lee_num:
	jmp mouse_no_clic

; TODO : Imprimir operación - Convertir a dígitos
;===============================================================================;
operacion_sumar:
    xor     dx,dx               ; Se establece DX en cero
	mov		ax,[num1h]          ; Se mueve el número 1 a ax
	mov		bx,[num2h]          ; Se mueve el número 2 a bx
	adc		ax,bx               ; Se suma ax + bx
    jnc     add_no_carry        ; Si no hay carry, guarda el resultado en AX
    adc     dx,0                ; Si hay carry, lo guarda en DX
add_no_carry:
	mov		[resultado],ax      ; Guarda AX en la primera mitad del resultado
    mov     [resultado + 2],dx  ; Guarda DX en la segunda mitad del resutlado
	jmp 	imprime_resultado   ; Salto a la impresión del resutlado

operacion_restar:
	mov		ax,[num1h]          ; Se mueve el número 1 a ax
	mov		bx,[num2h]          ; Se mueve el número 2 a bx
	sub		ax,bx               ; Se resta ax - bx
    jnc     sub_no_carry        ; Se comprueba si hubo carry, y en caso de que haya, se agrega el carry
    sbb     dx,0                ; Se agrega el carry
sub_no_carry:
    cmp     ax,0h               ; Se compara si ax es mayor o igual a cero para la impresión de números negativos
    jge     sub_pos             ; Si es mayor o igual, se imprime el resultado
    cmp     [baseSel],baseBin   ; Se comprueba si la base es binaria, para omitir el neg
    je      sub_pos             ; Si es binario, imprime el resultado
    push    ax                  ; Se guardan ax y dx en la pila
    push    dx
    mov     [col_aux],49d       ; Se prepara el dígito "-" en la posición indicada para imprimir el signo
    mov     [ren_aux],5h
    mov     dl,"-"
    mov     [num_impr],dl
    posiciona_cursor [ren_aux],[col_aux]
    imprime_caracter_color [num_impr],bgNegro,cBlanco
    pop     dx                  ; Se restauran ax y dx
    pop     ax
    neg     ax                  ; Se obtiene el complemento a 2 de ax para imprimirlo como positivo, pero el signo indicará que es negativo
    xor     dx,dx               ; Limpia dx

sub_pos:
	mov		[resultado],ax      ; Mueve el resultado desde ax
    mov     [resultado + 2],dx  ; Guarda dx en la segunda mitad del resultado
	jmp		imprime_resultado   ; Salto a la impresión del resultado

operacion_multiplicar:
	mov		ax,[num1h]          ; Se mueve el número 1 a ax
	mov		bx,[num2h]          ; Se mueve el número 2 a bx
    mul     bx                  ; Muliplica AX * BX
    mov     [resultado],ax      ; Guarda AX en la primera mitad del resultado
    mov     [resultado + 2],dx  ; Guarda BX en la segund mitad del resultado
    jmp     imprime_resultado

operacion_dividir:
    mov		ax,[num1h]          ; Se mueve el número 1 a ax
	mov		bx,[num2h]          ; Se mueve el número 2 a bx
    cmp     bx,0h
    jle     omite_division      ; Si se intenta dividir entre cero, se omite la operación y se muestra un mensaje de error
    xor     dx,dx               ; Establece DX en cero para la división
    div     bx
    mov     [resultado],ax      ; Se mueve AX a la primera mitad del resultado
    xor     dx,dx               ; Se limpia DX
    mov     [resultado + 2],dx  ; Se mueve DX al la segunda mitad del resultado
    jmp     imprime_resultado
omite_division:
    mov     [col_aux],16d       ; Se preparan las variables auxiliares para mostrar el mensaje
    mov     [ren_aux],2h
    mov     bx,offset error_zero; Se guarda en BX la dirección en memoria del mensaje
    xor     si,si               ; Se inicia el índice en cero
    mov     cx,ez_len - 1       ; Se le resta 1 al índice y se guarda en CX
loop_msg:
    mov     dl,[bx + si]        ; Se recorre cada carácter del mensaje para imprimirlo
    mov     [num_impr],dl
    push    ax
    push    bx
    push    cx
    posiciona_cursor [ren_aux],[col_aux]
    imprime_caracter_color [num_impr],bgNegro,cRojo
    pop     cx
    pop     bx
    pop     ax
    inc     [col_aux]           ; Se incrementan el índice y la columna
    inc     si
    loop    loop_msg

pause_div0:                     ; Espera a que se presione enter para seguir la ejecución del programa
	mov     ax,0800h
    int     21h
    cmp     al,0Dh
    jnz     pause_div0

    call    LIMPIA_PANTALLA_CALC; Limpia la interfaz
    jmp     mouse_no_clic       ; Continúa la ejecución

operacion_modulo:
    mov     ax,[num1h]
    mov     bx,[num2h]
    cmp     bx,0h               ; De la misma manera que en la división, se revisa que el denominador no sea cero
    jle     omite_division      ; y si es cero, se muestra un mensaje de error.
    xor     dx,dx
    div     bx
    mov     [resultado],dx
    xor     dx,dx
    mov     [resultado + 2],dx
    jmp     imprime_resultado

imprime_resultado:
    mov     [ren_aux],5
    cmp     [baseSel],baseHex
    je      imprime_resultado_hex
    cmp     [baseSel],baseDec
    je      imprime_resultado_dec

imprime_resultado_bin:
    mov     ax,[resultado]
    mov     bx,offset bf_result

    call    BIN2DIG

    mov     [col_aux],50d
    mov     bx,offset bf_result

    xor     si,si
    mov     cx,8h

    xor     di,di
loop_imprime_bin:
    push    bx
    push    cx
    mov     dl,[bx + si]
    mov     [num_impr],dl
    posiciona_cursor [ren_aux],[col_aux]
    imprime_caracter_color [num_impr],bgNegro,cBlanco
    pop     cx
    pop     bx
    inc     si
    inc     di
    inc     [col_aux]
    loop    loop_imprime_bin

    jmp imprime_end

imprime_resultado_hex:
    cmp     [resultado + 2],0h
    je      imprime_ax_hex

    mov     ax,[resultado + 2]
    mov     bx,offset bf_result

    call    HEX2DIG

imprime_ax_hex:
    mov     ax,[resultado]
    mov     bx,offset bf_result

    add     bx,04h
    call    HEX2DIG

    mov     [col_aux],50d
    mov     bx,offset bf_result

    xor     si,si
    mov     cx,8h
loop_imp_hex:
    push    bx
    push    cx
    mov     dl,[bx + si]
    mov     [num_impr],dl
    posiciona_cursor [ren_aux],[col_aux]
    imprime_caracter_color [num_impr],bgNegro,cBlanco
    pop     cx
    pop     bx
    inc     si
    inc     [col_aux]
    loop    loop_imp_hex

    jmp     imprime_end

imprime_resultado_dec:
    cmp     dx,0h ; Si DX es distinto de cero, hay algún residuo de la multiplicación
    je      imprime_ax_dec
    
    div     [diezmil]
    mov     bx,dx
    mov     [col_aux],54d
    call    IMPRIME_BX

    mov     bx,ax
    mov     [col_aux],50d
    call    IMPRIME_BX
    jmp     imprime_end

imprime_ax_dec: 
    mov		[ren_aux],5
    mov     cx,[diezmil]
    cmp     [resultado],cx
    jge     dm_digitos_dec
    mov     [col_aux],54d
    jmp     imprime_ax_1_dec
dm_digitos_dec:
    mov     [col_aux],53d

imprime_ax_1_dec:
    mov     bx,[resultado]
    call    IMPRIME_BX
imprime_end:
	mov 	[conta1],0
	mov 	[conta2],0
	mov 	[operador],0
	mov 	[num_boton],0
	mov 	[num1h],0
	mov 	[num1],0
	mov 	[num2h],0
	mov 	[num2],0
	mov     [resultado],0
    call    CLR_RES_BUFFER

	jmp mouse_no_clic

; * Si no se encontró el driver del mouse, muestra un mensaje y debe salir tecleando [enter]
teclado:
	mov ah,08h
	int 21h
	cmp al,0Dh		;compara la entrada de teclado si fue [enter]
	jnz teclado 	;Sale del ciclo hasta que presiona la tecla [enter]

salir:
 	clear
	mov ax,4C00h
	int 21h

;procedimiento MARCO_UI
;no requiere parametros de entrada
;Dibuja el marco de la interfaz de usuario del programa 
MARCO_UI proc
    xor di,di
    mov cx,80d
    mov [col_aux],0
marcos_horizontales:
    push cx
    ;Imprime marco superior
    posiciona_cursor 0,[col_aux]
    cmp [marco_sup+di],'X'
    je cerrar
superior:
    imprime_caracter_color [marco_sup+di],bgNegro,cBlanco
    jmp inferior
cerrar:
    imprime_caracter_color [marco_sup+di],bgNegro,cRojoClaro
inferior:
    ;Imprime marco inferior
    posiciona_cursor 24,[col_aux]
    imprime_caracter_color [marco_inf+di],bgNegro,cBlanco
    inc [col_aux]
    inc di
    pop cx
    loop marcos_horizontales
    
    ;Imprime marcos laterales
    xor di,di
    mov cx,23		;cx = 23d = 17h. Prepara registro CX para loop. 
                    ;para imprimir los marcos laterales en pantalla, entre el segundo y el penúltimo renglones
    mov [ren_aux],0
marcos_verticales:
    push cx
    inc [ren_aux]
    posiciona_cursor [ren_aux],0
    imprime_caracter_color [marco_lat],bgNegro,cBlanco
    posiciona_cursor [ren_aux],79
    imprime_caracter_color [marco_lat],bgNegro,cBlanco
    pop cx
    loop marcos_verticales
    ret 			;Regreso de llamada a procedimiento
endp	 			;Indica fin de procedimiento UI para el ensamblador

;procedimiento CALCULADORA_UI
;no requiere parametros de entrada
;Dibuja el marco de la calculador en la interfaz de usuario del programa 
CALCULADORA_UI proc
    xor di,di
    mov cx,50d
    mov [col_aux],15d
marcos_hor_cal:
    push cx
    ;Imprime marco superior
    posiciona_cursor 1,[col_aux]
    imprime_caracter_color [marco_sup_cal+di],bgNegro,cCyanClaro
    ;Imprime marco inferior
    posiciona_cursor 23,[col_aux]
    imprime_caracter_color [marco_inf_cal+di],bgNegro,cCyanClaro
    inc [col_aux]
    inc di
    pop cx
    loop marcos_hor_cal
    
    ;Imprime marcos laterales
    xor di,di
    mov cx,21d		;cx = 20d. Prepara registro CX para loop. 
                    ;para imprimir los marcos laterales en pantalla, entre el segundo y el penúltimo renglones
    mov [ren_aux],1
marcos_ver_cal:
    push cx
    inc [ren_aux]
    posiciona_cursor [ren_aux],15
    imprime_caracter_color [marco_lat_cal],bgNegro,cCyanClaro
    posiciona_cursor [ren_aux],64
    imprime_caracter_color [marco_lat_cal],bgNegro,cCyanClaro
    pop cx
    loop marcos_ver_cal

    ;Imprime marco horizontal interno
    mov cx,48
    mov [col_aux],16d
marco_hor_interno_cal:
    push cx
    posiciona_cursor 6,[col_aux]
    imprime_caracter_color [marco_hint_cal],bgNegro,cCyanClaro
    inc [col_aux]
    pop cx
    loop marco_hor_interno_cal

    ;Imprime marco vertical interno
    mov cx,16d
    mov [ren_aux],7
marco_ver_interno_cal:
    push cx
    posiciona_cursor [ren_aux],49
    imprime_caracter_color [marco_vint_cal],bgNegro,cCyanClaro
    inc [ren_aux]
    pop cx
    loop marco_ver_interno_cal

    ;Imprime intersecciones
marco_intersecciones:
    ;interseccion izquierda
    posiciona_cursor 6,15
    imprime_caracter_color [marco_cizq_cal],bgNegro,cCyanClaro
    ;interseccion derecha
    posiciona_cursor 6,64
    imprime_caracter_color [marco_cder_cal],bgNegro,cCyanClaro
    ;interseccion superior
    posiciona_cursor 6,49
    imprime_caracter_color [marco_csup_cal],bgNegro,cCyanClaro
    ;interseccion inferior
    posiciona_cursor 23,49
    imprime_caracter_color [marco_cinf_cal],bgNegro,cCyanClaro

;Imprimir botones
    ;Imprime Boton 0
    mov [boton_columna],24
    mov [boton_renglon],19
    mov [boton_color],bgMagenta
    mov [boton_caracter_color],cBlanco
    mov [boton_caracter],'0'
    call IMPRIME_BOTON

    ;Imprime Boton 1
    mov [boton_columna],24
    mov [boton_renglon],15
    mov [boton_color],bgMagenta
    mov [boton_caracter_color],cBlanco
    mov [boton_caracter],'1'
    call IMPRIME_BOTON

;===============================================================================;
; Para los botones decimales y hexadecimales, se agregan comprobaciones para    ;
; cambiar el estilo si están activados o desactivados.                          ;
; Siguiendo la misma lógica para detectar clicks en los botones, primero se     ;
; comprueba si la base es hexadecimal, en caso de que sea hexadecimal, se       ;
; asume que hay que activar los botones decimales. En caso de que la base sea   ;
; decimal, se activan los botones, y en caso de que no sea la base indicada     ;
; estos aparecerán de color gris, indicando que están desacticvados             ;
;===============================================================================;
    ;Imprime Boton 2
    mov [boton_columna],30
    mov [boton_renglon],15
    cmp baseSel,baseHex
    je imp_boton_2_enable
    cmp baseSel,baseDec
    je imp_boton_2_enable
    mov [boton_color],bgGrisOscuro
    mov [boton_caracter_color],cBlanco
    jmp imp_boton_2
imp_boton_2_enable:
    mov [boton_color],bgCyan
    mov [boton_caracter_color],cNegro
imp_boton_2:
    mov [boton_caracter],'2'
    call IMPRIME_BOTON

    ;Imprime Boton 3
    mov [boton_columna],36
    mov [boton_renglon],15
    cmp baseSel,baseHex
    je imp_boton_3_enable
    cmp baseSel,baseDec
    je imp_boton_3_enable
    mov [boton_color],bgGrisOscuro
    mov [boton_caracter_color],cBlanco
    jmp imp_boton_3
imp_boton_3_enable:
    mov [boton_color],bgCyan
    mov [boton_caracter_color],cNegro
imp_boton_3:
    mov [boton_caracter],'3'
    call IMPRIME_BOTON

    ;Imprime Boton 4
    mov [boton_columna],24
    mov [boton_renglon],11
    cmp baseSel,baseHex
    je imp_boton_4_enable
    cmp baseSel,baseDec
    je imp_boton_4_enable
    mov [boton_color],bgGrisOscuro
    mov [boton_caracter_color],cBlanco
    jmp imp_boton_4
imp_boton_4_enable:
    mov [boton_color],bgCyan
    mov [boton_caracter_color],cNegro
imp_boton_4:
    mov [boton_caracter],'4'
    call IMPRIME_BOTON

    ;Imprime Boton 5
    mov [boton_columna],30
    mov [boton_renglon],11
    cmp baseSel,baseHex
    je imp_boton_5_enable
    cmp baseSel,baseDec
    je imp_boton_5_enable
    mov [boton_color],bgGrisOscuro
    mov [boton_caracter_color],cBlanco
    jmp imp_boton_5
imp_boton_5_enable:
    mov [boton_color],bgCyan
    mov [boton_caracter_color],cNegro
imp_boton_5:
    mov [boton_caracter],'5'
    call IMPRIME_BOTON

    ;Imprime Boton 6
    mov [boton_columna],36
    mov [boton_renglon],11
    cmp baseSel,baseHex
    je imp_boton_6_enable
    cmp baseSel,baseDec
    je imp_boton_6_enable
    mov [boton_color],bgGrisOscuro
    mov [boton_caracter_color],cBlanco
    jmp imp_boton_6
imp_boton_6_enable:
    mov [boton_color],bgCyan
    mov [boton_caracter_color],cNegro
imp_boton_6:
    mov [boton_caracter],'6'
    call IMPRIME_BOTON

    ;Imprime Boton 7
    mov [boton_columna],24
    mov [boton_renglon],7
    cmp baseSel,baseHex
    je imp_boton_7_enable
    cmp baseSel,baseDec
    je imp_boton_7_enable
    mov [boton_color],bgGrisOscuro
    mov [boton_caracter_color],cBlanco
    jmp imp_boton_7
imp_boton_7_enable:
    mov [boton_color],bgCyan
    mov [boton_caracter_color],cNegro
imp_boton_7:
    mov [boton_caracter],'7'
    call IMPRIME_BOTON

    ;Imprime Boton 8
    mov [boton_columna],30
    mov [boton_renglon],7
    cmp baseSel,baseHex
    je imp_boton_8_enable
    cmp baseSel,baseDec
    je imp_boton_8_enable
    mov [boton_color],bgGrisOscuro
    mov [boton_caracter_color],cBlanco
    jmp imp_boton_8
imp_boton_8_enable:
    mov [boton_color],bgCyan
    mov [boton_caracter_color],cNegro
imp_boton_8:
    mov [boton_caracter],'8'
    call IMPRIME_BOTON

    ;Imprime Boton 9
    mov [boton_columna],36
    mov [boton_renglon],7
    cmp baseSel,baseHex
    je imp_boton_9_enable
    cmp baseSel,baseDec
    je imp_boton_9_enable
    mov [boton_color],bgGrisOscuro
    mov [boton_caracter_color],cBlanco
    jmp imp_boton_9
imp_boton_9_enable:
    mov [boton_color],bgCyan
    mov [boton_caracter_color],cNegro
imp_boton_9:
    mov [boton_caracter],'9'
    call IMPRIME_BOTON

;===============================================================================;
; Para los botones en hexadecimal, únicamente se comprueba si la base es        ;
; hexadecimal, en caso de que la base no sea la indicada, se les dará un estilo ;
; indicando que están desactivados.                                             ;
;===============================================================================;
    ;Imprime Boton A
    mov [boton_columna],30
    mov [boton_renglon],19
    cmp	baseSel,baseHex
    je	imp_boton_A_enable
    mov [boton_color],bgGrisOscuro
    mov [boton_caracter_color],cBlanco
    jmp imp_boton_A
imp_boton_A_enable:
    mov [boton_color],bgVerde
    mov [boton_caracter_color],cNegro
imp_boton_A:
    mov [boton_caracter],'A'
    call IMPRIME_BOTON

    ;Imprime Boton B
    mov [boton_columna],36
    mov [boton_renglon],19
    cmp	baseSel,baseHex
    je	imp_boton_B_enable
    mov [boton_color],bgGrisOscuro
    mov [boton_caracter_color],cBlanco
    jmp imp_boton_B
imp_boton_B_enable:
    mov [boton_color],bgVerde
    mov [boton_caracter_color],cNegro
imp_boton_B:
    mov [boton_caracter],'B'
    call IMPRIME_BOTON

    ;Imprime Boton C
    mov [boton_columna],42
    mov [boton_renglon],19
    cmp     baseSel,baseHex
    je      imp_boton_C_enable
    mov [boton_color],bgGrisOscuro
    mov [boton_caracter_color],cBlanco
    jmp imp_boton_C
imp_boton_C_enable:
    mov [boton_color],bgVerde
    mov [boton_caracter_color],cNegro
imp_boton_C:
    mov [boton_caracter],'C'
    call IMPRIME_BOTON

    ;Imprime Boton D
    mov [boton_columna],42
    mov [boton_renglon],15
    cmp     baseSel,baseHex
    je      imp_boton_D_enable
    mov [boton_color],bgGrisOscuro
    mov [boton_caracter_color],cBlanco
    jmp imp_boton_D
imp_boton_D_enable:
    mov [boton_color],bgVerde
    mov [boton_caracter_color],cNegro
imp_boton_D:
    mov [boton_caracter],'D'
    call IMPRIME_BOTON

    ;Imprime Boton E
    mov [boton_columna],42
    mov [boton_renglon],11
    cmp     baseSel,baseHex
    je      imp_boton_E_enable
    mov [boton_color],bgGrisOscuro
    mov [boton_caracter_color],cBlanco
    jmp imp_boton_E
imp_boton_E_enable:
    mov [boton_color],bgVerde
    mov [boton_caracter_color],cNegro
imp_boton_E:
    mov [boton_caracter],'E'
    call IMPRIME_BOTON

    ;Imprime Boton F
    mov [boton_columna],42
    mov [boton_renglon],7
    cmp     baseSel,baseHex
    je      imp_boton_F_enable
    mov [boton_color],bgGrisOscuro
    mov [boton_caracter_color],cBlanco
    jmp imp_boton_F
imp_boton_F_enable:
    mov [boton_color],bgVerde
    mov [boton_caracter_color],cNegro
imp_boton_F:
    mov [boton_caracter],'F'
    call IMPRIME_BOTON

    ;Imprime Boton +
    mov [boton_columna],51
    mov [boton_renglon],9
    mov [boton_color],bgAmarillo
    mov [boton_caracter_color],cRojo
    mov [boton_caracter],'+'
    call IMPRIME_BOTON

    ;Imprime Boton -
    mov [boton_columna],58
    mov [boton_renglon],9
    mov [boton_color],bgAmarillo
    mov [boton_caracter_color],cRojo
    mov [boton_caracter],'-'
    call IMPRIME_BOTON

    ;Imprime Boton *
    mov [boton_columna],51
    mov [boton_renglon],13
    mov [boton_color],bgAmarillo
    mov [boton_caracter_color],cRojo
    mov [boton_caracter],'*'
    call IMPRIME_BOTON

    ;Imprime Boton /
    mov [boton_columna],58
    mov [boton_renglon],13
    mov [boton_color],bgAmarillo
    mov [boton_caracter_color],cRojo
    mov [boton_caracter],'/'
    call IMPRIME_BOTON

    ;Imprime Boton %
    mov [boton_columna],51
    mov [boton_renglon],17
    mov [boton_color],bgAmarillo
    mov [boton_caracter_color],cRojo
    mov [boton_caracter],'%'
    call IMPRIME_BOTON

    ;Imprime Boton =
    mov [boton_columna],58
    mov [boton_renglon],17
    mov [boton_color],bgRojo
    mov [boton_caracter_color],cNegro
    mov [boton_caracter],'='
    call IMPRIME_BOTON

;===============================================================================;
; Para la impresión de los botones y si están seleccionados, se agrega una      ;
; comparación para verificar si el botón corresponde a la base usada (baseSel)  ;
; En caso de que sea la base seleccionada, este se coloreará de un color azul   ;
; claro, y los demás quedarán en azúl obscuro                                   ;
;===============================================================================;
    ;Imprime Boton Dec
    mov [boton_columna],17
    mov [boton_renglon],7
    cmp [baseSel],baseDec               ; Comprueba si la base es decimal
    je boton_dec_enabled                ; Si la base coincide, se muestra el botón como activado
    mov [boton_color],bgAzul            ; Si la base no coincide, se establece como desactivado
    jmp imp_boton_dec                   ; Continúa la impresión
boton_dec_enabled:
    mov [boton_color],bgAzulClaro       ; Cuando la base es distinta, se establece como botón activado
imp_boton_dec:
    mov [boton_caracter_color],cBlanco
    call IMPRIME_BOTON
    inc [boton_columna]
    inc [boton_renglon]
    posiciona_cursor [boton_renglon],[boton_columna]
    imprime_caracter_color 'D',[boton_color],[boton_caracter_color]
    inc [boton_columna]
    posiciona_cursor [boton_renglon],[boton_columna]
    imprime_caracter_color 'e',[boton_color],[boton_caracter_color]
    inc [boton_columna]
    posiciona_cursor [boton_renglon],[boton_columna]
    imprime_caracter_color 'c',[boton_color],[boton_caracter_color]

    ;Imprime Boton Hex
    mov [boton_columna],17
    mov [boton_renglon],11
    cmp [baseSel],baseHex
    je boton_hex_enabled
    mov [boton_color],bgAzul
    jmp imp_boton_hex
boton_hex_enabled:
    mov [boton_color],bgAzulClaro
imp_boton_hex:
    mov [boton_caracter_color],cBlanco
    call IMPRIME_BOTON
    inc [boton_columna]
    inc [boton_renglon]
    posiciona_cursor [boton_renglon],[boton_columna]
    imprime_caracter_color 'H',[boton_color],[boton_caracter_color]
    inc [boton_columna]
    posiciona_cursor [boton_renglon],[boton_columna]
    imprime_caracter_color 'e',[boton_color],[boton_caracter_color]
    inc [boton_columna]
    posiciona_cursor [boton_renglon],[boton_columna]
    imprime_caracter_color 'x',[boton_color],[boton_caracter_color]

    ;Imprime Boton Bin
    mov [boton_columna],17
    mov [boton_renglon],15
    cmp [baseSel],baseBin
    je boton_bin_enabled
    mov [boton_color],bgAzul
    jmp imp_boton_bin
boton_bin_enabled:
    mov [boton_color],bgAzulClaro
imp_boton_bin:
    mov [boton_caracter_color],cBlanco
    call IMPRIME_BOTON
    inc [boton_columna]
    inc [boton_renglon]
    posiciona_cursor [boton_renglon],[boton_columna]
    imprime_caracter_color 'B',[boton_color],[boton_caracter_color]
    inc [boton_columna]
    posiciona_cursor [boton_renglon],[boton_columna]
    imprime_caracter_color 'i',[boton_color],[boton_caracter_color]
    inc [boton_columna]
    posiciona_cursor [boton_renglon],[boton_columna]
    imprime_caracter_color 'n',[boton_color],[boton_caracter_color]

    ;Imprime un '0' inicial en la calculadora
    posiciona_cursor 3,57d
    imprime_caracter_color '0',bgNegro,cBlanco
    ret 			;Regreso de llamada a procedimiento
endp	 			;Indica fin de procedimiento UI para el ensamblador

;procedimiento IMPRIME_BOTON
;Dibuja un boton que abarca 3 renglones y 5 columnas
;con un caracter centrado dentro del boton
;en la posición que se especifique (esquina superior izquierda)
;y de un color especificado
;Utiliza paso de parametros por variables globales
;Las variables utilizadas son:
;boton_caracter: debe contener el caracter que va a mostrar el boton
;boton_renglon: contiene la posicion del renglon en donde inicia el boton
;boton_columna: contiene la posicion de la columna en donde inicia el boton
;boton_color: contiene el color del boton
IMPRIME_BOTON proc
    ;background de botón
    mov bh,[boton_color]	 	;Color del botón
    xor bh,[boton_caracter_color]	 	;Color del botón
    ;Posicion superior izquierda de donde comienza el boton
    mov ch,[boton_renglon]
    mov cl,[boton_columna]
    ;Posicion inferior derecha de donde termina el boton
    mov dh,ch
    add dh,2
    mov dl,cl
    add dl,4
    mov ax,0600h 		    ;AH=06h (scroll up window) AL=00h (borrar)
    int 10h                 ;int 10h opción 06h. Establece el color de fondo en pantalla, con los atributos dados, 
                            ;especificando CX: esquina superior izquierda CH: renglon, CL: columna y 
                            ;DX: esquina inferior derecha, DH: renglon y DL: columna
    ;Mover al centro de la posición actual para imprimir el caracter
    mov [col_aux],dl
    mov [ren_aux],dh
    sub [col_aux],2
    sub [ren_aux],1
    posiciona_cursor [ren_aux],[col_aux]
    imprime_caracter_color [boton_caracter],[boton_color],[boton_caracter_color]
    ret 			;Regreso de llamada a procedimiento
endp	 			;Indica fin de procedimiento IMPRIME_BOTON para el ensamblador


;procedimiento LIMPIA_PANTALLA_CALC
;no requiere parametros de entrada
;"Borra" el contenido de lo que se encuentra en la pantalla de la calculadora
LIMPIA_PANTALLA_CALC proc
    mov cx,4d
limpia_num1_y_num2:
    push cx
    mov [col_aux],58d
    sub [col_aux],cl
    posiciona_cursor 3,[col_aux]
    imprime_caracter_color ' ',bgNegro,cNegro
    posiciona_cursor 4,[col_aux]
    imprime_caracter_color ' ',bgNegro,cNegro
    pop cx
    loop limpia_num1_y_num2

limpia_operador:
    posiciona_cursor 4,52d
    imprime_caracter_color ' ',bgNegro,cNegro

    mov cx,10d
limpia_resultado:
    push cx
    mov [col_aux],58d
    sub [col_aux],cl
    posiciona_cursor 5,[col_aux]
    imprime_caracter_color ' ',bgNegro,cNegro
    pop cx
    loop limpia_resultado

    posiciona_cursor 3,57d
    imprime_caracter_color '0',bgNegro,cBlanco

    mov     [col_aux],16d
    mov     [ren_aux],2h
    mov     cx,ez_len - 1
limpia_mensaje:
    mov     dl," "
    mov     [num_impr],dl
    push    cx
    posiciona_cursor [ren_aux],[col_aux]
    imprime_caracter_color [num_impr],bgNegro,cNegro
    pop     cx
    inc     [col_aux]
    loop    limpia_mensaje

    ;Reinicia valores de variables utilizadas
    mov [conta1],0
    mov [conta2],0
    mov [operador],0
    mov [num_boton],0
    mov [num1h],0
    mov [num2h],0

    call CALCULADORA_UI
    ret 			;Regreso de llamada a procedimiento
endp	 			;Indica fin de procedimiento UI para el ensamblador

;===============================================================================;
; Procedimiento para convertir un arreglo de carácteres a un número, a partir   ;
; de una base dada                                                              ;
; BX - Dirección en memoria del arreglo con dígitos                             ;
; CX - Longitud del número                                                      ;
; Siguiendo el siguiente ejemplo, para convertir en base 10                     ;
; donde se usa la siguiente fórmula:                                            ;
; ax = bx + ax * BASE                                                           ;
;                                                                               ;
; Ejemplo con 1245:                                                             ;
; 1 + 0   * 10 = 1;                                                             ;
; 2 + 1   * 10 = 12                                                             ;
; 4 + 12  * 10 = 124                                                            ;
; 5 + 124 * 10 = 1245                                                           ;
;                                                                               ;
; Se aplica la misma idea para las demás bases                                  ;
;===============================================================================;
DIG2DEC proc tiny ; El número se pasará por bx y la longitud por cx
	push     	bp
	mov      	bp,sp
	xor			si,si               ; Se colocan si, ax y ch en 0 para las operaciones
	xor			ax,ax
	xor			ch,ch
txt2num:
	push		cx                  ; Se guarda el valor de cx (El contador de los dígitos)
	mov			cl,[bx + si]        ; Se guarda en cl el dígito del arreglo + índice

	cmp			[baseSel],baseHex   ; Se comprueba si la calculadora está en base hexadecimal
	jne			txtdec              ; Si no es hexadecimal, pasa a comprobar si es decimal
	mul			[dhex]              ; Para hexadecimal se multiplica por la base 16
	add			ax,cx               ; Se le suma a el acomulador AX el dígito de CX
	jmp 		txt2num_end         ; Salta al final de la iteración

txtdec:
	cmp			[baseSel],baseBin   ; Se comprueba si la calculadora está en base decimal
	je			txtbin              ; Si está en decimal
	mul			[diez]              ; Se multiplica por la base decimal (10)
	add			ax,cx               ; Se le suma al acomulador AX el díguto de CX
	jmp			txt2num_end         ; Salta al final de la iteración

txtbin:
	mul			[dbin]              ; Para binario, se multiplica por la base 2
	add			ax,cx               ; Se le suma al acomulador AX el dígito de CX

txt2num_end:
	inc			si                  ; Se incrementa el índice
	pop         cx                  ; Se recupera la longitud del número
	cmp			si,cx               ; Se comprueba si el índice es igual a la longitud del número
	jl			txt2num             ; Si aún faltan dígitos, se repite el ciclo
	pop      	bp
	ret
DIG2DEC endp

;procedimiento IMPRIME_BX
;Imprime un numero entero decimal guardado en BX
;Se pasa un numero a traves del registro BX que se va a imprimir con 4 o 5 digitos
;Si BX es menor a 10000, imprime 4 digitos, si no imprime 5 digitos
;Antes de llamar el procedimiento, se requiere definir la posicion en pantalla
;a partir de la cual comienza la impresion del numero con ayuda de las variables [ren_aux] y [col_aux]
;[ren_aux] para el renglon (entre 0 y 24)
;[col_aux] para la columna (entre 0 y 79)
IMPRIME_BX	proc 
;Antes de comenzar, se guarda un respaldo de los registros
; CX, DX, AX en la pila
;Al terminar el procedimiento, se recuperan estos valores
    push cx
    push dx
    push ax
;Calcula digito de decenas de millar
    mov cx,bx
    cmp bx,10000d
    jb imprime_4_digs
    mov ax,bx 				;pasa el valor de BX a AX para division de 16 bits
    xor dx,dx 				;limpia registro DX, para extender AX a 32 bits
    div [diezmil]			;Division de 16 bits => AX=cociente, DX=residuo
                            ;El cociente contendrá el valor del dígito que puede ser entre 0 y 9. 
                            ;Por lo tanto, AX=000Xh => AH=00h y AL=0Xh, donde X es un dígito entre 0 y 9
                            ;Asumimos que el digito ya esta en AL
                            ;El residuo se utilizara para los siguientes digitos
    mov cx,dx 				;Guardamos el residuo anterior en un registro disponible para almacenarlo temporalmente
                            ;debido a que modificaremos DX antes de usar ese residuo
    ;Imprime el digito decenas de millar 
    add al,30h				;Pasa el digito en AL a su valor ASCII
    mov [num_impr],al 		;Pasa el digito a una variable de memoria ya que AL se modifica en las siguientes macros
    push cx
    posiciona_cursor [ren_aux],[col_aux]
    imprime_caracter_color [num_impr],bgNegro,cBlanco	
    pop cx
    inc [col_aux] 			;Recorre a la siguiente columna para imprimir el siguiente digito

imprime_4_digs:
;Calcula digito de unidades de millar
    mov ax,cx 				;Recuperamos el residuo de la division anterior y preparamos AX para hacer division
    xor dx,dx 				;limpia registro DX, para extender AX a 32 bits
    div [mil]				;Division de 16 bits => AX=cociente, DX=residuo
                            ;El cociente contendrá el valor del dígito que puede ser entre 0 y 9. 
                            ;Por lo tanto, AX=000Xh => AH=00h y AL=0Xh, donde X es un dígito entre 0 y 9
                            ;Asumimos que el digito ya esta en AL
                            ;El residuo se utilizara para los siguientes digitos
    mov cx,dx 				;Guardamos el residuo anterior en un registro disponible para almacenarlo temporalmente
                            ;debido a que modificaremos DX antes de usar ese residuo
    ;Imprime el digito unidades de millar
    add al,30h				;Pasa el digito en AL a su valor ASCII
    mov [num_impr],al 		;Pasa el digito a una variable de memoria ya que AL se modifica en las siguientes macros
    push cx
    posiciona_cursor [ren_aux],[col_aux]
    imprime_caracter_color [num_impr],bgNegro,cBlanco		
    pop cx
    inc [col_aux] 			;Recorre a la siguiente columna para imprimir el siguiente digito

;Calcula digito de centenas
    mov ax,cx 				;Recuperamos el residuo de la division anterior y preparamos AX para hacer division
    xor dx,dx 				;limpia registro DX, para extender AX a 32 bits
    div [cien]				;Division de 16 bits => AX=cociente, DX=residuo
                            ;El cociente contendrá el valor del dígito que puede ser entre 0 y 9. 
                            ;Por lo tanto, AX=000Xh => AH=00h y AL=0Xh, donde X es un dígito entre 0 y 9
                            ;Asumimos que el digito ya esta en AL
                            ;El residuo se utilizara para los siguientes digitos
    mov cx,dx 				;Guardamos el residuo anterior en un registro disponible para almacenarlo temporalmente
                            ;debido a que modificaremos DX antes de usar ese residuo
    ;Imprime el digito de centenas
    add al,30h				;Pasa el digito en AL a su valor ASCII
    mov [num_impr],al 		;Pasa el digito a una variable de memoria ya que AL se modifica en las siguientes macros
    push cx
    posiciona_cursor [ren_aux],[col_aux]
    imprime_caracter_color [num_impr],bgNegro,cBlanco
    pop cx
    inc [col_aux] 			;Recorre a la siguiente columna para imprimir el siguiente digito

;Calcula digito de decenas
    mov ax,cx 				;Recuperamos el residuo de la division anterior y preparamos AX para hacer division
    xor dx,dx 				;limpia registro DX, para extender AX a 32 bits
    div [diez]				;Division de 16 bits => AX=cociente, DX=residuo
                            ;El cociente contendrá el valor del dígito que puede ser entre 0 y 9. 
                            ;Por lo tanto, AX=000Xh => AH=00h y AL=0Xh, donde X es un dígito entre 0 y 9
                            ;Asumimos que el digito ya esta en AL
                            ;El residuo se utilizara para los siguientes digitos
    mov cx,dx 				;Guardamos el residuo anterior en un registro disponible para almacenarlo temporalmente
                            ;debido a que modificaremos DX antes de usar ese residuo
    ;Imprime el digito decenas
    add al,30h				;Pasa el digito en AL a su valor ASCII
    mov [num_impr],al 		;Pasa el digito a una variable de memoria ya que AL se modifica en las siguientes macros
    push cx
    posiciona_cursor [ren_aux],[col_aux]
    imprime_caracter_color [num_impr],bgNegro,cBlanco		
    pop cx
    inc [col_aux]

;Calcula digito de unidades
    mov ax,cx 				;Recuperamos el residuo de la division anterior
                            ;Para este caso, el residuo debe ser un número entre 0 y 9
                            ;al hacer AX = CX, el residuo debe estar entre 0000h y 0009h
                            ;=> AX = 000Xh -> AH=00h y AL=0Xh
    ;Imprime el digito de unidades
    add al,30h				;Pasa el digito en AL a su valor ASCII
    mov [num_impr],al 		;Pasa el digito a una variable de memoria ya que AL se modifica en las siguientes macros
    posiciona_cursor [ren_aux],[col_aux]
    imprime_caracter_color [num_impr],bgNegro,cBlanco

;Se recuperan los valores de los registros CX, AX, y DX almacenados en la pila
    pop ax
    pop dx
    pop cx
    ret 					;intruccion ret para regresar de llamada a procedimiento
endp

;===============================================================================;
; Procedimiento para convertir dígitos hexadecimales a carácteres ASCII         ;
; Datos necesarios:                                                             ;
; BX - Dirección de memoria del inicio del arreglo de dígitos (buf_resultado)   ;
; AX - El número que se pasará a carácteres                                     ;
;===============================================================================;
HEX2DIG proc tiny
    push    bp                      ; Se guarda la base de la pila en la pila
    mov     bp,sp                   ; Se establece como la base de la pila el tope de la pila
    xor     si,si                   ; Se coloca si en 0
    mov     cx,4h                   ; Se establece CX en 4 para el loop
@@loop_digitos:
    xor     dx,dx                   ; Se coloca DX en 0 para la división
    div     [dhex]                  ; Se divide entre la base hexadecimal
    push    dx                      ; Se guarda el residuo en la pila
    loop    @@loop_digitos          ; Se repite el ciclo

@@loop_digs:
    pop     dx                      ; Se saca el último dígito obtenido de la pila en DX
    or      dx,30h                  ; Se convierte a carácter ASCII
    cmp     dx,3Ah                  ; Se comprueba si es un valor hexadecimal
    jl      @@save                  ; Si no es mayor a 'A', se guarda el dígito en el buffer
    add     dx,07h                  ; Si es mayor a 'A', se le suma 7 para obtener el carácter correspondiente en hexadecimal
@@save:
    mov     byte ptr [bx + si],dl   ; Se guarda el carácter almacenado en dl en el índice del arreglo dado por bx
    inc     si                      ; Se incrementa el índice
    cmp     bp,sp                   ; Se compara si aún quedan dígitos en la pila
    jne     @@loop_digs             ; Se repite el ciclo en caso de que aún falten

@@end:
    pop      bp                     ; Se regresa la base de la pila
    ret                             ; Salida de la función
HEX2DIG endp

;===============================================================================;
; Procedimiento para convertir dígitos binarios a carácteres ASCII              ;
; Datos necesarios:                                                             ;
; BX - Dirección de memoria del inicio del arreglo de dígitos (buf_resultado)   ;
; AX - El número que se pasará a carácteres                                     ;
;===============================================================================;
BIN2DIG proc tiny
    push    bp                      ; Se guarda la base de la pila en la pila
    mov     bp,sp                   ; Se establece como la base de la pila el tope de la pila
    xor     si,si                   ; Se coloca si en 0
    mov     cx,8h                   ; CX se establece en 8 para el loop
@@loop_digitos:
    xor     dx,dx                   ; Se coloca DX en 0 para la división
    div     [dbin]                  ; Se divide entre la base decimal
    push    dx                      ; Se guarda el residuo en la pila
    loop    @@loop_digitos          ; Se repite el ciclo 8 veces

@@loop_digs:
    pop     dx                      ; Se saca el dígito obtenido
    or      dx,30h                  ; Se convierte a su valor en ASCII
    mov     byte ptr [bx + si],dl   ; Se guarda el carácter en el arreglo + índice
    inc     si                      ; Se incrementa el índice
    cmp     bp,sp                   ; Se compara si aún quedan dígitos en la pila
    jne     @@loop_digs             ; Se repite el ciclo hasta sacar todos los dígitos
    pop      bp                     ; Se regresa la base de la pila
    ret                             ; Retorno de la función
BIN2DIG endp

;===============================================================================;
; Procedimiento para limpiar el buffer de carácteres del resultado              ;
;===============================================================================;
CLR_RES_BUFFER proc tiny
    push    bp
    mov     bp,sp
    mov     bx,offset bf_result     ; Se mueve a bx la dirección en memoria de bf_result

    xor     si,si                   ; Se coloca el índice en 0
    mov     cx,8h                   ; CX se coloca en 8 para recorrer el arreglo
@@clr:
    mov     byte ptr [bx + si],0h   ; Se coloca 0 en bf_result[si]
    inc     si                      ; si++
    loop    @@clr                   ; Se repite el ciclo
    pop     bp
    ret
CLR_RES_BUFFER endp

end inicio
