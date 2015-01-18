#pragma config[1] = 0xF1 // Osilatör: XT
#pragma config[2] = 0xFE & 0xF9 // PWRT açýk, BOR kapalý
#pragma config[3] = 0xFE // Watchdog Timer kapalý
#pragma origin 0x8    //Aþaðýdaki kesme fonksiyonunun hangi program satýrýndan baþlayacaðý ayarlandý
       					//(0x8 adresi yüksek öncelikli kesme baþlangýç adresidir)

#pragma interruptSaveCheck n
#pragma sharedAllocation

void ayarlar();
void bekle(unsigned long t);	// t milisaniye gecikme saðlayan fonksiyon tanýmý
void oku_yaz();
void LcdInit();
void LcdYaz(char);
void LcdKomut(unsigned kom);
void MesajYaz(const char *msj,unsigned adr);

bit e @ PORTE.0, rs @ PORTE.1, rw @ PORTE.2;
unsigned disp @ PORTD;


interrupt int_server(void)  // KESME SUNUCU FONKSÝYONU
{   
	if(INT0IF)				//Gelen kesme, INT0 kesmesi mi?
	{
		oku_yaz();
		INT0IF = 0;
	}
}


void main()
{
	ayarlar(); // Ýlgili Port ve INT tanýmlamalarýnýn yapýlmdýðý fonksiyon
	LcdInit(); // LCD' nin kullanýmý için gerekli ayarlamalar.
	
	MesajYaz("Islem Basliyor",0x80); //0x80 Cursorýn baslangýc konumunu belirliyor
	bekle(500);
//-----------------------------------------------	
anadongu:
	
	
 	bekle(1);	// Acquisition Time(Sample & Hold kapasitörünün þarj olmasý için gerekli zaman)
 	MesajYaz("Basilan Tus : ",0x80);
	goto anadongu;
//-----------------------------------------------	
}

//////////////////////////////////////////////////////////////////////////////////////////////////

void ayarlar()	// Bütün baþlangýç ayarlarýnýn tamamlandýðý kýsým
{	

	INT0IE = 1;		// INT0 kesmesi açýk
	INTEDG0 = 0;	// INT0 kesmesi düþen kenarda aktif olacak
	GIE = 1;		// Bütün kesmeler kullanýlabilir
	TRISC = 0x00;	// PORTC çýkýþ yapýldý( LED )
	TRISB = 0xFF;	// PORTB giriþ yapýldý ( Matrix Klavye )
	TRISD = 0X00;	// PORTD çýkýþ yapýldý ( LCD )
	TRISE = 0X00;	// PORTE çýkýþ yapýldý ( LCD )
	
	PORTC = 0;		// PORTC çýkýþlarý sýfýrlandý
	PORTD = 0;	
	
}

//////////////////////////////////////////////////////////////////////////////////////////////////

void bekle(unsigned long t)	//t milisaniye gecikme saðlar
{
	unsigned x;
	
	for(;t>0;t--)
		for(x=140;x>0;x--)
			nop();
}

//////////////////////////////////////////////////////////////////////////////////////////////////

void oku_yaz()
{
	unsigned x;
	int index;
	int b[4];
	static const v[8] = {0x01,0x02,0x03,0x00,0x04,0x05,0x06,0x00}; //Girilen deðer 6'dan küçükse kullanýlan bu diziyi kullan
	static const n[8] = {0x07,0x08,0x09,0x00,0x0F,0x00,0x0F,0x00}; //Girilen deðer 6'dan büyükse kullanýlan bu diziyi kullan
	
	//Matrix klavyeden girilen deðeri bulmak için, b dizisini kullan
	b[0] = PORTB.4;
	b[1] = PORTB.5;
	b[2] = PORTB.6;
	b[3] = PORTB.7;

	//Girilen sayýnýn decimal karþýlýðý
	index = b[0] + (b[1]*2);
	index += (b[2]*4); 
	index += (b[3]*8);
	
	if( index>6 ) //Girilen sayýnýn 6 dan büyük olmasý
	{
		
		PORTC = n[index-8];
		if ( index == 12 || index == 14 ) //Basýlan tuþun "*" veya "#" olmasý
		{
			if ( index == 12 )
				MesajYaz("*",0x8E);
			else
				MesajYaz("#",0x8E);
		}
		else //Basýlan tuþun 7,8,9,0 olmasý durumu
		{
			switch (index)
			{
				case 8:
					MesajYaz("7",0x8E);
					break;
				case 9:
					MesajYaz("8",0x8E);
					break;
				case 10:
					MesajYaz("9",0x8E);
					break;
				case 13:
					MesajYaz("0",0x8E);
					break;
			}
		}
	}
	else //Girilen sayýnýn 6 veya 6'dan küçük olmasý
	{
		PORTC = v[index];
		switch(index) //Basýlan tuþun 1,2,3,4,5,6 olmasý durumu
		{
			case 0:
					MesajYaz("1",0x8E);
					break;
			case 1:
					MesajYaz("2",0x8E);
					break;
			case 2:
					MesajYaz("3",0x8E);
					break;
			case 4:
					MesajYaz("4",0x8E);
					break;
			case 5:
					MesajYaz("5",0x8E);
					break;
			case 6:
					MesajYaz("6",0x8E);
					break;
		}
	}	
}
//////////////////////////////////////////////////////////////////////////////////////////////////
void LcdKomut(unsigned kom) // Gelen mesajýn iþlem komutuna göre, ilgili komutu gerçekleþtiren fonksiyon 
{							// MesajYaz("....",0x80); satýrýndaki 0x80' i iþleme koyan fonksiyon
	bekle(20);
	disp=kom;
	rs=0;
	e=0;
	e=1;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
void LcdYaz(char c) // Gelen karakteri ekrana basan fonksiyon
{
	bekle(50);
	disp=c;
	rs=1;
	e=0;
	e=1;
	bekle(1);	
}
//////////////////////////////////////////////////////////////////////////////////////////////////
void LcdInit() // LCD ekranýn kullaným özelliklerini belirleyen fonksiyon
{
	rw=0;			// LCD' ye yazdýrma
	e=1;			// LCD aktif edildi
	rs=1;			// Yazmaç seçimi
	LcdKomut(0x38);	
	LcdKomut(0x01);	//Clear display
	LcdKomut(0x0C); //Dont display cursor,Blink off
	LcdKomut(0x06); //Increment ddram adres, do not shift disp.
}
//////////////////////////////////////////////////////////////////////////////////////////////////
void MesajYaz(const char *msj,unsigned adr)
{
	unsigned i,j,k;
	i=0;
	while(msj[i]!=0) //Gelen mesajýn boyutunun bulunmasý
		i++;
	
	LcdKomut(adr);
	for(j=0;j<i;j++) //LcdYaz fonksiyonu içine, mesajýn karakterleri tek tek yollanýyor.
	{
		LcdYaz(msj[j]);
		for(k=0;k<30;k++) //30 cycle boyunca bekleme yarat
			nop();
	}
}