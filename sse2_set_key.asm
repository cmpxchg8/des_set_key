;/**
; *  The MIT License:
; *
; *  Copyright (c) 2005, 2008 Kevin Devine
; *
; *  Permission is hereby granted,  free of charge,  to any person obtaining a copy
; *  of this software and associated documentation files (the "Software"),  to deal
; *  in the Software without restriction,  including without limitation the rights
; *  to use,  copy,  modify,  merge,  publish,  distribute,  sublicense,  and/or sell
; *  copies of the Software,  and to permit persons to whom the Software is
; *  furnished to do so,  subject to the following conditions:
; *
; *  The above copyright notice and this permission notice shall be included in
; *  all copies or substantial portions of the Software.
; *
; *  THE SOFTWARE IS PROVIDED "AS IS",  WITHOUT WARRANTY OF ANY KIND,  EXPRESS OR
; *  IMPLIED,  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,  DAMAGES OR OTHER
; *  LIABILITY,  WHETHER IN AN ACTION OF CONTRACT,  TORT OR OTHERWISE,  ARISING FROM,
; *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
; *  THE SOFTWARE.
; */
.686
.xmm
.model flat, stdcall

DES_set_key proto C :dword,:dword

DES_key_schedule STRUCT
  key_data db 128 dup (?)
DES_key_schedule ENDS

.data?

align 16
index_one    DES_key_schedule 256 dup (<>)
align 16
index_two    DES_key_schedule 256 dup (<>)
align 16
index_three  DES_key_schedule 256 dup (<>)
align 16
index_four   DES_key_schedule 256 dup (<>)
align 16
index_five   DES_key_schedule 256 dup (<>)
align 16
index_six    DES_key_schedule 256 dup (<>)
align 16
index_seven  DES_key_schedule 256 dup (<>)
align 16
index_eight  DES_key_schedule 256 dup (<>)

public g_schedules
public _g_schedules

.data

_g_schedules label dword
g_schedules dd offset index_one
            dd offset index_two
            dd offset index_three
            dd offset index_four
            dd offset index_five
            dd offset index_six
            dd offset index_seven
            dd offset index_eight
            
key_indexes dd 8 dup (?)

i_one       equ key_indexes+4*0
i_two       equ key_indexes+4*1
i_three     equ key_indexes+4*2
i_four      equ key_indexes+4*3
i_five      equ key_indexes+4*4
i_six       equ key_indexes+4*5
i_seven     equ key_indexes+4*6
i_eight     equ key_indexes+4*7

.code

public init_subkeys
public _init_subkeys

_init_subkeys:
init_subkeys proc C uses esi edi ebx
    local ks      :DES_key_schedule
    local key[8]  :byte

    lea  edi, [key]
    xor  eax, eax
    stosd
    stosd
    xor  esi, esi
    
    .while esi < 8
    
      mov  edi, g_schedules[esi*4]
      xor  ebx, ebx 
      
      .while ebx < 256
        lea  ecx, [key]
        mov  byte ptr[ecx+esi], bl

        invoke DES_set_key, ecx, edi

        add  edi, sizeof (DES_key_schedule)
        inc  ebx
      .endw
      lea  ecx, [key]
      mov  byte ptr[ecx+esi], 0
      inc  esi
    .endw
    ret
init_subkeys endp

public sse2_DES_set_key
public _sse2_DES_set_key

_sse2_DES_set_key:
sse2_DES_set_key proc C uses esi ebx edi ebp key:dword, ks:dword

    mov   esi, [ks]
    mov   edi, [ks]

    pxor  xmm0, xmm0
    pxor  xmm1, xmm1
    pxor  xmm2, xmm2
    pxor  xmm3, xmm3

    mov   ebp, [key]
    add   edi, 64

    pxor  xmm4, xmm4
    pxor  xmm5, xmm5
    pxor  xmm6, xmm6
    pxor  xmm7, xmm7

    irp i, <0, 2, 4, 6>

      xor  eax, eax
      mov  al,  byte ptr[ebp+i]

      xor  ebx, ebx
      mov  bl,  byte ptr[ebp+i+1]

      mov  ecx, [g_schedules+4*i]
      mov  edx, [g_schedules+4*i+4]

      rol  eax, 7
      rol  ebx, 7

      add  ecx, eax
      add  edx, ebx

      por  xmm0, [ecx+16*0]
      por  xmm1, [ecx+16*1]
      por  xmm0, [edx+16*0]
      por  xmm1, [edx+16*1]

      por  xmm2, [ecx+16*2]
      por  xmm3, [ecx+16*3]
      por  xmm2, [edx+16*2]
      por  xmm3, [edx+16*3]

      por  xmm4, [ecx+16*4]
      por  xmm5, [ecx+16*5]
      por  xmm4, [edx+16*4]
      por  xmm5, [edx+16*5]

      por  xmm6, [ecx+16*6]
      por  xmm7, [ecx+16*7]
      por  xmm6, [edx+16*6]
      por  xmm7, [edx+16*7]
    endm

    movdqu  [esi+16*0], xmm0
    movdqu  [edi+16*0], xmm4

    movdqu  [esi+16*1], xmm1
    movdqu  [edi+16*1], xmm5

    movdqu  [esi+16*2], xmm2
    movdqu  [edi+16*2], xmm6

    movdqu  [esi+16*3], xmm3
    movdqu  [edi+16*3], xmm7
    
    ret
sse2_DES_set_key endp

    end
