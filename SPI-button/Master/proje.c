
#pragma config[1] = 0xF1 // Osilatör: XT
#pragma config[2] = 0xFE & 0xF9 // PWRT açýk, BOR kapalý
#pragma config[3] = 0xFE // Watchdog Timer kapalý

char	keypad_oku();
void	i2cgonder();
char	TUS;
char	data;
void	ayarlar();
void 	bekle(unsigned long t);	// t milisaniye gecikme saðlayan fonksiyon tanýmý

//-----------------------------------------------	
unsigned data;
void main()
{
	ayarlar();

anadongu:
	bekle(1);	// Acquisition Time(Sample & Hold kapasitörünün þarj olmasý için gerekli zaman)
  	while(1)
 {
	PORTD=keypad_oku();
	data=TUS;
	i2cgonder();
 }   
	goto anadongu;
//-----------------------------------------------	
}

//////////////////////////////////////////////////////////////////////////////////////////////////

void ayarlar()	// Bütün baþlangýç ayarlarýnýn tamamlandýðý kýsým
{	
	GIE=0;			// Bütün kesmeleri kapat
	TRISC.3=1; 		//I2C SCL Ayarý
	TRISC.4=1; 		//I2C SDA Ayarý
	SSPCON1.3=1; 	//I2C Master Modu seç
	SSPCON1.2=0;
	SSPCON1.1=0;
	SSPCON1.0=0;
	SSPADD=0x0A; 	//100kHZ Hýz Modu seç
	SSPEN=1; 		//MSSP'yi Etkinleþtir
	TRISD=0xF0;		// 
		
	PORTD=0;		// D portu çýkýþlarý sýfýrlandý
	PORTC=0;		// C portu çýkýþlarý sýfýrlandý


}

//////////////////////////////////////////////////////////////////////////////////////////////////

void i2cgonder()
{
	SEN=1; 			//I2C Start Biti Yolla
	while(SEN); 	//Baþlatma iþlemi geçerli olana kadar bekle
	SSPIF=0; 		//SSPIF Bayraðýný Sýfýrla
	SSPBUF=0x02; 	//Seçilecek I2C Cihazýnýn Adresini Gönder ve Yazma Bitini Aktifleþtir
	while(!SSPIF); 	//Adres Gönderilene Kadar Bekle
	SSPIF=0; 		//SSPIF Bayraðýný Sýfýrla
	SSPBUF=data; 	//Seçilen Cihaza Veriyi Gönder
	while(!SSPIF); 	//Veri Gönderilene Kadar Bekle
	SSPIF=0; 		//SSPIF Bayraðýný Sýfýrla
	PEN=1; 			//I2C Stop Biti Yolla
	while(PEN); 	//Bitirme iþlemi geçerli olana kadar bekle
	SSPIF=0; 		//SSPIF Bayraðýný Sýfýrla
}

//////////////////////////////////////////////////////////////////////////////////////////////////

char keypad_oku()	// tarama keypad'ýn okunduðu kýsým
{	
	PORTD.0=1;
	if(PORTD.4==1)
	{bekle(50);TUS=0X01;}
	if(PORTD.5==1)
	{bekle(50);TUS=0X02;}
	if(PORTD.6==1)
	{bekle(50);TUS=0X03;}
	if(PORTD.7==1)
	{bekle(50);TUS=0X0A;}
  	PORTD.0=0;
	bekle(1);  	

	PORTD.1=1;
	if(PORTD.4==1)
	{bekle(50);TUS=0X04;}
	if(PORTD.5==1)
	{bekle(50);TUS=0X05;}
	if(PORTD.6==1)
	{bekle(50);TUS=0X06;}
	if(PORTD.7==1)
	{bekle(50);TUS=0X0B;}
	PORTD.1=0;
	bekle(1);  

	PORTD.2=1;
	if(PORTD.4==1)
	{bekle(50);TUS=0X07;}
	if(PORTD.5==1)
	{bekle(50);TUS=0X08;}
	if(PORTD.6==1)
	{bekle(50);TUS=0X09;}
	if(PORTD.7==1)
	{bekle(50);TUS=0X0C;}
	PORTD.2=0;
	bekle(1);  

	PORTD.3=1;
	if(PORTD.4==1)
	{bekle(50);TUS=0X0E;}
	if(PORTD.5==1)
	{bekle(50);TUS=0X00;}
	if(PORTD.6==1)
	{bekle(50);TUS=0X0F;}
	if(PORTD.7==1)
	{bekle(50);TUS=0X0D;}
	PORTD.3=0;
	bekle(1);  
	
	return TUS;	
	
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

