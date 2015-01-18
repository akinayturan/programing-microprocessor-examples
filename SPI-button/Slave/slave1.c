#include "INT18XXX.H"


#pragma config[1] = 0xF1 // Osilatör: XT
#pragma config[2] = 0xFE & 0xF9 // PWRT açýk, BOR kapalý
#pragma config[3] = 0xFE // Watchdog Timer kapalý

uns8 dummy;
uns8 rx;
void ayarlar();
void bekle(unsigned long);

#pragma origin 0x8
interrupt ISR(void) //Kesme Rutini
{
	int_save_registers //Önemli yazmaçlarý sakla
	if(SSPIF==1) //Kesme, Senkron Ýletiþim Kesmesi mi?
	{
		SSPIF=0; //Kesme bayraðýný temizle
		if(S==1 && DA_==0 && RW_==0 && BF==1) //Eðer gelen mesaj bir adres bilgisi ise
		
			dummy=SSPBUF; //Bufferý boþaltmak için sahte okuma yap
		}
		if(S==1 && DA_==1 && RW_==0 && BF==1) //Eðer gelen mesaj bir veri ise
		{
			rx=SSPBUF; //Veriyi oku
		}
	}
	int_restore_registers //Kaydedilen yazmaçlarý yerine koy
	CKP=1; //Clock'u serbest býrak
}

void main()
{
	rx=0; 
	ayarlar(); //Ayarlarý yap
	while(1)//Her zaman
	{
		PORTB=rx; //Gelen veriyi PORTB'e çýk
	}
}

void ayarlar()
{
	TRISB=0;  //PORTB'i çýkýþ yap
	PORTB=0;  //PORTB'i sýfýrla
	TRISC.3=1; //I2C SCL Portunu Ayarla
	TRISC.4=1; //I2C SDA Portunu Ayarla
	SSPADD=0x02; //Cihazýn Adresini Belirle
	SSPCON1=0x36; //I2C Slave Modunu seç
	SSPSTAT=0x00;
	SSPCON2=0x00;
	SEN=1; //Clock esnetmeyi etkinleþtir
	SSPIF=0; //SSPIF Bayraðýný temizle
	SSPIE=1; //Senkron iletiþim kesmesini etkinleþtir
	INTCON=0xC0; //Genel kesmeleri ve çevre kesmelerini etkinleþtir
	return;
}
void bekle(unsigned long t)	//t milisaniye gecikme saðlar
{
	unsigned x;
	
	for(;t>0;t--)
		for(x=140;x>0;x--)
			nop();
}