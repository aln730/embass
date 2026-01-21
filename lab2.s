        AREA    ExpressionCalc, CODE, READONLY
        EXPORT  __main

DIV4    EQU     2
MULT2   EQU     1

__main
        MOV     R0, #45
        MOV     R1, #6
        MOV     R2, #13
        MOV     R3, #7
        MOV     R4, #65
        MOV     R5, #33

        RSBS    R6, R2, #0
        ASR     R6, R6, #DIV4

        LSL     R7, R3, #MULT2
        ADD     R7, R7, R3

        ADD     R0, R0, R1
        ADD     R0, R0, R6
        SUB     R0, R0, R7
        SUB     R0, R0, R4
        ADD     R0, R0, R5

        B       .

