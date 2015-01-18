
#pragma config[1] = 0xF1 // Osilat�r: XT
#pragma config[2] = 0xFE & 0xF9 // PWRT a��k, BOR kapal�
#pragma config[3] = 0xFE // Watchdog Timer kapal�

char	keypad_oku();
void	i2cgonder();
char	TUS;
char	data;
void	ayarlar();
void 	bekle(unsigned long t);	// t milisaniye gecikme sa�layan fonksiyon tan�m�

//-----------------------------------------------	
unsigned data;
void main()
{
	ayarlar();

anadongu:
	bekle(1);	// Acquisition Time(Sample & Hold kapasit�r�n�n �arj olmas� i�in gerekli zaman)
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

void ayarlar()	// B�t�n ba�lang�� ayarlar�n�n tamamland��� k�s�m
{	
	GIE=0;			// B�t�n kesmeleri kapat
	TRISC.3=1; 		//I2C SCL Ayar�
	TRISC.4=1; 		//I2C SDA Ayar�
	SSPCON1.3=1; 	//I2C Master Modu se�
	SSPCON1.2=0;
	SSPCON1.1=0;
	SSPCON1.0=0;
	SSPADD=0x0A; 	//100kHZ H�z Modu se�
	SSPEN=1; 		//MSSP'yi Etkinle�tir
	TRISD=0xF0;		// 
		
	PORTD=0;		// D portu ��k��lar� s�f�rland�
	PORTC=0;		// C portu ��k��lar� s�f�rland�


}

//////////////////////////////////////////////////////////////////////////////////////////////////

void i2cgonder()
{
	SEN=1; 			//I2C Start Biti Yolla
	while(SEN); 	//Ba�latma i�lemi ge�erli olana kadar bekle
	SSPIF=0; 		//SSPIF Bayra��n� S�f�rla
	SSPBUF=0x02; 	//Se�ilecek I2C Cihaz�n�n Adresini G�nder ve Yazma Bitini Aktifle�tir
	while(!SSPIF); 	//Adres G�nderilene Kadar Bekle
	SSPIF=0; 		//SSPIF Bayra��n� S�f�rla
	SSPBUF=data; 	//Se�ilen Cihaza Veriyi G�nder
	while(!SSPIF); 	//Veri G�nderilene Kadar Bekle
	SSPIF=0; 		//SSPIF Bayra��n� S�f�rla
	PEN=1; 			//I2C Stop Biti Yolla
	while(PEN); 	//Bitirme i�lemi ge�erli olana kadar bekle
	SSPIF=0; 		//SSPIF Bayra��n� S�f�rla
}

//////////////////////////////////////////////////////////////////////////////////////////////////

char keypad_oku()	// tarama keypad'�n okundu�u k�s�m
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

void bekle(unsigned long t)	//t milisaniye gecikme sa�lar
{
	unsigned x;
	
	for(;t>0;t--)
		for(x=140;x>0;x--)
			nop();
}

//////////////////////////////////////////////////////////////////////////////////////////////////

