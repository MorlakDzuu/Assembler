format PE console
entry main
include 'macro/import32.inc'

section '.data' data readable writeable
        msg db "Enter your name: ",0
        chrarr db "%s",0
        msg2 db "Hello %s",0dh,0ah,0
        p db "pause",0

section '.code' code readable executable

        main:
        push ebp
        mov ebp,esp
        sub esp,24
        mov dword [esp],msg
        call [printf]
        lea eax,[ebp-12]
        mov dword [esp+4],eax
        mov dword [esp],chrarr
        call [scanf]
        mov dword [esp],msg2
        call [printf]
        mov dword [esp],p
        call [system]
        mov dword [esp],0
        call [exit]

section '.idata' import data readable
        library msvcrt,'msvcrt.dll'

        import msvcrt,\
               printf,'printf',\
               scanf,'scanf',\
               system,'system',\
               exit,'exit'