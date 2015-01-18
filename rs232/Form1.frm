VERSION 5.00
Object = "{648A5603-2C6E-101B-82B6-000000000014}#1.1#0"; "MSCOMM32.OCX"
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   7155
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   9450
   LinkTopic       =   "Form1"
   ScaleHeight     =   7155
   ScaleWidth      =   9450
   StartUpPosition =   3  'Windows Default
   Begin MSCommLib.MSComm MSComm1 
      Left            =   3720
      Top             =   3480
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      DTREnable       =   -1  'True
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Durdur"
      Height          =   855
      Left            =   4200
      TabIndex        =   2
      Top             =   2160
      Width           =   1575
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Baþla"
      Height          =   855
      Left            =   2280
      TabIndex        =   1
      Top             =   2160
      Width           =   1575
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      Caption         =   "Sistemin Aktif Olmasý Ýçin Baþla Butonuna Basýnýz"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   18
         Charset         =   162
         Weight          =   700
         Underline       =   0   'False
         Italic          =   -1  'True
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H000000FF&
      Height          =   495
      Left            =   1560
      TabIndex        =   0
      Top             =   600
      Width           =   5655
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Command1_Click()


If MSComm1.PortOpen = False Then
    MSComm1.PortOpen = True
End If

Label1.Caption = " "
MSComm1.Output = "w"

If MSComm1.InBufferCount Then
    Label1.Caption = MSComm1.Input

End If

End Sub

Private Sub Command3_Click()

MSComm1.Output = "d"
Label1.Caption = "LED sonduruldu"
MSComm1.PortOpen = False

End Sub

Private Sub Form_Load()
MSComm1.CommPort = 1
MSComm1.Settings = "9600,n,8,1"
MSComm1.PortOpen = True
MSComm1.RThreshold = 1

End Sub

Private Sub Label1_Click()

End Sub

Private Sub MSComm1_OnComm()

MSComm1.InputLen = 0

Select Case MSComm1.CommEvent
Case comEvSend:
Case comEvReceive:
Label1.Caption = Label1.Caption + MSComm1.Input
End Select

End Sub

