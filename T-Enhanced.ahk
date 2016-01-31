﻿RunAsAdmin() 
if not A_isadmin {
	OutputDebug, [T-Enhanced] Not running as administrator
	MsgBox, Unable to get privileges. Check your permissions
	ExitApp	
} else {
	OutputDebug, [T-Enhanced] Running as administrator
}

#include Modules\Lib\Functions.ahk
#include Modules\Lib\Api.ahk

	

A:=true
B:=3
C:=false



SplashTextOn,200,100,T-Enhanced©, Created and maintained `n by Kieran Wynne `n`n All rights reservered %A_Year%

;{ ----Startup
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
Onexit,Endit
#singleinstance, force
#Persistent
;}

;{ ----COM Addins
Pwb:=""
try {
DymoLabel := ComObjCreate("DYMO.DymoLabels")
OutputDebug, [T-Enhanced] Enabled DYMO.DymoLabels 1/3 
DymoAddIn := ComObjCreate("DYMO.DymoAddIn")
OutputDebug, [T-Enhanced] Enabled DYMO.DymoAddIn 2/3
DymoEngine := ComObjCreate("DYMO.LabelEngine")
OutputDebug, [T-Enhanced] Enabled DYMO.LabelEngine 3/3
} catch {
	msgbox, Unable to activate Dymo.`nPlease check you have the latest Dymo software installed.
}
OutputDebug,[T-Enhanced]  Dymo successfully Loaded
;}

;{ ----Variables
global Config:=A_ScriptDir "\Modules\Config.ini"
OutputDebug,[T-Enhanced]  Config directory set to [ %config% ]

IniRead,Eng,%Config%,Engineer,Number
OutputDebug, [T-Enhanced] Engineer Stock site = %Eng%
Iniread,Site, %Config%,Site,Location
OutputDebug,[T-Enhanced]  Current stock site = %Site%
global TesseractVersion:="5.40.14"
;}

/*
###########
Custom Scripts
###########
Launches all .AHK files inside Custom Scripts Folder
*/
Loop %A_ScriptDir%\Custom Scripts\*.ahk
Run %A_LoopFileFullPath%


/*
###########
SysTray Setup
###########
Initialize the system tray menu
*/
;~ Menu,tray,Nostandard
Menu, Home, add, Config,config
Menu, Home, add, Changelog,Changelog
Menu, Workshop, add,Create Job,Create
Menu, Workshop, add,Service Report,Report
Menu, Workshop, add,Ship Out,Ship
Menu, Workshop, add,Print,PrintFunction
Menu,Tools,add,Pickable parts Requests,StockRequirements
Menu,Tools,add,Stock Level check,RequiredStock
Menu,Tools,add,Stat Levels,StatRace
Menu,Management,add,BER Item,BER
Menu, tray, add, Home, :Home
Menu, tray, add, Workshop, :Workshop
Menu, tray, add, Tools, :Tools
Menu, tray, add, Management, :Management
Menu, tray, add,
Menu,Tray,add,Show
Menu,Tray,add,Reload,panic
Menu,Tray,add,Quit,Endit
OutputDebug,[T-Enhanced]  Tray fully loaded

/*
###########
Timer Initialization
###########
Start the Timers
*/
SetTimer,TestDB,5000,-1
OutputDebug,[T-Enhanced]  checking database connection every 5 seconds

/*
###########
Master GUI
###########
Launch the Main User Interface
*/
SplashTextOff
Gui, Master: Margin, 0, 0
Gui, Master: Font, s8
Gui, Master: Add, Tab2, x0 y0 w265 h150 vTab gTabClick 0x108, Home|Engineer|Logistics|Management
Gui, Master: Tab, Management
Gui, Master: Add, Button, x92 y85 w80 h45 gBER 0x8000, Ber Item
Gui, Master: Tab, Home
Gui, Master: Font, s10 Bold
Gui, Master: Add, text, x40 y30 w150 h50  center ,T-Enhanced `n[ZULU]
Gui, Master: Add, text, x40 y65 w150 h50  center ,By Kieran Wynne
Gui, Master: Font, s8 norm
Gui, Master: add, Button , x20 y85 w112 h20 gChangelog 0x8000, Changelog
Gui, Master: Add, Button, x20 y110 w225 h35  gConfig 0x8000, Configuration
Gui, Master: Add, Button, x5 y25 w35 h35 gEndit 0x8000, Quit
Gui, Master: Tab, Engineer
Gui, Master: Add, Button, x5 y30 w80 h45 gCreate vCreate 0x8000, Create Job
Gui, Master: Add, Button, x92 y85 w80 h45 gPanic 0x8000, Reload T-Enhanced
Gui, Master: Add, Button, x5 y85 w80 h45 gPrintFunction vPrint 0x8000, Print Labels
Gui, Master: Add, Button, x180 y30 w80 h45 gShip vShipOut 0x8000, Ship Current Job
Gui, Master: Add, Button, x92 y30 w80 h45 gReport vReport 0x8000, Service Report
Gui, Master: Add, Button, x180 y85 w80 h45 gLetsMoveSomeShit 0x8000, Move Parts
Gui, Master: Tab, Logistics
Gui, Master: Add, Button, x5 y30 w80 h45 gAssets vAssets 0x8000, Book In

Gui, Master: +AlwaysOnTop +ToolWindow +OwnDialogs -DPIScale 
X:=GetWinPosX("T-Enhanced Master Window")
Y:=GetWinPosY("T-Enhanced Master Window")
if (X = "" OR Y = ""){
Gui, Master: Show, ,T-Enhanced Master Window
} else {
Gui, Master: Show, X%x% Y%y%  ,T-Enhanced Master Window
}
if (ENG = "error" Or Eng = "" Or Site = "error" Or Site = ""){
	OutputDebug,[T-Enhanced]  Failed to find settings
	gosub, config
}
OutputDebug,[T-Enhanced]  Master Gui loaded
WinGet,MasterWindow,ID,T-Enhanced Master Window
return

MasterGuiClose:
MasterGuiEscape:
SaveWinPos("T-Enhanced Master Window")
gosub,Hide
return

/*
###########
Simple Quit
###########
Quits the master Gui
*/
Endit:
try
pwb := ""
SaveWinPos("T-Enhanced Master Window")
OutputDebug,[T-Enhanced]  Force quit
Exitapp
return


/*
###########
Configuration Interface
###########
Opens up the Configuration Interface
*/
config:
Eng1:=""
Gui, Setup: Margin, 0, 0
Gui, Setup:Font, s10
Gui, Setup:Add, Text, x20 y2 w267 h50, T-Enhanced Configuration
Gui, Setup:Font, s10
Gui, Setup:Add, Text, x150 y30 w100 h17, Workshop Site?
Gui, Setup:add, DDL, x150 y50 w100 vMySite, NSC|Cumbernauld
Gui, Setup:Font, s8 norm
Gui, Setup:Add, Text, x20 y17 w105 h15, Engineer Stock site
Gui, Setup:Add, Edit, x20 y32 w65 h20 vEng1, %Eng%
Gui, Setup:Add, Text, x20 y50 w105 h15, Username
Gui, Setup:Add, Edit, x20 y65 w65 h20 vUserNameIn,
Gui, Setup:Add, Text, x20 y85 w105 h15, Password
Gui, Setup:Add, Edit, x20 y100 w65 h20 vPasswordIn Password,
;Gui, Setup:Add, Button, x20 y125 w43 h20 gEngSave, Save
Gui, Setup:Add, Button, x216 y126 w43 h23 gDone, Submit
Gui, Setup:  +AlwaysOnTop +ToolWindow +Owner%MasterWindow%

X:=GetWinPosX("Setup")
Y:=GetWinPosY("Setup")
if (X = "" OR Y = "" OR X= "Error" OR Y="Error"){
Gui, Setup: Show, ,Setup
} else {
Gui, Setup: Show, X%x% Y%y%  ,Setup
}
return
EngSave:
return
SetupGuiClose:
SetupGuiEscape:
SaveWinPos("Setup")
Reload
return
Done:
gui,Setup:submit,nohide
StringUpper,Eng1,Eng1
IniDelete,%Config%,Engineer,Number
IniWrite,%Eng1%,%Config%,Engineer,Number
IniRead,Eng,%Config%,Engineer,Number
OutputDebug,[T-Enhanced]  saved %eng% to %config%
if (UserNameIn != "" OR PasswordIn != ""){
UserHash:=Crypt.Encrypt.StrEncrypt(UserNameIn,Eng,5,1)
PassHash:=Crypt.Encrypt.StrEncrypt(PasswordIn,Eng,5,1)
IniWrite,%UserHash%,%Config%,Login,UserName
IniWrite,%PassHash%,%Config%,Login,Password
OutputDebug, [T-Enhanced] saved username & password
}
IniWrite,%mySite%,%Config%,Site,Location
OutputDebug,[T-Enhanced]  saved %mysite% to %config%
Gui,Setup:Destroy
OutputDebug,[T-Enhanced]  succesfull config
SaveWinPos("Setup")
reload
return


/*
###########
Show commit history
###########
Opens github to the commits page
*/
Changelog:
run, https://github.com/k33k00/T-Enhanced--ZULU-/commits/master
OutputDebug,[T-Enhanced]  opened changelog
return
;}

Create:
#include Modules/TheCreationist.ahk
return

Report:
#Include Modules/ServicePlease.ahk
return

Ship:
#Include Modules/Sayonara.ahk
return

Panic:
SaveWinPos("T-Enhanced Master Window")
OutputDebug,[T-Enhanced]  Force Reload
Reload
return

Hide:
SaveWinPos("T-Enhanced Master Window")
Gui,Master: Hide
return

Show:
Gui, Master:Show
return



PrintFunction:
#include Modules/ManualPrint.ahk
return


BER:
;#include Modules/fuBER.ahk
return

StockRequirements:
;#include Modules/Urgent.ahk
return

RequiredStock:
;#include Modules/DoIt.ahk
return

;{ ----On tab click
TabClick:
return
;}

;{ ----AutoLogin
MasterGuiContextMenu:
OutputDebug,[T-Enhanced]  Quick login started
gui, Master:Submit, Nohide
if (A_GuiControl = "Tab"){
If (Tab = "Engineer"){
IniRead,Eng,%Config%,Engineer,Number
IniRead,UserHash,%Config%,Login,UserName
IniRead,PassHash,%Config%,Login,Password
If (UserHash = "" OR UserHash = "Error"){
return
}
if not PWB:= IEGET("Service Centre 5 Login") {
pwb:=""
return
} else {
User:=Crypt.Encrypt.StrDecrypt(UserHash,Eng,5,1)
Pass:=Crypt.Encrypt.StrDecrypt(PassHash,Eng,5,1)
pwb.document.getElementById("txtUserName").value := User
pwb.document.getElementById("txtPassword").value := Pass
pwb.document.getElementsByTagName("IMG")[7].click
User:=""
Pass:=""
pwb:=""
}
}
}
OutputDebug,[T-Enhanced]  Quick login ended
return
;}

StatRace:
;#include Modules/AndThereOff.ahk
return

MoveGui:
WinMove()
return

Benchkit:
;#include Modules/KitCheck.ahk
return

;{ ----Database Check
TestDB:
If TestDB:=IETitle("ESOLBRANCH TEST DB / \w+ / DLL Ver: " TesseractVersion " / Page Ver: " TesseractVersion) {
setTimer,TestDB,Off
msgbox, You are logged in the Test Database `, Redirecting
TestDB.Navigate("http://hypappbs005/SC5/SC_Login/aspx/login_launch.aspx?SOURCE=ESOLBRANCHLIVE")
sleep, 5000
setTimer,TestDB,1000
}
TestDB:=""
return
;}

BulkProcess:
;#include Modules/FactoryTime.ahk
return

LetsMoveSomeShit:
#include Modules/IWantToMoveIt.AHK
return

Assets:
#include Modules/KillMeNow.ahk
return

#if eng = "406bk"
#include Modules\406.ahk

