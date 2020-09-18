format PE console
entry main

include 'macro/import32.inc'

section '.data' data readable writeable
        intl db "%d",0dh,0ah,0
        p db "pause>nul",0

section '.code' code readable executable
        main:
        push ebp
        mov ebp,esp
        sub esp,12
        mov dword [ebp-4],1
        loopA:
        mov eax,dword [ebp-4]
        cmp eax,11
        jge BreakA
        mov eax,dword [ebp-4]
        mov dword [esp+4],eax
        mov dword [esp],intl
        call [printf]
        mov eax,dword [ebp-4]
        inc eax
        mov dword [ebp-4],eax
        jmp loopA
        BreakA:
        add esp,4
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