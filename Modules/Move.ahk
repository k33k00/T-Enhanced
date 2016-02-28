FileInstall, InstallMe/PartDescriptions.ini,Modules/Database/PartDescriptions.ini, 1
FileInstall, InstallMe/partList.ini,Modules/Database/partList.ini,1
FileInstall, InstallMe/Parts-Request.msg,Modules/Parts-Request.msg,1
PartMove := new Movement("default")
PartMove.ini := new PartMove.ini("default")


        
gui,Move2:add,Text,,Select Manufacturer
gui,Move2: add, DDL, vSelectedSection gManuUpdate w200, % PartMove.ini.Sections()
gui, Move2: +AlwaysOnTop +ToolWindow +OwnDialogs -DPIScale 
gui, Move2:show,, Parts Movement
WinActivate, Parts Movement
return

ManuUpdate:
gui, Move2:submit,nohide
;GuiControl,disable,SelectedSection

GuiControl, Move2:, SelectedKey,% "|" . PartMove.ini.SectionKeys(selectedSection)
if (errorlevel) {
gui,Move2:add,Text,w200,Select Unit Type
gui, Move2:add, DDL, w200 vSelectedKey gTypeUpdate,% PartMove.ini.SectionKeys(selectedSection)
}
gui, Move2: show, AutoSize

return

TypeUpdate:
gui, Move2:submit, NoHide
;GuiControl,disable,SelectedKey

selectedKey :=  PartMove.ini.SectionkeyValues(SelectedKey)

GuiControl,Move2:, textCheck,Select Parts
if (errorLevel){
    gui,Move2:add,Text, vtextCheck w200,Select Parts
    gui,Move2:add, button, w200 xm vgoButton gPartMoveGo Disabled, Submit
gui,Move2:add, button, w200 xm vdescButton gPartMoveDesc, Description Lookup
Loop % PartMove.ini.KeyValues().MaxIndex()
{
    gui, Move2:add, DDL, w140 xm vSelectedKey%A_Index% genableSubmit, % PartMove.ini.SectionKeyValue
    gui, Move2:Add,edit, w40 yp x+2
    gui, Move2:add,updown, vKeyQuantity%A_Index%
    gui, Move2:add, text, vstatusText%A_Index% w20 h20 yp0 x+4,
    
    
}until A_index > 4


} else {
    Loop % PartMove.ini.KeyValues().MaxIndex()
    {
        GuiControl,Move2:, SelectedKey%A_Index% , % "|" . PartMove.ini.SectionKeyValue
        if (errorlevel){
            GuiControl,Move2:move, goButton,yp
            GuiControl,Move2:move, descButton,yp
            gui, Move2:add, DDL, w140 xm vSelectedKey%A_Index% genableSubmit, % PartMove.ini.SectionKeyValue
            gui, Move2:Add,edit, w40 yp x+2
        }
    }until A_index > 4
}
gui, Move2: show, AutoSize
return

enableSubmit:
GuiControl, enable, goButton
return

PartMoveDesc:
Gui, Move2:add, ListView, w400 x220 ym r16, Part Code|Description
thelist := PartMove.ini.SectionKeyValue
Loop, parse, thelist , |
{
    IniRead,tempdescription, Modules/Database/PartDescriptions.ini,PartDescriptions,%A_LoopField%
    LV_Add("", A_LoopField , tempDescription)
    LV_ModifyCol()  
}
LV_ModifyCol()  
gui, Move2: show, AutoSize
return

PartMoveGo:
gui,Move2:submit, nohide
loop, 5 {
    if (selectedKey%A_Index%) {
        currentPart := selectedKey%A_Index%
        selectedQuantity := KeyQuantity%A_Index%
        currentStatus := statusText%A_Index%
        Gui Font, cBlue s14
        GuiControl, Move2:Font, statusText%A_Index%
        GuiControl,Move2:text ,statusText%A_Index%, % chr(0x00221E)
            while not selectedQuantity
                InputBox, selectedQuantity,Select Quantity, Input correct quantity - current set to %selectedQuantity%
        
        if (PartMove.MovePart(currentPart,selectedQuantity)) {
            sleep, 150
            PartMove.queuePrint(currentPart,selectedQuantity)
            sleep, 150
            partMove.GetPartLocation(currentPart)
            sleep, 150
            Gui Font, cGreen
            GuiControl, Move2:Font, statusText%A_Index%
            GuiControl,Move2:text ,statusText%A_Index%, % chr(0x002714)
            } else {
                Gui Font, cRed
                GuiControl, Move2:Font, statusText%A_Index%
                GuiControl,Move2:text ,statusText%A_Index%, X
        }
    }
}

partmove.print()

Move2GuiClose:
Move2GuiEscape:
PartMove := ""
gui,Move2:destroy
return


;~ #IfWinActive,Parts Movement
;~ {
   ;~ $WheelDown::
    ;~ if selectedKey
        ;~ return
    ;~ else
        ;~ Send {WheelDown}
    ;~ return
    
    ;~ $WheelUp::
    ;~ if selectedKey
       ;~ return
    ;~ else
        ;~ Send {WheelUp}
    ;~ return
;~ }


class Movement
{
    requestedPart := {}
    partLocation := {}
    __New()
    {
        ;ini := new this.ini("default")
        ;gui:= new this.gui("default")
    }
    
    __Delete()
    {
        RIni_Shutdown(1)
        loop, 5 {
        selectedKey%A_Index% := ""
        KeyQuantity%A_Index% := ""
}
    }
    class ini
    {
        databasePath := "/modules/Database/partList.ini"
        instance := ""
        selectedSection := ""
        selectedKey:= ""
        SectionkeyValue:= ""
        __New() 
        {
            this.read(1)
        }
        Read(instance)
        {
            this.instance := instance
            RIni_Read(this.instance, A_ScriptDir . this.databasePath)
        }
        
        Sections()
        {
            return RIni_GetSections(this.instance,"|")
        }
        
        SectionKeys(SelectedSection)
        {
            this.SelectedSection := SelectedSection
            return RIni_GetSectionKeys(this.instance,this.SelectedSection, "|")
        }
        
        SectionkeyValues(key)
        {
            this.selectedKey:= key
            OutputDebug % this.selectedKey . " - " . this.SelectedSection
            tempsectionkeyvalue := Rini_GetKeyValue(this.instance, this.SelectedSection, this.SelectedKey)
            this.SectionkeyValue := Trim(tempsectionkeyvalue)
            return this.SectionKeyValue
        }
        
        KeyValues()
        {
            return  StrSplit(this.sectionKeyValue, "|")
        }
    }
    
    class gui
    {
        
    }
    
    MovePart(part,quantity)
    {
    sleep 250
    PartMovePointer:=IEVget(Title)
    URL=http://hypappbs005/SC5/SC_StockMove/aspx/stockmove_frameset.aspx ;set the url
	PartMovePointer.Navigate2(URL,2048) ;navigate the hijacked session to a new tab opening the set url
    	Loop {
		try {
			PartMovePointer:=IEGetURL("http://hypappbs005/SC5/SC_StockMove/aspx/stockmove_frameset.aspx")  ;get session by url
			Frame:=PartMovePointer.document.all(9).contentwindow
			Frame.document.GetElementById("cboPartNum").value := Part ;set the value of the field
		}
	}Until (Frame.document.GetElementById("cboPartNum").value = Part) ;break the loop when the field is set to the correct field
    frame.document.getelementbyID("cboSourceSiteNum").value := "STOWPARTS"
    ModalDialogue() 
    frame.document.getElementsByTagName("IMG")[2] .click
    if (Frame.document.GetElementById("cboSourceSiteName").value = ""){
        PartMovePointer.quit
        return false
    }
    while (frame.document.getelementbyID("txtSourceTotalQty").value = "")
        sleep, 500
    sleep, 250
    
    SourceQuantity := frame.document.getelementbyID("txtSourceTotalQty").value
    if (SourceQuantity < quantity) {
        TrayTip, incorrect quantity
        InputBox,quantity,New Quantity, Not enough in stock.`nMax available: %SourceQuantity%`nSelect new amount
        WinWaitClose, New Quantity
         if (errorlevel = 1) {
                PartMovePointer.quit
                return false
                }
    } 
    IniRead,Engineer,%Config%,Engineer,Number ;read engineer number
	
	frame.document.getelementbyID("cboDestSiteNum").value := Engineer ;input engineer number
	ModalDialogue() 
	frame.document.getElementsByTagName("IMG")[6] .click 
	
	while (frame.document.getelementbyID("txtSourceTotalNeed").value = "")
		sleep, 500
    frame.document.getelementbyID("txtMoveTotalQty").value := Quantity
    	frame.document.getelementbyID("cboAdjustCode").value := "MV" ;set adjustment code
	frame.document.getelementbyID("txtReason").value := "Automated by T-Enhanced" ;inserted reason
	frame.document.getelementbyID("cboSourceSiteNum").value := "STOWPARTS" ;insert movement site
	ModalDialogue() 
	frame.document.getElementsByTagName("IMG")[2] .click 
	sleep, 500
	frame.document.getelementbyid("chkAllowNewStockFlag").click  ;check the flag
    PageAlert()
	frame := PartMovePointer.document.all(6).contentWindow
	frame.document.getElementByID("cmdSubmit").Click ;submit
    pageloading(PartMovePointer)
    WinClose,Message from webpage,,5
    PartMovePointer.quit()
    return true
}

    queuePrint(part,quantity) 
    {
    this.requestedPart[part] := quantity
    return true
    }
    
    GetpartLocation(part)
    {
        SecondaryPointer:=IEVget(Title)
        URL:="http://hypappbs005/SC5/SC_StockControl/aspx/StockControl_modify.aspx?SiteNo=STOWPARTS&PartNo=" . part ;set the url
        SecondaryPointer.Navigate2(URL,4096) ;navigate the hijacked session to a new tab opening the set url
    	Loop {
		try {
			SecondaryPointer:=IEGetURL("http://hypappbs005/SC5/SC_StockControl/aspx/StockControl_modify.aspx?SiteNo=STOWPARTS&PartNo=" . part)  ;get session by url
			stockCheck := SecondaryPointer.document.GetElementById("txtTotalQty").value ;set the value of the field
            }
        }Until (stockCheck != "") ;break the loop when the field is set to the correct field
        StockLocation :=  SecondaryPointer.document.GetElementById("txtLocation").value
        if (stockLocation = "") {
            StockLocation :=  SecondaryPointer.document.GetElementById("txtBinLoc").value
        }
        if  (StockLocation = "") {
            StockLocation := false
        }
        this.partLocation[part] := StockLocation
        SecondaryPointer.quit()
        return true
    }
    
    print()
    {
        global DymoAddin
        global DymoLabel
        DymoAddIn.Open("Modules\Part Order.label")
        DymoAddin.StartPrintJob()
        
        For key, value in this.requestedPart
        {
            OutputDebug % key . " = " value
        DymoLabel.SetField( "Part1", key) 
        IniRead,description, Modules/Database/PartDescriptions.ini,PartDescriptions,%key%
        DymoLabel.SetField( "Description1", description) 
        DymoLabel.SetField( "Quantity1", value) 
        IniRead,Engineer,%Config%,Engineer,Number ;read engineer number
        StringReplace,Engineer,Engineer,BK,,
        DymoLabel.SetField( "Engineer", Engineer)
        if (this.partLocation[key]) {
            DymoLabel.SetField( "Location1", this.partLocation[key]) 
        }
        DymoAddIn.Print( 1, TRUE )
        }
        DymoAddin.EndPrintJob()
    }
}