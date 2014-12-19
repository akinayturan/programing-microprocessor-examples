		LIST P=16F84A
INCLUDE "P16F84A.INC"
__CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _RC_OSC ; Config ayarlarý yapýldý. RC osilatör yapýldý.
SAYAC2 	EQU H'0D' ; Gecikme için sayaclar tanýmlandý.
SAYAC	EQU H'0C'
SAYAC3	EQU H'0B'
		ORG 0X00 ;Baþlama adresi
		CLRF PORTB ; PORTB yi temizledik.
		BSF STATUS,5 ; STATUS'un beþinci bitini 1 yaparak BANK1'e geçtik.
		CLRF TRISB ; PORTB'yi çýkýþ olarak tanýmladýk.
		BCF STATUS,5 ;STATUS'un beþinci bitini 0 yaparak BANK0'a geçtik.
TEKRAR ; Tekrar birinci ledi yakmasý için döngü tanýmladýk
		MOVLW H'01' ; Ýlk ledi yaktýk
		MOVWF PORTB 
SAG	  ; Birinci ledden 4.lede kayarak gitmesi için döngü kurduk.
		CALL TIMER ; Gecikme döngüsü çaðýrdýk
		RLF PORTB,F ; 1.ledden baþlayarak yaktýðýmýz ledleri 4.lede kadar kaydýran komut.
		BTFSS PORTB,3 ; RB3'e geldiðimizi kontrol edip SON döngüsüne gideceðimiz komut.
		GOTO SAG ; RB3 ledi yanmadýysa SAG döngüsüne git.
		GOTO SON ; RB3 ledi yandýysa SON döngüsüne git.
SON ; Bu döngü tüm ledleri sýfýrlar. Ve 8. ledi yakar.
		CALL TIMER ; gecikme döngüsü
		MOVLW B'00000000' ; Ledleri söndürdük.
		MOVWF PORTB
		CALL TIMER
		MOVLW H'80' ; Sola kaymasý için 8. Ledi yaktýk.
		MOVWF PORTB
		GOTO SOL
SOL
		CALL TIMER 
		RRF PORTB,F ; 8. Ledden 5. lede kaydýran komut.
		BTFSS PORTB,4 ; RB4'in yanýp yanmadýðýný kontrol ederiz.
		GOTO SOL ; RB4 deki led yanmadýysa döngüye devam et.
		CALL TIMER
		MOVLW B'00000000' ; RB4 deki led yandýysa ledleri söndür.
		MOVWF PORTB ; Tekrar döngüsüne git.
		CALL TIMER
		GOTO TEKRAR
TIMER  ; RC osilatör için gecikme döngüsü
		MOVLW H'37'
		MOVWF SAYAC
DONGUl
		MOVLW H'37'
		MOVWF SAYAC2
DONGU2
		MOVLW H'37'
		MOVWF SAYAC3
DONGU3
		DECFSZ SAYAC3, F
		GOTO DONGU3
		DECFSZ SAYAC2, F
		GOTO DONGU2
		DECFSZ SAYAC, F
		GOTO DONGUl
		RETURN
		END