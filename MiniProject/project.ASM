format PE console
entry start
include 'win32ax.inc'
b equ byte
section '.data' readable writeable
        Site db "http://62.109.3.189/getDate/%s",0Dh, 0Ah,0 ;url ��� ����������� ���� ������
        startMsg db '������� ���: ',0
        finishMsg db '����������� ���� ������ ������ � ��������� ���',0Dh,0Ah,0
        InternetOpenHandle dd ?
        InternetOpenUrlHandle dd ?
        Buff rb 1024  ;����� ��� ������ ������ �������
        BytesRead dd ?
        p db "pause>nul",0
        yearMask db "%s",0
        buff rb 100h
        year db 0

section '.code' code readable executable
start:
        ;����������� ���������
        invoke  SetConsoleOutputCP,1251
        invoke  SetConsoleCP,1251

        ;������ ���������� ���������
        invoke printf, finishMsg

        ;������ �������� �� �������
        push ebp
        mov ebp,esp
        sub esp,24
        mov dword [esp],startMsg
        call [printf]
        lea eax,[ebp-12]
        mov dword [esp+4],eax
        cinvoke scanf,yearMask,year
        invoke  wsprintf,buff,Site,year

        ;�������� �������� ����������
        invoke InternetOpen, 'MicrosoftR Internet Explorer',0, 0, 0, 0
        mov [InternetOpenHandle], eax
        cmp eax, 0
        je exit

        ;�������� get ������� �� ������
        invoke InternetOpenUrl, eax, buff, 0, 0, 0, 0
        mov [InternetOpenUrlHandle], eax
        cmp eax, 0
        je exit

        ;������ ������ �������
        invoke InternetReadFile, eax, Buff, 1023, BytesRead
        cmp eax, 0
        je exit
        mov eax, [BytesRead]
        mov b[Buff+eax], 0
        invoke printf, Buff

        ;�����
        mov dword [esp],p
        call [system]
        jmp closeAll

        ;�������� �������� ����������
        exit:
                invoke MessageBox, 0, '������ ��� ������� ���������� � ������.', 'Error', MB_OK
                invoke InternetCloseHandle, [InternetOpenHandle]
                invoke InternetCloseHandle, [InternetOpenUrlHandle]
                invoke ExitProcess, 0

        ;�������� �������� ����������
        closeAll:
                invoke InternetCloseHandle, [InternetOpenHandle]
                invoke InternetCloseHandle, [InternetOpenUrlHandle]


section '.idata' import data readable writeable
       library wininet,'wininet.dll',\
               kernel32, 'kernel32.dll' ,\
               user32, 'user32.dll',\
               msvcrt,'msvcrt.dll'

       include 'api\user32.inc'
       include 'encoding\WIN1250.inc'
 
       import kernel32, \
               ExitProcess, 'ExitProcess',\
               SetConsoleOutputCP,'SetConsoleOutputCP',\
               SetConsoleCP,'SetConsoleCP'
 
       import wininet,\
               InternetOpen,'InternetOpenA',\
               InternetReadFile,'InternetReadFile',\
               InternetOpenUrl,'InternetOpenUrlA',\
               InternetCloseHandle,'InternetCloseHandle'

       import msvcrt,\
               printf,'printf',\
               scanf,'scanf',\
               system,'system'