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