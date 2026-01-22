;****************************************************************
; TTL Program Title for Listing Header Goes Here
;****************************************************************
; Descriptive comment header goes here.
; (What does the program do?)
; Name:  <Your name here>
; Date:  <Date completed here>
; Class:  CMPE-250
; Section:  <Your lab section, day, and time here>
;---------------------------------------------------------------
; Keil Simulator Template for KL05
; R. W. Melton
; August 21, 2025
;****************************************************************

; Assembler directives
            THUMB
            OPT    64      ; Turn on listing macro expansions

;****************************************************************
; EQUates
; Standard data masks
BYTE_MASK         EQU  0xFF
NIBBLE_MASK       EQU  0x0F
; Standard data sizes (in bits)
BYTE_BITS         EQU  8
NIBBLE_BITS       EQU  4
; Architecture data sizes (in bytes)
WORD_SIZE         EQU  4
HALFWORD_SIZE     EQU  2
; Architecture data masks
HALFWORD_MASK     EQU  0xFFFF
; Return
RET_ADDR_T_MASK   EQU  1

;---------------------------------------------------------------
; Vectors
VECTOR_TABLE_SIZE EQU 0x000000C0
VECTOR_SIZE       EQU 4

;---------------------------------------------------------------
; CPU CONTROL: Control register
CONTROL_SPSEL_MASK   EQU  2
CONTROL_SPSEL_SHIFT  EQU  1
CONTROL_nPRIV_MASK   EQU  1
CONTROL_nPRIV_SHIFT  EQU  0

;---------------------------------------------------------------
; CPU PRIMASK
PRIMASK_PM_MASK   EQU  1
PRIMASK_PM_SHIFT  EQU  0

;---------------------------------------------------------------
; CPU PSR Masks
APSR_MASK     EQU  0xF0000000
APSR_SHIFT    EQU  28
APSR_N_MASK   EQU  0x80000000
APSR_N_SHIFT  EQU  31
APSR_Z_MASK   EQU  0x40000000
APSR_Z_SHIFT  EQU  30
APSR_C_MASK   EQU  0x20000000
APSR_C_SHIFT  EQU  29
APSR_V_MASK   EQU  0x10000000
APSR_V_SHIFT  EQU  28

EPSR_MASK     EQU  0x01000000
EPSR_SHIFT    EQU  24
EPSR_T_MASK   EQU  0x01000000
EPSR_T_SHIFT  EQU  24

IPSR_MASK             EQU  0x0000003F
IPSR_SHIFT            EQU  0
IPSR_EXCEPTION_MASK   EQU  0x0000003F
IPSR_EXCEPTION_SHIFT  EQU  0

PSR_N_MASK           EQU  APSR_N_MASK
PSR_N_SHIFT          EQU  APSR_N_SHIFT
PSR_Z_MASK           EQU  APSR_Z_MASK
PSR_Z_SHIFT          EQU  APSR_Z_SHIFT
PSR_C_MASK           EQU  APSR_C_MASK
PSR_C_SHIFT          EQU  APSR_C_SHIFT
PSR_V_MASK           EQU  APSR_V_MASK
PSR_V_SHIFT          EQU  APSR_V_SHIFT
PSR_T_MASK           EQU  EPSR_T_MASK
PSR_T_SHIFT          EQU  EPSR_T_SHIFT
PSR_EXCEPTION_MASK   EQU  IPSR_EXCEPTION_MASK
PSR_EXCEPTION_SHIFT  EQU  IPSR_EXCEPTION_SHIFT

;---------------------------------------------------------------
; Stack
SSTACK_SIZE EQU  0x00000100

;****************************************************************
; Program
; Linker requires Reset_Handler
            AREA    MyCode,CODE,READONLY
            ENTRY
            EXPORT  Reset_Handler

Reset_Handler  PROC
            ; Initialize registers
            BL      RegInit
            ; Call expression calculator
            BL      __main
            ; Stay here indefinitely
            B       .
            ENDP

;---------------------------------------------------------------
RegInit     PROC
;********************************************************************
; Initializes registers
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
            ENDP

;****************************************************************
; Expression Calculator
;****************************************************************
            AREA    ExpressionCalc, CODE, READONLY
            EXPORT  __main

DIV4        EQU     2
MULT2       EQU     1

__main
        ; Initialize operands
        MOV     R0, #45
        MOV     R1, #6
        MOV     R2, #13
        MOV     R3, #7
        MOV     R4, #65
        MOV     R5, #33

        ; Compute -R2 / DIV4
        RSBS    R6, R2, #0      ; R6 = -R2
        ASR     R6, R6, #DIV4   ; R6 = R6 >> DIV4 (arithmetic shift)

        ; Compute R3 * MULT2 + R3
        LSL     R7, R3, #MULT2  ; R7 = R3 << MULT2
        ADD     R7, R7, R3      ; R7 = R7 + R3

        ; Compute final expression: R0 + R1 + R6 - R7 - R4 + R5
        ADD     R0, R0, R1
        ADD     R0, R0, R6
        SUB     R0, R0, R7
        SUB     R0, R0, R4
        ADD     R0, R0, R5

        ; Infinite loop to hold result
        B       .

;****************************************************************
; Vector Table
;****************************************************************
            AREA    RESET, DATA, READONLY
            EXPORT  __Vectors
            EXPORT  __Vectors_End
            EXPORT  __Vectors_Size

__Vectors 
            DCD    __initial_sp       ; 00:end of stack
            DCD    Reset_Handler      ; reset vector
            SPACE  (VECTOR_TABLE_SIZE - (2 * VECTOR_SIZE))

__Vectors_End
__Vectors_Size  EQU     __Vectors_End - __Vectors
            ALIGN

;****************************************************************
; System Stack
;****************************************************************
            AREA    |.ARM.__at_0x1FFFFC00|,DATA,READWRITE,ALIGN=3
            EXPORT  __initial_sp

Stack_Mem   SPACE   SSTACK_SIZE
__initial_sp
            END
