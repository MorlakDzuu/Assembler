;===============================================================================
;Program        : getfasmg
;Version        : 0.0.1
;Author         : Yeoh HS
;Date           : 6 January 2018
;Purpose        : a Win32 console program to download fasmg.zip
;flat assembler : 1.73.02
;===============================================================================
format PE CONSOLE 4.0
entry start

include 'win32ax.inc'
include 'macro\if.inc'

INTERNET_OPEN_TYPE_PRECONFIG = 0

;-------------------------------------------------------------------------------
macro println arg*
{
   cinvoke printf, '%s', arg
}

;-------------------------------------------------------------------------------
section '.data' data readable writeable
    wsadata        WSADATA
    TestApp        db "InetURL/1.0",0
    strURL         db "http://flatassembler.net/fasmg.zip",0
    zipfile        db 'fasmg.zip',0    ; download to executable's folder
    cannotopenfile db 'Cannot download!',0
    errorzip       db 'Unexpected Error!',0
    zipmode        db 'wb',0
    downloadmsg    db "==== Download Successful! ====",0
    DownloadTitle  db "Status Report",0

;-------------------------------------------------------------------------------
section '.code' code readable executable
start:
     invoke WSAStartup, 0002h, wsadata
     println 'Trying to download fasmg.zip file...'
     stdcall httpdownloadfile
     invoke WSACleanup

.finished:
    invoke  ExitProcess,0

;-------------------------------------------------------------------------------
proc httpdownloadfile
local hINet:DWORD, hFile:DWORD, htmlfp:DWORD, dwRead:DWORD, buffer[1024]:BYTE
     invoke InternetOpen,TestApp,INTERNET_OPEN_TYPE_PRECONFIG,NULL,NULL,0
     mov [hINet], eax
     invoke InternetOpenUrl,[hINet],strURL,NULL,0, 0, 0
     mov [hFile], eax
     .if [hFile] <> 0
         cinvoke fopen,zipfile,zipmode
         mov [htmlfp], eax
         .if [htmlfp] = NULL
             pushad
             invoke MessageBox, NULL,cannotopenfile,errorzip,MB_SYSTEMMODAL+MB_OK+MB_ICONWARNING
             popad
             jmp .finish
         .endif
         .repeat
         invoke InternetReadFile,[hFile],addr buffer,1024,addr dwRead
         .if [dwRead] <> 0
             cinvoke fwrite,addr buffer,1024,1,[htmlfp]
         .endif
         .until [dwRead] = 0
         invoke MessageBox,NULL,downloadmsg,DownloadTitle,MB_SYSTEMMODAL+MB_OK
    .else
         invoke InternetCloseHandle,[hINet]
    .endif
.finish:
   cinvoke fclose,[htmlfp]
   ret
endp

;-------------------------------------------------------------------------------
section '.idata' import data readable writeable
library kernel32, 'KERNEL32.DLL',\
        user32,   'USER32.DLL',\
        comctl32, 'COMCTL32.DLL',\
        shell32,  'SHELL32.DLL',\
        advapi32, 'ADVAPI32.DLL',\
        comdlg32, 'COMDLG32.DLL',\
        gdi32,    'GDI32.DLL',\
        wsock32,  'WSOCK32.DLL',\
        wininet,  'WININET.DLL',\
        msvcrt,   'MSVCRT.DLL'

include 'api\kernel32.inc'
include 'api\user32.inc'
include 'api\comctl32.inc'
include 'api\shell32.inc'
include 'api\advapi32.inc'
include 'api\comdlg32.inc'
include 'api\gdi32.inc'
include 'api\wsock32.inc'

import  wininet,\
        InternetOpen, 'InternetOpenA',\
        InternetOpenUrl, 'InternetOpenUrlA',\
        InternetReadFile, 'InternetReadFile',\
        InternetCloseHandle, 'InternetCloseHandle'

import  msvcrt,\
        printf,    'printf',\
        fopen,     'fopen',\
        fwrite,    'fwrite',\
        fclose,    'fclose',\
        fprintf,   'fprintf',\
        fgets,     'fgets'

; end of file ==================================================================
