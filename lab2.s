            TTL Program Title for Listing Header Goes Here
;****************************************************************
;Descriptive comment header goes here.
;(What does the program do?)
;Name:  Arnav Gawas
;Date:  02/05/2026
;Class:  CMPE-250
;Section:  Lab Section X
;---------------------------------------------------------------
;Keil Simulator Template for KL05
;R. W. Melton
;August 21, 2025
;****************************************************************
;Assembler directives
            THUMB
            OPT    64  ;Turn on listing macro expansions
;****************************************************************
;EQUates
;Standard data masks
BYTE_MASK         EQU  0xFF
NIBBLE_MASK       EQU  0x0F
;Standard data sizes (in bits)
BYTE_BITS         EQU  8
NIBBLE_BITS       EQU  4
;Architecture data sizes (in bytes)
WORD_SIZE         EQU  4  ;Cortex-M0+
HALFWORD_SIZE     EQU  2  ;Cortex-M0+
;Architecture data masks
HALFWORD_MASK     EQU  0xFFFF
;Return                 
RET_ADDR_T_MASK   EQU  1  ;Bit 0 of ret. addr. must be
                          ;set for BX, BLX, or POP
                          ;mask in thumb mode
;---------------------------------------------------------------
;Vectors
VECTOR_TABLE_SIZE EQU 0x000000C0  ;KL05
VECTOR_SIZE       EQU 4           ;Bytes per vector
;---------------------------------------------------------------
;CPU CONTROL:  Control register
CONTROL_SPSEL_MASK   EQU  2
CONTROL_SPSEL_SHIFT  EQU  1
CONTROL_nPRIV_MASK   EQU  1
CONTROL_nPRIV_SHIFT  EQU  0
;---------------------------------------------------------------
;CPU PRIMASK:  Interrupt mask register
PRIMASK_PM_MASK   EQU  1
PRIMASK_PM_SHIFT  EQU  0
;---------------------------------------------------------------
;CPU PSR:  Program status register
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
;----------------------------------------------------------
;Stack
SSTACK_SIZE EQU  0x00000100
;****************************************************************
;Program
;Linker requires Reset_Handler
            AREA    MyCode,CODE,READONLY
            ENTRY
            EXPORT  Reset_Handler
Reset_Handler  PROC {}
main
;---------------------------------------------------------------
;Initialize registers
            BL      RegInit
;>>>>> begin main program code <<<<<

;------------------------------
; EQUs for multiplication shifts
;------------------------------
MUL2    EQU 1   ; multiply by 2 -> shift left 1
MUL3    EQU 1   ; multiply by 3 -> (x<<1)+x
MUL4    EQU 2   ; multiply by 4 -> shift left 2

;------------------------------
; Load P and Q
;------------------------------
            LDR     R1,=P
            LDR     R1,[R1]        ; R1 = P
            LDR     R2,=Q
            LDR     R2,[R2]        ; R2 = Q

;------------------------------
; Compute F = 3P + 2Q - 75
; Byte overflow [-128,127]
;------------------------------

            ; 3P = (P << 1) + P
            MOV     R3,R1
            LSL     R3,R3,#MUL3
            ADD     R3,R3,R1
            CMP     R3,#127
            BHI     F_OVF
            CMP     R3,#-128
            BLO     F_OVF

            ; 2Q = Q << 1
            MOV     R4,R2
            LSL     R4,R4,#MUL2
            CMP     R4,#127
            BHI     F_OVF
            CMP     R4,#-128
            BLO     F_OVF

            ; 3P + 2Q
            ADD     R3,R3,R4
            CMP     R3,#127
            BHI     F_OVF
            CMP     R3,#-128
            BLO     F_OVF

            ; -75
            LDR     R5,=const_F
            LDR     R5,[R5]
            SUB     R3,R3,R5
            CMP     R3,#127
            BHI     F_OVF
            CMP     R3,#-128
            BLO     F_OVF

            ; Store F
            LDR     R6,=F
            STR     R3,[R6]
            B       F_DONE

F_OVF:
            LDR     R6,=F
            MOV     R3,#0
            STR     R3,[R6]

F_DONE:

;------------------------------
; Compute G = 2P - 4Q + 63
; Use MSB and V flag
;------------------------------
            ; 2P
            MOV     R3,R1
            LSL     R3,R3,#MUL2
            AND     R3,R3,#0xFF00

            ; 4Q
            MOV     R4,R2
            LSL     R4,R4,#MUL4
            AND     R4,R4,#0xFF00

            ; 2P - 4Q
            SUBS    R3,R3,R4
            BVS     G_OVF

            ; +63
            LDR     R5,=const_G
            LDR     R5,[R5]
            ADDS    R3,R3,R5
            BVS     G_OVF

            ; Store G
            LDR     R6,=G
            STR     R3,[R6]
            B       G_DONE

G_OVF:
            LDR     R6,=G
            MOV     R3,#0
            STR     R3,[R6]

G_DONE:

;------------------------------
; Compute Result = F + G
;------------------------------
            LDR     R3,=F
            LDR     R3,[R3]
            LDR     R4,=G
            LDR     R4,[R4]
            ADD     R3,R3,R4
            CMP     R3,#127
            BHI     RESULT_OVF
            CMP     R3,#-128
            BLO     RESULT_OVF

            LDR     R5,=Result
            STR     R3,[R5]
            B       END_MAIN

RESULT_OVF:
            LDR     R5,=Result
            MOV     R3,#0
            STR     R3,[R5]

END_MAIN:
;>>>>>   end main program code <<<<<
            B       .
            ENDP    ;main

;---------------------------------------------------------------
RegInit     PROC  {}
;********************************************************************
;Initializes registers (template code kept intact)
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
            ENDP    ;RegInit

;****************************************************************
;Constants
            AREA    MyConst,DATA,READONLY
;>>>>> begin constants here <<<<<
const_F     DCD 75
const_G     DCD 63
;>>>>>   end constants here <<<<<

;****************************************************************
;Variables
            AREA    MyData,DATA,READWRITE
;>>>>> begin variables here <<<<<
P       DCD 5
Q       DCD 10
F       DCD 0
G       DCD 0
Result  DCD 0
;>>>>>   end variables here <<<<<
            END
