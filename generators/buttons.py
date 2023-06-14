from sys import argv

if "b-op" in argv:
    base1 = """boton{}_1:
        mov num_boton,{}
        jmp jmp_lee_oper1"""

    for i in range(16):
        ch = i if i < 10 else chr(i + 55)
        print(base1.format(ch, ch))

if "b-ac" in argv:
    base2 = """boton{}:
        jmp boton{}_1"""

    for i in range(16):
        ch = i if i < 10 else chr(i + 55)
        print(base2.format(ch, ch))

if "b-col" in argv:
    string = """        cmp baseSel,base{}
        je imp_boton_{}_enable
        mov [boton_color],bgGrisOscuro
        mov [boton_caracter_color],cBlanco
        jmp imp_boton_{}
imp_boton_{}_enable:
        mov [boton_color],{}
        mov [boton_caracter_color],cNegro
imp_boton_{}:
    """

    string2 = """        cmp baseSel,baseHex
        je imp_boton_{}_enable
        cmp baseSel,baseDec
        je imp_boton_{}_enable
        mov [boton_color],bgGrisOscuro
        mov [boton_caracter_color],cBlanco
        jmp imp_boton_{}
imp_boton_{}_enable:
        mov [boton_color],{}
        mov [boton_caracter_color],cNegro
imp_boton_{}:
"""

    for i in range(16):
        ch = i if i < 10 else chr(i + 55)
        baseSel = "Dec" if i < 10 else "Hex"
        color = "bgGrisClaro" if i < 10 else "bgVerde"
        if i <= 9:
            print(string2.format(ch, ch, ch, ch, color, ch))
        else:
            print(string.format(baseSel, ch, ch, ch, color, ch))