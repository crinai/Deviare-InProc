 ;
 ; Copyright (C) 2010-2015 Nektra S.A., Buenos Aires, Argentina.
 ; All rights reserved. Contact: http://www.nektra.com
 ;
 ;
 ; This file is part of Deviare In-Proc
 ;
 ;
 ; Commercial License Usage
 ; ------------------------
 ; Licensees holding valid commercial Deviare In-Proc licenses may use this
 ; file in accordance with the commercial license agreement provided with the
 ; Software or, alternatively, in accordance with the terms contained in
 ; a written agreement between you and Nektra.  For licensing terms and
 ; conditions see http://www.nektra.com/licensing/.  For further information
 ; use the contact form at http://www.nektra.com/contact/.
 ;
 ;
 ; GNU General Public License Usage
 ; --------------------------------
 ; Alternatively, this file may be used under the terms of the GNU
 ; General Public License version 3.0 as published by the Free Software
 ; Foundation and appearing in the file LICENSE.GPL included in the
 ; packaging of this file.  Please review the following information to
 ; ensure the GNU General Public License version 3.0 requirements will be
 ; met: http://www.gnu.org/copyleft/gpl.html.
 ;
 ;

.386
.model flat, stdcall
.code

_TEXT SEGMENT

;---------------------------------------------------------------------------------

IMAGE_DOS_SIGNATURE            EQU    5A4Dh     ;MZ
IMAGE_NT_SIGNATURE             EQU    00004550h ;PE00
IMAGE_FILE_MACHINE_I386        EQU    14Ch
IMAGE_NT_OPTIONAL_HDR32_MAGIC  EQU    10Bh

ERROR_MOD_NOT_FOUND            EQU    126
ERROR_PROC_NOT_FOUND           EQU    127

UNICODE_STRING32 STRUCT 8
    _Length       WORD  ?
    MaximumLength WORD  ?
    Buffer        DWORD ?
UNICODE_STRING32 ENDS
   
LIST_ENTRY32 STRUCT
    Flink DWORD ?
    Blink DWORD ?
LIST_ENTRY32 ENDS

MODULE_ENTRY32 STRUCT
    InLoadOrderLinks           LIST_ENTRY32 <>
    InMemoryOrderLinks         LIST_ENTRY32 <>
    InInitializationOrderLinks LIST_ENTRY32 <>
    DllBase                    DWORD ?
    EntryPoint                 DWORD ?
    SizeOfImage                DWORD ?
    FullDllName                UNICODE_STRING32 <>
    BaseDllName                UNICODE_STRING32 <>
    Flags                      DWORD ?
    LoadCount                  WORD  ?
    ;structure continues but it is not needed
MODULE_ENTRY32 ENDS

IMAGE_DATA_DIRECTORY STRUCT
    VirtualAddress DWORD ?
    _Size          DWORD ?
IMAGE_DATA_DIRECTORY ENDS

IMAGE_DOS_HEADER STRUCT
    e_magic    WORD  ?
    e_cblp     WORD  ?
    e_cp       WORD  ?
    e_crlc     WORD  ?
    e_cparhdr  WORD  ?
    e_minalloc WORD  ?
    e_maxalloc WORD  ?
    e_ss       WORD  ?
    e_sp       WORD  ?
    e_csum     WORD  ?
    e_ip       WORD  ?
    e_cs       WORD  ?
    e_lfarlc   WORD  ?
    e_ovno     WORD  ?
    e_res      WORD  4 DUP (?)
    e_oemid    WORD  ?
    e_oeminfo  WORD  ?
    e_res2     WORD 10 DUP (?)
    e_lfanew   DWORD ?
IMAGE_DOS_HEADER ENDS

IMAGE_FILE_HEADER STRUCT
    Machine              WORD  ?
    NumberOfSections     WORD  ?
    TimeDateStamp        DWORD ?
    PointerToSymbolTable DWORD ?
    NumberOfSymbols      DWORD ?
    SizeOfOptionalHeader WORD  ?
    Characteristics      WORD  ?
IMAGE_FILE_HEADER ENDS

IMAGE_OPTIONAL_HEADER32 STRUCT
    Magic                       WORD  ?
    MajorLinkerVersion          BYTE  ?
    MinorLinkerVersion          BYTE  ?
    SizeOfCode                  DWORD ?
    SizeOfInitializedData       DWORD ?
    SizeOfUninitializedData     DWORD ?
    AddressOfEntryPoint         DWORD ?
    BaseOfCode                  DWORD ?
    BaseOfData                  DWORD ?
    ;NT additional fields
    ImageBase                   DWORD ?
    SectionAlignment            DWORD ?
    FileAlignment               DWORD ?
    MajorOperatingSystemVersion WORD  ?
    MinorOperatingSystemVersion WORD  ?
    MajorImageVersion           WORD  ?
    MinorImageVersion           WORD  ?
    MajorSubsystemVersion       WORD  ?
    MinorSubsystemVersion       WORD  ?
    Win32VersionValue           DWORD ?
    SizeOfImage                 DWORD ?
    SizeOfHeaders               DWORD ?
    CheckSum                    DWORD ?
    Subsystem                   WORD  ?
    DllCharacteristics          WORD  ?
    SizeOfStackReserve          DWORD ?
    SizeOfStackCommit           DWORD ?
    SizeOfHeapReserve           DWORD ?
    SizeOfHeapCommit            DWORD ?
    LoaderFlags                 DWORD ?
    NumberOfRvaAndSizes         DWORD ?
    DataDirectory               IMAGE_DATA_DIRECTORY 16 DUP (<>)
IMAGE_OPTIONAL_HEADER32 ENDS

IMAGE_NT_HEADERS32 STRUCT 
    Signature      DWORD ?
    FileHeader     IMAGE_FILE_HEADER <>
    OptionalHeader IMAGE_OPTIONAL_HEADER32 <>
IMAGE_NT_HEADERS32 ENDS

IMAGE_EXPORT_DIRECTORY STRUCT
    Characteristics       DWORD ?
    TimeDateStamp         DWORD ?
    MajorVersion          WORD  ?
    MinorVersion          WORD  ?
    _Name                 DWORD ?
    Base                  DWORD ?
    NumberOfFunctions     DWORD ?
    NumberOfNames         DWORD ?
    AddressOfFunctions    DWORD ?
    AddressOfNames        DWORD ?
    AddressOfNameOrdinals DWORD ?
IMAGE_EXPORT_DIRECTORY ENDS

GetPtr MACRO _reg:REQ, symbol:REQ, ofs:REQ
    DB   0E8h, 0, 0, 0, 0 ;call 0
    pop  _reg
    sub  _reg, OFFSET $ - (symbol + ofs) - 1
ENDM

;---------------------------------------------------------------------------------

PUBLIC GETMODULEANDPROCADDR_SECTION_START
PUBLIC GETMODULEANDPROCADDR_SECTION_END

ALIGN 4
GETMODULEANDPROCADDR_SECTION_START:

ALIGN 4
;BOOL __stdcall SimpleStrNICmpW(LPCWSTR string1, LPCWSTR string2, SIZE_T len)
SimpleStrNICmpW PROC
_string1$ = 8
_string2$ = 12
_len$ = 16
    push ebp
    mov  ebp, esp
    push ebx
    push ecx
    push esi
    push edi
    ;get string1 and check for null
    mov  esi, DWORD PTR _string1$[ebp]
    test esi, esi
    je   @@mismatch
    ;get string2 and check for null
    mov  edi, DWORD PTR _string2$[ebp]
    test edi, edi
    je   @@mismatch
    ;get length and check for zero
    mov  ecx, DWORD PTR _len$[ebp]
    test ecx, ecx
    je   @@afterloop
@@loop:
    ;compare letter
    mov  ax, WORD PTR [esi]
    mov  bx, WORD PTR [edi]
    cmp  bx, ax
    je   @@next
    ;check letters between A-Z and a-z
    cmp  ax, 41h
    jb   @@check2
    cmp  ax, 5Ah
    jbe  @@check2_test
@@check2:
    cmp  ax, 61h
    jb   @@mismatch
    cmp  ax, 7Ah
    ja   @@mismatch
@@check2_test:
    ;compare letter case insensitive
    or   ax, 20h
    or   bx, 20h
    cmp  bx, ax
    jne  @@mismatch
@@next:
    add  esi, 2
    add  edi, 2
    dec  ecx
    jne  @@loop
@@afterloop:
    cmp  WORD PTR [edi], 0
    jne  @@mismatch
    xor  eax, eax
    inc  eax
    jmp  @@end
@@mismatch:
    xor  eax, eax
@@end:
    pop  edi
    pop  esi
    pop  ecx
    pop  ebx
    mov  esp, ebp
    pop  ebp
    ret  0Ch ;pop parameters
SimpleStrNICmpW ENDP

ALIGN 4
;BOOL __stdcall SimpleStrCmpA(LPCSTR string1, LPCSTR string2)
SimpleStrCmpA PROC
_string1$ = 8
_string2$ = 12
    push ebp
    mov  ebp, esp
    push esi
    push edi
    ;get string1 and check for null
    mov  esi, DWORD PTR _string1$[ebp]
    test esi, esi
    je   @@mismatch
    ;get string2 and check for null
    mov  edi, DWORD PTR _string2$[ebp]
    test edi, edi
    je   @@mismatch
@@loop:
    ;compare letter
    mov  al, BYTE PTR [esi]
    cmp  al, BYTE PTR [edi]
    jne  @@mismatch
    cmp  al, 0
    je   @F
    inc  esi
    inc  edi
    jne  @@loop
@@: ;match
    xor  eax, eax
    inc  eax
    jmp  @@end
@@mismatch:
    xor  eax, eax
@@end:
    pop  edi
    pop  esi
    mov  esp, ebp
    pop  ebp
    ret  8h ;pop parameters
SimpleStrCmpA ENDP

ALIGN 4
;BOOL __stdcall CheckImageType(LPVOID lpBase, LPVOID *lplpNtHdr)
CheckImageType PROC
_lpBase$ = 8
_lplpNtHdr$ = 12
    push ebp
    mov  ebp, esp
    push ecx
    push edx
    ;get lpBase and check for null
    xor  eax, eax
    mov  ecx, DWORD PTR _lpBase$[ebp]
    test ecx, ecx
    je   @@end
    ;check dos header magic
    cmp  WORD PTR [ecx].IMAGE_DOS_HEADER.e_magic, IMAGE_DOS_SIGNATURE
    jne  @@end
    ;get header offset
    mov  edx, DWORD PTR [ecx].IMAGE_DOS_HEADER.e_lfanew
    add  ecx, edx ;ecx now points to NtHeader address
    ;check if we are asked to store NtHeader address 
    mov  edx, DWORD PTR _lplpNtHdr$[ebp]
    test edx, edx 
    je   @F
    mov  DWORD PTR [edx], ecx ;save it
@@: ;check image type
    cmp  WORD PTR [ecx].IMAGE_NT_HEADERS32.FileHeader.Machine, IMAGE_FILE_MACHINE_I386
    jne  @@end
    ;check magic
    cmp  WORD PTR [ecx].IMAGE_NT_HEADERS32.Signature, IMAGE_NT_SIGNATURE
    jne  @@end
    inc  eax
@@end:
    pop  edx
    pop  ecx
    mov  esp, ebp
    pop  ebp
    ret  8h ;pop parameters
CheckImageType ENDP

ALIGN 4
;LPVOID __stdcall GetModuleBaseAddress(LPCWSTR szDllNameW)
GetModuleBaseAddress PROC
_szDllNameW$ = 8
    push ebp
    mov  ebp, esp
    push ebx
    push ecx
    push esi
ASSUME FS:NOTHING
    mov  eax, DWORD PTR fs:[30h]
ASSUME FS:ERROR
    mov  eax, DWORD PTR [eax+0Ch] ;peb32+12 => pointer to PEB_LDR_DATA32
    test eax, eax
    je   @@not_found
    cmp  DWORD PTR [eax+4], 0h ;check PEB_LDR_DATA32.Initialize flag
    je   @@not_found
    mov  esi, eax
    add  esi, 0Ch ;esi has the first link (PEB_LDR_DATA32.InLoadOrderModuleList.Flink)
    mov  ebx, DWORD PTR [esi]
@@loop:
    cmp  ebx, esi
    je   @@not_found
    ;check if this is the entry we are looking for...
    movzx ecx, WORD PTR [ebx].MODULE_ENTRY32.BaseDllName._Length
    test ecx, ecx
    je   @@next
    shr  ecx, 1 ;divide by 2 because they are unicode chars
    mov  eax, DWORD PTR [ebx].MODULE_ENTRY32.BaseDllName.Buffer
    test eax, eax
    je   @@next
    push ecx                         ;push 3rd param (length)
    push DWORD PTR _szDllNameW$[ebp] ;push 2nd param (dll name to find)
    push eax                         ;push 1st param (string)
    CALL SimpleStrNICmpW
    test eax, eax
    je   @@next
    ;got it
    push 0
    push DWORD PTR [ebx].MODULE_ENTRY32.DllBase
    call CheckImageType
    test eax, eax
    je   @@next
    mov  eax, DWORD PTR [ebx].MODULE_ENTRY32.DllBase
    jmp  @@found
@@next:
    mov  ebx, DWORD PTR [ebx].MODULE_ENTRY32.InLoadOrderLinks.Flink ;go to the next entry
    jmp  @@loop
@@not_found:
    xor  eax, eax
@@found:
    pop  esi
    pop  ecx
    pop  ebx
    mov  esp, ebp
    pop  ebp
    ret  4h ;pop parameters
GetModuleBaseAddress ENDP

ALIGN 4
;LPVOID __stdcall GetProcedureAddress(LPVOID lpDllBase, LPCSTR szFuncNameA)
GetProcedureAddress PROC
_lpDllBase$ = 8
_szFuncNameA$ = 12
_lpNtHdr$ = -8
_nNamesCount$ = -12
_lpAddrOfNames$ = -16

    push ebp
    mov  ebp, esp
    sub  esp, 20h
    push ebx
    push ecx
    push esi
    ;check szFuncNameA for null
    cmp  DWORD PTR _szFuncNameA$[ebp], 0
    je   @@not_found
    ;get module base address and check for null
    mov  ecx, DWORD PTR _lpDllBase$[ebp]
    test ecx, ecx
    je   @@not_found
    ;get nt header
    lea  eax, DWORD PTR _lpNtHdr$[ebp]
    push eax
    push ecx
    call CheckImageType
    test eax, eax
    je   @@not_found
    ;check export data directory
    mov  eax, DWORD PTR _lpNtHdr$[ebp]
    cmp  DWORD PTR [eax].IMAGE_NT_HEADERS32.OptionalHeader.DataDirectory[0]._Size, 0
    je   @@not_found
    mov  esi, DWORD PTR [eax].IMAGE_NT_HEADERS32.OptionalHeader.DataDirectory[0].VirtualAddress
    test esi, esi
    je   @@not_found
    add  esi, DWORD PTR [ebp+8h]
    ;get the number of names
    mov  eax, DWORD PTR [esi].IMAGE_EXPORT_DIRECTORY.NumberOfNames
    mov  DWORD PTR _nNamesCount$[ebp], eax
    ;get the AddressOfNames
    mov  eax, DWORD PTR [esi].IMAGE_EXPORT_DIRECTORY.AddressOfNames
    add  eax, DWORD PTR [ebp+8h]
    mov  DWORD PTR _lpAddrOfNames$[ebp], eax
    ;main loop
    xor  ecx, ecx
@@loop:
    cmp  ecx, DWORD PTR _nNamesCount$[ebp]
    jae  @@not_found
    ;get exported name
    push DWORD PTR [ebp+0Ch]
    mov  eax, DWORD PTR _lpAddrOfNames$[ebp]
    mov  eax, DWORD PTR [eax]
    add  eax, DWORD PTR [ebp+8h]
    push eax
    call SimpleStrCmpA
    test eax, eax
    je   @@next
    ;got the function
    mov  eax, DWORD PTR [esi].IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals
    add  eax, DWORD PTR [ebp+8h]
    shl  ecx, 1
    add  eax, ecx
    movzx ecx, WORD PTR [eax] ;get the ordinal of this function
    mov  eax, DWORD PTR [esi].IMAGE_EXPORT_DIRECTORY.AddressOfFunctions
    add  eax, DWORD PTR [ebp+8h]
    shl  ecx, 2
    add  eax, ecx
    ;get the function address
    mov  eax, DWORD PTR [eax]
    add  eax, DWORD PTR [ebp+8h]
    jmp  @@found
@@next:
    add  DWORD PTR _lpAddrOfNames$[ebp], 4
    inc  ecx
    jmp  @@loop
@@not_found:
    xor  eax, eax
@@found:
    pop  esi
    pop  ecx
    pop  ebx
    mov  esp, ebp
    pop  ebp
    ret  8h ;pop parameters
GetProcedureAddress ENDP

GETMODULEANDPROCADDR_SECTION_END:

;---------------------------------------------------------------------------------

PUBLIC INJECTDLLINSUSPENDEDPROCESS_SECTION_START
PUBLIC INJECTDLLINSUSPENDEDPROCESS_SECTION_END

ALIGN 4
INJECTDLLINSUSPENDEDPROCESS_SECTION_START:

ALIGN 4
InjectDllInSuspendedProcess PROC
_GETPROCADDR_1                    EQU 0
_GETMODBASEADDR_1                 EQU 4
_DLLNAME_1                        EQU 8
_INITFUNCTION_1                   EQU 12
_ORIGINAL_ENTRYPOINT_1            EQU 16
_CHECKPOINTEVENT_1                EQU 20

_ntdll_hinst$ = -4
_ntcloseAddr$ = -8
_ntseteventAddr$ = -12
_kernel32_hinst$ = -16
_loadlibrarywAddr$ = -20
_freelibraryAddr$ = -24
_injectdll_hinst$ = -28
_initfunctionAddr$ = -32

    db   4 DUP (0h)                                                  ;offset 0: address of GetProcedureAddress
    db   4 DUP (0h)                                                  ;offset 4: address of GetModuleBaseAddress
    db   4 DUP (0h)                                                  ;offset 8: pointer to dll name
    db   4 DUP (0h)                                                  ;offset 12: pointer to initialize function
    db   4 DUP (0h)                                                  ;offset 16: original entrypoint
    db   4 DUP (0h)                                                  ;offset 20: checkpoint event
    jmp @@start

@@ntdll_dll:
    dw   'n','t','d','l','l','.','d','l','l', 0
@@ntclose:
    db   'NtClose', 0
@@ntsetevent:
    db   'NtSetEvent', 0
@@kernel32_dll:
    dw   'k','e','r','n','e','l','3','2','.','d','l','l', 0
@@loadlibraryw:
    db   'LoadLibraryW', 0
@@freelibrary:
    db   'FreeLibrary', 0

@@start:
    push ebp
    mov  ebp, esp
    sub  esp, 32

    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    pushfd

    ;get ntdll.dll base address
    GetPtr eax, @@ntdll_dll, 0
    push eax
    GetPtr eax, INJECTDLLINSUSPENDEDPROCESS_SECTION_START, _GETMODBASEADDR_1
    call DWORD PTR [eax]
    mov  DWORD PTR _ntdll_hinst$[ebp], eax
    test eax, eax
    jne  @F
    mov  eax, ERROR_MOD_NOT_FOUND
    jmp  @@fail

@@: ;get kernel32.dll base address
    GetPtr eax, @@kernel32_dll, 0
    push eax
    GetPtr eax, INJECTDLLINSUSPENDEDPROCESS_SECTION_START, _GETMODBASEADDR_1
    call DWORD PTR [eax]
    mov  DWORD PTR _kernel32_hinst$[ebp], eax
    test eax, eax
    jne  @F
    mov  eax, ERROR_MOD_NOT_FOUND
    jmp  @@fail

@@: GetPtr ebx, INJECTDLLINSUSPENDEDPROCESS_SECTION_START, _GETPROCADDR_1

    ;get address of NtClose
    GetPtr eax, @@ntclose, 0
    push eax
    push DWORD PTR _ntdll_hinst$[ebp]
    call DWORD PTR [ebx]
    mov  DWORD PTR _ntcloseAddr$[ebp], eax
    test eax, eax
    jne  @F
    mov  eax, ERROR_PROC_NOT_FOUND
    jmp  @@fail

@@: ;get address of NtSetEvent
    GetPtr eax, @@ntsetevent, 0
    push eax
    push DWORD PTR _ntdll_hinst$[ebp]
    call DWORD PTR [ebx]
    mov  DWORD PTR _ntseteventAddr$[ebp], eax
    test eax, eax
    jne  @F
    mov  eax, ERROR_PROC_NOT_FOUND
    jmp  @@fail

@@: ;get address of LoadLibraryW
    GetPtr eax, @@loadlibraryw, 0
    push eax
    push DWORD PTR _kernel32_hinst$[ebp]
    call DWORD PTR [ebx]
    mov  DWORD PTR _loadlibrarywAddr$[ebp], eax
    test eax, eax
    jne  @F
    mov  eax, ERROR_PROC_NOT_FOUND
    jmp  @@fail

@@: ;get address of FreeLibrary
    GetPtr eax, @@freelibrary, 0
    push eax
    push DWORD PTR _kernel32_hinst$[ebp]
    call DWORD PTR [ebx]
    mov  DWORD PTR _freelibraryAddr$[ebp], eax
    test eax, eax
    jne  @F
    mov  eax, ERROR_PROC_NOT_FOUND
    jmp  @@fail

@@: ;load library
    GetPtr eax, INJECTDLLINSUSPENDEDPROCESS_SECTION_START, _DLLNAME_1
    push DWORD PTR [eax]
    call DWORD PTR _loadlibrarywAddr$[ebp]
    mov  DWORD PTR _injectdll_hinst$[ebp], eax
    test eax, eax
    jne  @F
    ;get last error
ASSUME FS:NOTHING
    mov  eax, DWORD PTR fs:[18h]
ASSUME FS:ERROR
    mov  eax, DWORD PTR [eax+34h]
    jmp  @@fail

@@: ;call init function if provided
    GetPtr eax, INJECTDLLINSUSPENDEDPROCESS_SECTION_START, _INITFUNCTION_1
    mov  eax, DWORD PTR [eax]
    test eax, eax
    je   @@done

    ;get init function address
    push eax
    push DWORD PTR _injectdll_hinst$[ebp]
    GetPtr eax, INJECTDLLINSUSPENDEDPROCESS_SECTION_START, _GETPROCADDR_1
    call DWORD PTR [eax]
    test eax, eax
    jne  @F

    ;free library if init function was not found
    push DWORD PTR _injectdll_hinst$[ebp]
    call DWORD PTR _freelibraryAddr$[ebp]
    mov  eax, ERROR_PROC_NOT_FOUND
    jmp  @@fail

@@: ;call init function
    CALL eax
    test eax, eax
    je   @@done
    ;if init function returns an error, first free library
    push eax ;save error code
    push DWORD PTR _injectdll_hinst$[ebp]
    call DWORD PTR _freelibraryAddr$[ebp]
    pop  eax ;restore error code
    jmp  @@fail

@@done:
    ;set checkpoint event
    GetPtr eax, INJECTDLLINSUSPENDEDPROCESS_SECTION_START, _CHECKPOINTEVENT_1
    mov  ebx, DWORD PTR [eax]
    test ebx, ebx
    je   @F
    push 0
    push ebx
    call DWORD PTR _ntseteventAddr$[ebp]
    ;close continue event
    push ebx
    call DWORD PTR _ntcloseAddr$[ebp]

@@: popfd
    pop  edi
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    pop  eax
    add  esp, 32
    pop  ebp

    ;jmp to original address
    push eax
    push eax
    GetPtr eax, INJECTDLLINSUSPENDEDPROCESS_SECTION_START, _ORIGINAL_ENTRYPOINT_1
    mov  eax, DWORD PTR [eax]
    mov  DWORD PTR [esp+4], eax
    pop  eax
    ret

@@fail:
    ;on error, quit
    popfd
    pop  edi
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    add  esp, 32+4 ;skip popping eax
    pop  ebp

    ;return and exit process
    ret  4h
InjectDllInSuspendedProcess ENDP

INJECTDLLINSUSPENDEDPROCESS_SECTION_END:

;---------------------------------------------------------------------------------

PUBLIC INJECTDLLINRUNNINGPROCESS_SECTION_START
PUBLIC INJECTDLLINRUNNINGPROCESS_SECTION_END

ALIGN 4
INJECTDLLINRUNNINGPROCESS_SECTION_START:

ALIGN 4
InjectDllInRunningProcess PROC
_GETPROCADDR_2                    EQU 0
_GETMODBASEADDR_2                 EQU 4
_DLLNAME_2                        EQU 8
_INITFUNCTION_2                   EQU 12
_READYEVENT_2                     EQU 16
_CONTINUEEVENT_2                  EQU 20

_ntdll_hinst$ = -4
_ntcloseAddr$ = -8
_ntseteventAddr$ = -16
_ntwaitformultipleobjectsAddr$ = -24
_kernel32_hinst$ = -28
_loadlibrarywAddr$ = -32
_freelibraryAddr$ = -16
_injectdll_hinst$ = -36
_initfunctionAddr$ = -40

    db   4 DUP (0h)                                                  ;offset 0: address of GetProcedureAddress
    db   4 DUP (0h)                                                  ;offset 4: address of GetModuleBaseAddress
    db   4 DUP (0h)                                                  ;offset 8: pointer to dll name
    db   4 DUP (0h)                                                  ;offset 12: pointer to initialize function
    db   4 DUP (0h)                                                  ;offset 16: ready event handle
    db   4 DUP (0h)                                                  ;offset 20: continue event handle
    jmp @@start

@@ntdll_dll:
    dw   'n','t','d','l','l','.','d','l','l', 0
@@ntclose:
    db   'NtClose', 0
@@ntsetevent:
    db   'NtSetEvent', 0
@@ntwaitformultipleobjects:
    db   'NtWaitForMultipleObjects', 0
@@kernel32_dll:
    dw   'k','e','r','n','e','l','3','2','.','d','l','l', 0
@@loadlibraryw:
    db   'LoadLibraryW', 0
@@freelibrary:
    db   'FreeLibrary', 0

@@start:
    push ebp
    mov  ebp, esp
    sub  esp, 44

    push ebx
    push ecx
    push edx
    push esi
    push edi
    pushfd

    ;get ntdll.dll base address
    GetPtr eax, @@ntdll_dll, 0
    push eax
    GetPtr eax, INJECTDLLINRUNNINGPROCESS_SECTION_START, _GETMODBASEADDR_2
    call DWORD PTR [eax]
    mov  DWORD PTR _ntdll_hinst$[ebp], eax
    test eax, eax
    jne  @F
    mov  eax, ERROR_MOD_NOT_FOUND
    jmp  @@exit

@@: ;get kernel32.dll base address
    GetPtr eax, @@kernel32_dll, 0
    push eax
    GetPtr eax, INJECTDLLINRUNNINGPROCESS_SECTION_START, _GETMODBASEADDR_2
    call DWORD PTR [eax]
    mov  DWORD PTR _kernel32_hinst$[ebp], eax
    test eax, eax
    jne  @F
    mov  eax, ERROR_MOD_NOT_FOUND
    jmp  @@exit

@@: GetPtr ebx, INJECTDLLINRUNNINGPROCESS_SECTION_START, _GETPROCADDR_2

    ;get address of NtClose
    GetPtr eax, @@ntclose, 0
    push eax
    push DWORD PTR _ntdll_hinst$[ebp]
    call DWORD PTR [ebx]
    mov  DWORD PTR _ntcloseAddr$[ebp], eax
    test eax, eax
    jne  @F
    mov  eax, ERROR_PROC_NOT_FOUND
    jmp  @@exit

@@: ;get address of NtSetEvent
    GetPtr eax, @@ntsetevent, 0
    push eax
    push DWORD PTR _ntdll_hinst$[ebp]
    call DWORD PTR [ebx]
    mov  DWORD PTR _ntseteventAddr$[ebp], eax
    test eax, eax
    jne  @F
    mov  eax, ERROR_PROC_NOT_FOUND
    jmp  @@exit

@@: ;get address of NtWaitForMultipleObjects
    GetPtr eax, @@ntwaitformultipleobjects, 0
    push eax
    push DWORD PTR _ntdll_hinst$[ebp]
    call DWORD PTR [ebx]
    mov  DWORD PTR _ntwaitformultipleobjectsAddr$[ebp], eax
    test eax, eax
    jne  @F
    mov  eax, ERROR_PROC_NOT_FOUND
    jmp  @@exit

@@: ;get address of LoadLibraryW
    GetPtr eax, @@loadlibraryw, 0
    push eax
    push DWORD PTR _kernel32_hinst$[ebp]
    call DWORD PTR [ebx]
    mov  DWORD PTR _loadlibrarywAddr$[ebp], eax
    test eax, eax
    jne  @F
    mov  eax, ERROR_PROC_NOT_FOUND
    jmp  @@exit

@@: ;get address of FreeLibrary
    GetPtr eax, @@freelibrary, 0
    push eax
    push DWORD PTR _kernel32_hinst$[ebp]
    call DWORD PTR [ebx]
    mov  DWORD PTR _freelibraryAddr$[ebp], eax
    test eax, eax
    jne  @F
    mov  eax, ERROR_PROC_NOT_FOUND
    jmp  @@exit

@@: ;wait for ready event ?
    GetPtr eax, INJECTDLLINRUNNINGPROCESS_SECTION_START, _READYEVENT_2
    cmp  DWORD PTR [eax], 0
    je   @F
    push 0 ;NULL
    push 0 ;FALSE
    push 1 ;WaitAnyObject
    push eax
    push 1
    call DWORD PTR _ntwaitformultipleobjectsAddr$[ebp]

    ;close ready event
    GetPtr eax, INJECTDLLINRUNNINGPROCESS_SECTION_START, _READYEVENT_2
    push DWORD PTR [eax]
    call DWORD PTR _ntcloseAddr$[ebp]

@@: ;load library
    GetPtr eax, INJECTDLLINRUNNINGPROCESS_SECTION_START, _DLLNAME_2
    push DWORD PTR [eax]
    call DWORD PTR _loadlibrarywAddr$[ebp]
    mov  DWORD PTR _injectdll_hinst$[ebp], eax
    test eax, eax
    jne  @F
    ;get last error
ASSUME FS:NOTHING
    mov  eax, DWORD PTR fs:[18h]
ASSUME FS:ERROR
    mov  eax, DWORD PTR [eax+34h]
    jmp  @@exit

@@: ;call init function if provided
    GetPtr eax, INJECTDLLINRUNNINGPROCESS_SECTION_START, _INITFUNCTION_2
    mov  eax, DWORD PTR [eax]
    test eax, eax
    je   @@done

    ;get init function address
    push eax
    push DWORD PTR _injectdll_hinst$[ebp]
    GetPtr eax, INJECTDLLINRUNNINGPROCESS_SECTION_START, _GETPROCADDR_2
    call DWORD PTR [eax]
    test eax, eax
    jne  @F

    ;free library if init function was not found
    push DWORD PTR _injectdll_hinst$[ebp]
    call DWORD PTR _freelibraryAddr$[ebp]
    mov  eax, ERROR_PROC_NOT_FOUND
    jmp  @@exit

@@: ;call init function
    CALL eax
    test eax, eax
    je   @@done
    ;if init function returns an error, first free library
    push eax ;save error code
    push DWORD PTR _injectdll_hinst$[ebp]
    call DWORD PTR _freelibraryAddr$[ebp]
    pop eax  ;restore error code
    jmp  @@exit

@@done:
    ;set continue event
    GetPtr eax, INJECTDLLINRUNNINGPROCESS_SECTION_START, _CONTINUEEVENT_2
    mov  ebx, DWORD PTR [eax]
    test ebx, ebx
    je   @F
    push 0
    push ebx
    call DWORD PTR _ntseteventAddr$[ebp]

    ;close continue event
    push ebx
    call DWORD PTR _ntcloseAddr$[ebp]

@@: ;no error
    xor  eax, eax

@@exit:
    popfd
    pop  edi
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx

    add  esp, 44
    pop  ebp
    ;return and exit thread
    ret  4h
InjectDllInRunningProcess ENDP

INJECTDLLINRUNNINGPROCESS_SECTION_END:

;---------------------------------------------------------------------------------

PUBLIC WAITFOREVENTATSTARTUP_SECTION_START
PUBLIC WAITFOREVENTATSTARTUP_SECTION_END

ALIGN 4
WAITFOREVENTATSTARTUP_SECTION_START:

ALIGN 4
WaitForEventAtStartup PROC
_GETPROCADDR_3                    EQU 0
_GETMODBASEADDR_3                 EQU 4
_READYEVENT_3                     EQU 8
_CONTINUEEVENT_3                  EQU 12
_CONTROLLERPROC_3                 EQU 16
_ORIGINAL_ENTRYPOINT_3            EQU 20

_ntdll_hinst$ = -4
_ntcloseAddr$ = -8
_ntseteventAddr$ = -12
_ntwaitformultipleobjectsAddr$ = -16

    db   4 DUP (0h)                                                  ;offset 0: address of GetProcedureAddress
    db   4 DUP (0h)                                                  ;offset 4: address of GetModuleBaseAddress
    db   4 DUP (0h)                                                  ;offset 8: ready event handle
    db   4 DUP (0h)                                                  ;offset 12: continue event handle
    db   4 DUP (0h)                                                  ;offset 16: controller process handle
    db   4 DUP (0h)                                                  ;offset 20: original entrypoint
    jmp  @@start

@@ntdll_dll:
    dw   'n','t','d','l','l','.','d','l','l', 0
@@ntclose:
    db   'NtClose', 0
@@ntsetevent:
    db   'NtSetEvent', 0
@@ntwaitformultipleobjects:
    db   'NtWaitForMultipleObjects', 0

@@start:
    push ebp
    mov  ebp, esp
    sub  esp, 20

    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    pushfd

    ;get ntdll.dll base address
    GetPtr eax, @@ntdll_dll, 0
    push eax
    GetPtr eax, WAITFOREVENTATSTARTUP_SECTION_START, _GETMODBASEADDR_3
    call DWORD PTR [eax]
    test eax, eax
    je   @@done
    mov  DWORD PTR _ntdll_hinst$[ebp], eax

    GetPtr ebx, WAITFOREVENTATSTARTUP_SECTION_START, _GETPROCADDR_3

    ;get address of NtClose
    GetPtr eax, @@ntclose, 0
    push eax
    push DWORD PTR _ntdll_hinst$[ebp]
    call DWORD PTR [ebx]
    test eax, eax
    je   @@done
    mov  DWORD PTR _ntcloseAddr$[ebp], eax

    ;get address of NtSetEvent
    GetPtr eax, @@ntsetevent, 0
    push eax
    push DWORD PTR _ntdll_hinst$[ebp]
    call DWORD PTR [ebx]
    test eax, eax
    je   @@done
    mov  DWORD PTR _ntseteventAddr$[ebp], eax

    ;get address of NtWaitForMultipleObjects
    GetPtr eax, @@ntwaitformultipleobjects, 0
    push eax
    push DWORD PTR _ntdll_hinst$[ebp]
    call DWORD PTR [ebx]
    test eax, eax
    je   @@done
    mov  DWORD PTR _ntwaitformultipleobjectsAddr$[ebp], eax

    ;set ready event
    GetPtr eax, WAITFOREVENTATSTARTUP_SECTION_START, _READYEVENT_3
    mov  ebx, DWORD PTR [eax]
    push 0
    push ebx
    call DWORD PTR _ntseteventAddr$[ebp]

    ;close ready event
    push ebx
    call DWORD PTR _ntcloseAddr$[ebp]

    ;wait for continue event or controller process termination
    GetPtr eax, WAITFOREVENTATSTARTUP_SECTION_START, _CONTINUEEVENT_3
    push 0 ;NULL
    push 0 ;FALSE
    push 1 ;WaitAnyObject
    push eax
    push 2
    call DWORD PTR _ntwaitformultipleobjectsAddr$[ebp]

    ;close continue event
    GetPtr eax, WAITFOREVENTATSTARTUP_SECTION_START, _CONTINUEEVENT_3
    push DWORD PTR [eax]
    call DWORD PTR _ntcloseAddr$[ebp]

    ;close controller process
    GetPtr eax, WAITFOREVENTATSTARTUP_SECTION_START, _CONTROLLERPROC_3
    push DWORD PTR [eax]
    call DWORD PTR _ntcloseAddr$[ebp]

@@done:
    popfd
    pop  edi
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    pop  eax
    pop  ebp

    ;jmp to original address
    push eax
    push eax
    GetPtr eax, WAITFOREVENTATSTARTUP_SECTION_START, _ORIGINAL_ENTRYPOINT_3
    mov  eax, DWORD PTR [eax]
    mov  DWORD PTR [esp+4], eax
    pop  eax
    ret
WaitForEventAtStartup ENDP

WAITFOREVENTATSTARTUP_SECTION_END:

;---------------------------------------------------------------------------------

_TEXT ENDS

END
