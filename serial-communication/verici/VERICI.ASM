
 P=16f84a
 _A = 32
 _X = 33
F2_SOF equ $ 
F2_EOF equ $ 
F1_SOF equ $ 
F1_000004 equ $ 
	Bsf STATUS,5
ram_bank = 1
	Clrf TRISA
	Bcf STATUS,5
ram_bank = 0
	Clrf PORTA
F1_000005 equ $ 
	Movlw 3+
	Bsf STATUS,5
ram_bank = 1
	Movwf TRISB
	Bcf STATUS,5
ram_bank = 0
	Clrf PORTB
F1_000010 equ $ 
	Clrf _A
F1_000011 equ $ 
	Clrf _X
F1_000012 equ $ 
BASLA
F1_000016 equ $ 
	Btfss PORTB,0
	Goto bc@LL2
F1_000017 equ $ 
	Movlw 10
	Movwf _A
F1_000018 equ $ 
	Movlw 1
	Movwf _X
fr@lb4
	Movlw 4
	Subwf _X,W
	Btfsc STATUS,0
	Goto nx@lb5
F1_000019 equ $ 
	Movlw PORTA
	Movwf GEN
	Movlw 1
	Movwf GENH
	Clrf PP5H
	Movlw 84
	Movwf PP5
	Clrf GEN3H
	Clrf GEN3
	Movlw 32
	Movwf BPFH
	Movlw 84
	Call Serout
	Movlw 88
	Call Serout
	Movlw 82
	Call Serout
	Movlw 88
	Call Serout
	Movf _A,W
	Call Serout
F1_000020 equ $ 
	Incf _X,F
	Btfss STATUS,2
	Goto fr@lb4
nx@lb5
	Goto bc@LL5
bc@LL2
F1_000021 equ $ 
F1_000022 equ $
	Clrf _A
F1_000023 equ $ 
bc@LL5
F1_000025 equ $ 
	Btfss PORTB,1
	Goto bc@LL7
F1_000026 equ $ 
	Movlw 20
	Movwf _A
F1_000027 equ $ 
	Movlw 1
	Movwf _X
fr@lb9
	Movlw 4
	Subwf _X,W
	Btfsc STATUS,0
	Goto nx@lb10
F1_000028 equ $ 
	Movlw PORTA
	Movwf GEN
	Movlw 1
	Movwf GENH
	Clrf PP5H
	Movlw 84
	Movwf PP5
	Clrf GEN3H
	Clrf GEN3
	Movlw 32
	Movwf BPFH
	Movlw 84
	Call Serout
	Movlw 88
	Call Serout
	Movlw 82
	Call Serout
	Movlw 88
	Call Serout
	Movf _A,W
	Call Serout
F1_000029 equ $
	Incf _X,F
	Btfss STATUS,2
	Goto fr@lb9
nx@lb10
	Goto bc@LL10
bc@LL7
F1_000030 equ $ 
F1_000031 equ $ 
	Clrf _A
F1_000032 equ $ 
bc@LL10
F1_000035 equ $ 
	Goto BASLA
F1_EOF equ $ 
 LIST
	END

