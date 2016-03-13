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
#include Modules\Lib\Rini.ahk
#include Modules\config.ahk
FileInstall, InstallMe/icon.png,icon.png, 1

A:=true
B:=3
C:=false



;SplashTextOn,200,100,T-Enhanced©, Created and maintained `n by Kieran Wynne `n`n All rights reservered %A_Year%
gui, splash: add, picture, w128 h-1 BackgroundTrans,icon.png
Gui, splash: Font, s12
gui, splash: add, Text,w128 center cblue BackgroundTrans, T-Enhanced
Gui, splash: Font, s10
gui, splash: add, Text,w128 center cblue BackgroundTrans, Created by`nKieran Wynne
gui, splash: add, progress, w128 vLoadup,
gui, splash: -border -caption +alwaysontop +LastFound +ToolWindow
Gui, splash:Color, EEAA99
WinSet, TransColor, EEAA99
gui, splash:show, autosize, T-Enhanced

;{ ----Startup
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
Onexit,Endit
#singleinstance, force
#Persistent
GuiControl,splash:, Loadup, +15
sleep, 150
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
GuiControl,splash:, Loadup, +15
sleep, 150
;}

;{ ----Variables
global Config:=A_ScriptDir "\Modules\Config.ini"
OutputDebug,[T-Enhanced]  Config directory set to [ %config% ]

global TesseractVersion:="5.40.14"
GuiControl,splash:, Loadup, +15
sleep, 150
;}

/*
###########
Custom Scripts
###########
Launches all .AHK files inside Custom Scripts Folder
*/
Loop %A_ScriptDir%\Custom Scripts\*.ahk
Run %A_LoopFileFullPath%
GuiControl,splash:, Loadup, +15  
sleep, 150
/*
###########
SysTray Setup
###########
Initialize the system tray menu
*/
if (A_IsCompiled){
Menu,tray,Nostandard
}
Menu, Home, add, Changelog,Changelog
Menu, Workshop, add,Create Job,Create
Menu, Workshop, add,Service Report,Report
Menu, Workshop, add,Ship Out,Ship
Menu, Workshop, add,Print,PrintFunction
Menu, tray, add, Home, :Home
Menu, tray, add, Workshop, :Workshop
Menu,Tray,add,Show
Menu,Tray,add,Reload,panic
Menu,Tray,add,Quit,Endit
OutputDebug,[T-Enhanced]  Tray fully loaded
GuiControl,splash:, Loadup, +15  
sleep, 150
/*
###########
Timer Initialization
###########
Start the Timers
*/
SetTimer,TestDB,60000,-1
OutputDebug,[T-Enhanced]  checking database connection every 5 seconds
GuiControl,splash:, Loadup, +15  
sleep, 150
/*
###########
Master GUI
###########
Launch the Main User Interface
*/
GuiControl,splash:, Loadup, 100  
sleep, 150
gui, splash:destroy
Gui, Master: Font, s8
Gui, Master: Add, Tab2, x0 y0 w265 h150 vTab gTabClick 0x108, Home|Engineer|Logistics|Management
Gui, Master: Tab, Management
Gui, Master: Add, Button, x92 y85 w80 h45 gBER 0x8000, Ber Item
Gui, Master: Tab, Home
Gui, Master: Font, s10 Bold
Gui, Master: Add, text, x40 y30 w150 h50  center ,T-Enhanced `n[ZULU]
Gui, Master: Add, text, x40 y65 w150 h50  center ,By Kieran Wynne
Gui, Master: Add, picture, x195 y30 w50 h50,icon.png
Gui, Master: Font, s8 norm
Gui, Master: add, Button , x20 y85 w112 h20 gChangelog 0x8000, Changelog
Gui, Master: Add, Button, vConfigButton x20 y110 w225 h35  gConfig 0x8000, Configuration
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
Gui, Master: Add, Button, x92 y30 w80 h45 gLogShipout 0x8000, Ship Out

Gui, Master: +AlwaysOnTop +ToolWindow +OwnDialogs -DPIScale 
X:=GetWinPosX("T-Enhanced Master Window")
Y:=GetWinPosY("T-Enhanced Master Window")
if (X = "ERROR" OR Y = "ERROR"){
Gui, Master: Show, ,T-Enhanced Master Window
} else {
Gui, Master: Show, X%x% Y%y%  ,T-Enhanced Master Window
}
if (settings.Engineer = "ERROR" or settings.Engineer = "" Or settings.WorkshopSite= "Error" or settings.WorkshopSite= ""){
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
Gui, Master: Tab, Home
GuiControl,Master:, Tab, |Home
Gui, Master: Add, text, ym xm+267 center, Insert Engineer Number
Gui, Master: Add, Edit, xm+267 yp+17 vEng1,
Gui, Master:Add, Text, xm+267 yp+20, Workshop Site?
Gui, Master:add, DDL, xm+267 yp+17 vMySite, NSC|Cumbernauld
Gui, Master:Add, Text, xm+267 yp+20 BackgroundTrans, Username
Gui, Master:Add, Edit, xm+267 yp+17 vUserNameIn,
Gui, Master:Add, Text, xm+267 yp+20, Password
Gui, Master:Add, Edit, xm+267 yp+17 vPasswordIn Password,
GuiControl, Master:hide, configButton
Gui, Master: Add, Button, x20 y110 w225 h35  gDone 0x8000, Submit
Gui, Master: show, autosize
return

Done:
gui,Master:submit,nohide
settings.save(Eng1,mySite,UserNameIn,PasswordIn)
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
if (settings.Engineer = "" OR settings.Engineer = "Error") {
	GuiControl,Master:, Tab, |Home
	return
}
gui,Master:show, autosize

return
;}

;{ ----AutoLogin
MasterGuiContextMenu:
OutputDebug,[T-Enhanced]  Quick login started
gui, Master:Submit, Nohide
if (A_GuiControl = "Tab"){
If (Tab = "Engineer"){
IniRead,UserHash,%Config%,Login,UserName
IniRead,PassHash,%Config%,Login,Password
If (UserHash = "" OR UserHash = "Error"){
return
}
if not PWB:= IEGET("Service Centre 5 Login") {
pwb:=""
return
} else {
pwb.document.getElementById("txtUserName").value := settings.decrypt("username")
pwb.document.getElementById("txtPassword").value := settings.decrypt("password")
pwb.document.getElementsByTagName("IMG")[7].click
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
#include Modules/Move.AHK
return

Assets:
#include Modules/KillMeNow.ahk
return

LogShipout:
shipout := new logistics.bookout()
return

#if settings.Engineer = "406"
#include Modules\406.ahk

