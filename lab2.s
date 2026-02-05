            TTL Program: Compute F, G, Result
;****************************************************************
;This program computes:
;  F = 3*var_P + 2*var_Q - 75
;  G = 2*var_P - 4*var_Q + 63
;  Result = F + G
;It stores all variables in memory and uses constants in ROM.
;Name:  <Your name here>
;Date:  <Date completed here>
;Class: CMPE-250
;Section: <Your lab section, day, time>
;****************************************************************

;Assembler directives
            THUMB
            OPT    64  ;Turn on listing macro expansions

;****************************************************************
;EQUates
BYTE_MASK         EQU  0xFF
NIBBLE_MASK       EQU  0x0F
BYTE_BITS         EQU  8
NIBBLE_BITS       EQU  4
WORD_SIZE         EQU  4
HALFWORD_SIZE     EQU  2
HALFWORD_MASK     EQU  0xFFFF
RET_ADDR_T_MASK   EQU  1
VECTOR_TABLE_SIZE EQU  0xC0
VECTOR_SIZE       EQU  4
SSTACK_SIZE       EQU  0x100

;****************************************************************
;Program
            AREA    MyCode,CODE,READONLY
            ENTRY
            EXPORT  Reset_Handler

Reset_Handler  PROC {}
main
;---------------------------------------------------------------
;Initialize registers
            BL      RegInit

;---------------------------------------------------------------
;---------------------------------------------------------------
;>>>>> begin main program code <<<<<

; Load var_P and var_Q
            LDR     R1,=var_P
            LDR     R1,[R1]           ; R1 = P
            LDR     R2,=var_Q
            LDR     R2,[R2]           ; R2 = Q

;===============================================================
; Compute F = 3P + 2Q - 75   (byte overflow by comparison)
;===============================================================

            MOV     R3,R1
            ADD     R3,R3,R1          ; 2P
            BL      CHECK_BYTE_F
            ADD     R3,R3,R1          ; 3P
            BL      CHECK_BYTE_F

            MOV     R4,R2
            ADD     R4,R4,R2          ; 2Q
            BL      CHECK_BYTE_F

            ADD     R3,R3,R4          ; 3P + 2Q
            BL      CHECK_BYTE_F

            LDR     R5,=Const_F
            LDR     R5,[R5]
            SUB     R3,R3,R5          ; -75
            BL      CHECK_BYTE_F

            LDR     R6,=F
            STR     R3,[R6]
            B       COMPUTE_G

F_OVERFLOW
            MOVS    R3,#0
            LDR     R6,=F
            STR     R3,[R6]

;===============================================================
; Compute G = 2P - 4Q + 63   (MSB arithmetic + V flag)
;===============================================================
COMPUTE_G
            LSLS    R3,R1,#24         ; P -> MSB
            LSLS    R4,R2,#24         ; Q -> MSB

            ADDS    R3,R3,R3          ; 2P
            BVS     G_OVERFLOW

            ADDS    R4,R4,R4          ; 2Q
            ADDS    R4,R4,R4          ; 4Q
            BVS     G_OVERFLOW

            SUBS    R3,R3,R4          ; 2P - 4Q
            BVS     G_OVERFLOW

            LDR     R5,=Const_G
            LDR     R5,[R5]
            LSLS    R5,R5,#24
            ADDS    R3,R3,R5          ; +63
            BVS     G_OVERFLOW

            LSRS    R3,R3,#24
            LDR     R6,=G
            STR     R3,[R6]
            B       COMPUTE_RESULT

G_OVERFLOW
            MOVS    R3,#0
            LDR     R6,=G
            STR     R3,[R6]

;===============================================================
; Compute Result = F + G   (byte overflow by comparison)
;===============================================================
COMPUTE_RESULT
            LDR     R3,=F
            LDR     R3,[R3]
            LDR     R4,=G
            LDR     R4,[R4]
            ADD     R3,R3,R4

            MOVS    R7,#127
            CMP     R3,R7
            BGT     RESULT_OVERFLOW
            MOVS    R7,#128
            RSBS    R7,R7,#0          ; -128
            CMP     R3,R7
            BLT     RESULT_OVERFLOW

            LDR     R5,=Result
            STR     R3,[R5]
            B       DONE

RESULT_OVERFLOW
            MOVS    R3,#0
            LDR     R5,=Result
            STR     R3,[R5]

DONE
            B       .

;---------------------------------------------------------------
; Byte overflow check subroutine for F
;---------------------------------------------------------------
CHECK_BYTE_F
            PUSH    {LR}
            MOVS    R7,#127
            CMP     R3,R7
            BGT     F_OVERFLOW
            MOVS    R7,#128
            RSBS    R7,R7,#0          ; -128
            CMP     R3,R7
            BLT     F_OVERFLOW
            POP     {PC}

;>>>>>   end main program code <<<<<

            ENDP

;---------------------------------------------------------------
RegInit     PROC  {}
;********************************************************************
;Initializes registers (template default)
;********************************************************************
            PUSH    {LR}
            LDR     R1,=0x11111111
            ADDS    R2,R1,R1
            ADDS    R3,R2,R1
            ADDS    R4,R3,R1
            ADDS    R5,R4,R1
            ADDS    R6,R5,R1
            ADDS    R7,R6,R1
            MOV     R8,R1
            ADD     R8,R8,R7
            MOV     R9,R1
            ADD     R9,R9,R8
            MOV     R10,R1
            ADD     R10,R10,R9
            MOV     R11,R1
            ADD     R11,R11,R10
            MOV     R12,R1
            ADD     R12,R12,R11
            MOV     R14,R2
            ADD     R14,R14,R12
            MOV     R0,R1
            ADD     R0,R0,R14
            MSR     APSR,R0
            LDR     R0,=0x05250821
            POP     {PC}
            ENDP  ;RegInit

;---------------------------------------------------------------
;Vector Table
            ALIGN
            AREA    RESET, DATA, READONLY
            EXPORT  __Vectors
            EXPORT  __Vectors_End
            EXPORT  __Vectors_Size
__Vectors 
            DCD    __initial_sp
            DCD    Reset_Handler
            SPACE  (VECTOR_TABLE_SIZE - (2 * VECTOR_SIZE))
__Vectors_End
__Vectors_Size  EQU     __Vectors_End - __Vectors

;---------------------------------------------------------------
;Constants
            AREA    MyConst,DATA,READONLY
Const_F     DCD 75
Const_G     DCD 63

;---------------------------------------------------------------
;Stack
            AREA    |.ARM.__at_0x1FFFFC00|,DATA,READWRITE,ALIGN=3
            EXPORT  __initial_sp
Stack_Mem   SPACE   SSTACK_SIZE
__initial_sp

;---------------------------------------------------------------
;Variables
            AREA    MyData,DATA,READWRITE
var_P       SPACE 4
var_Q       SPACE 4
F           SPACE 4
G           SPACE 4
Result      SPACE 4

            END
