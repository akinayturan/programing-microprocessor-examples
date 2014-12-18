
 P=16f84a
 _B = 26
F2_SOF equ $ 
F2_EOF equ $ 
F1_SOF equ $ 
F1_000004 equ $ 
	Movlw 1
	Bsf STATUS,5
ram_bank = 1
	Movwf TRISA
	Bcf STATUS,5
ram_bank = 0
	Clrf PORTA
F1_000005 equ $ 
	Bsf STATUS,5
ram_bank = 1
	Clrf TRISB
	Bcf STATUS,5
ram_bank = 0
	Clrf PORTB
F1_000007 equ $ 
F1_000009 equ $
	Clrf _B
BASLA
F1_000013 equ $ 
	Movlw PORTA
	Movwf GEN
	Movlw 1
	Movwf GENH
	Clrf PP5H
	Movlw 84
	Movwf PP5
Pb@lb2
	Call Serin
	Sublw 84
	Btfss STATUS,2
	Goto Pb@lb2
	Call Serin
	Sublw 88
	Btfss STATUS,2
	Goto Pb@lb2
	Call Serin
	Sublw 82
	Btfss STATUS,2
	Goto Pb@lb2
	Call Serin
	Sublw 88
	Btfss STATUS,2
	Goto Pb@lb2
	Call Serin
	Movwf _B
F1_000016 equ $
	Movlw 10
	Subwf _B,W
	Btfss STATUS,2
	Goto bc@LL3
F1_000017 equ $ 
	Bsf STATUS,5
ram_bank = 1
	Bcf TRISB,0
	Bcf STATUS,5
ram_bank = 0
	Bsf PORTB,0
F1_000018 equ $ 
	Movlw 250
	Call dl@ms
F1_000019 equ $
	Bsf STATUS,5
ram_bank = 1
	Bcf TRISB,0
	Bcf STATUS,5
ram_bank = 0
	Bcf PORTB,0
F1_000020 equ $
bc@LL3
F1_000022 equ $
	Movlw 20
	Subwf _B,W
	Btfss STATUS,2
	Goto bc@LL5
F1_000023 equ $
	Bsf STATUS,5
ram_bank = 1
	Bcf TRISB,1
	Bcf STATUS,5
ram_bank = 0
	Bsf PORTB,1
F1_000024 equ $
	Movlw 250
	Call dl@ms
F1_000025 equ $ 
	Bsf STATUS,5
ram_bank = 1
	Bcf TRISB,1
	Bcf STATUS,5
ram_bank = 0
	Bcf PORTB,1
F1_000026 equ $
bc@LL5
F1_000028 equ $
	Goto BASLA
F1_000029 equ $ 
Pb@lb7
	Sleep
	Goto Pb@lb7
F1_EOF equ $ 
 LIST
	END

