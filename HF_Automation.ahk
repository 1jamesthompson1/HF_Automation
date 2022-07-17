#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force
programName := HF automation v0.1.0

loop
{
  if !FileExist("config.ini")
  {
    InputBox, userInitials, %programName%, What is your intials?
    if ErrorLevel
        ExitApp
    IniWrite, %userInitials%, config.ini, userDetails, userInitials

  }
  else
  {
    loop {
      InputBox, campaign, %programName%, What is the campagin?
      if ErrorLevel
        ExitApp
      if (campaign != 6 && campaign != 18 && campaign != 30) {
        MsgBox, Please just enter either 6, 18, or 30
      }
      else {
        break
      }
    }
    IniRead, userInitials, config.ini, userDetails, userInitials
    break
  }
}
/*
*Main script. This should be started on the upgradeAmount column.
*/
Insert::
;Check if it is a conversion or not and get neccasary information
Send ^c
Sleep 100
clipboard := StrReplace(clipboard, "`r`n")
if (clipboard != "") { ;If cell is not empty
  conversion := true
  upgradeAmount := clipboard
  Send, {Right}
  Sleep 200
  Send ^c
  Sleep, 200
  originalAmount := clipboard - upgradeAmount
  totalAmount := clipboard
  Send {Left}
} else {
  conversion := false
}


;Grab the constituents ID
Send, {Home}
Sleep 100
Send, ^c
Sleep 100

;Move to the Kete Tab and make sure at the top of the page
Send, ^{Tab}
Send, 100
Send, {Home}
Sleep 100

;Find the search bar and click on it
WinGetPos, X, Y, W, H, A
if (W < 985) { ;At this point the distnace does not decrease
  clickX := 756
} else if (W <= 1215) { ;There is a step
  clickX := W*0.477 + 290
} else { ;When it is the largest
  clickX := W*0.477 + 295  - 80
}
Click, %clickX% 144

Sleep 2000


;Enter consistents ID and enter
Send, ^v
Sleep 100
Send, {Enter}
Sleep 1000
Send, {Enter}

Sleep 2000
;Go to interaction
pressImage("interaction.png", 20,10)
Sleep 1000


;-----Fill out the interaction-------


outcomeStart := "TM-RG "
outcomeEnd := " to Upgrade"
if (conversion) ;If it is a conversion
{
  outcome := "Yes"
}
else ;not a conversion
{
  outcome := "No"
}
outcomeFinal := outcomeStart . outcome . outcomeEnd
Send %outcomeFinal% ;Summary

Send {Tab}
Send Completed ;Status
Send {Tab}
Send Telemarketing ;Category
Send {Tab}
Sleep 1000
Send +{Tab}

;Subcategory
if (conversion) {
  Send TM Upgrade
  Send {Space}
  Send %campaign%
  Send {Space}
  Send Months
}
else {
  Send %outcomeFinal%
}

Send {Tab}

FormatTime, TimeString,, dd/MM/yyyy
Send, %TimeString% ;Expected date
Sleep 1000
Loop, 5
{
  Send {Tab}
  Sleep 100
}
Send Phone - Outgoing ;Contact method
Send {Tab}
Sleep 100
Send {Tab}
Send %TimeString% ;Actual date
Loop, 4 {
  Send {Tab}
  Sleep 100
}

;Filling out comments
Send Telefund -{Space}
outcomeComment := outcome . outcomeEnd
Send %outcomeComment%{Space}

if (conversion) ;If it is a conversion
{
  Send of $%upgradeAmount%{Space}
  Send , from $%originalAmount% to $%totalAmount%.{Space}
}
Send -{Space}
Send %userInitials%

;Move to the save button
Loop, 3 {
  Send {Tab}
  Sleep 100
}

Return

/*
*This function will find and image and press it. It will wait until the image can be found.
*/
pressImage(imageFileName, xOffset:=0, yOffset:=0)
{
  ;CoordMode Pixel
  Loop
  {
    WinGetPos, X, Y, W, H, A
    ImageSearch, FoundX, FoundY, 0, 0, W, H, *15 searchImages\%imageFileName%
    if (ErrorLevel = 2){
      MsgBox Could not conduct the search.
      Exit
    }
    if (ErrorLevel = 0) {
      break
    }
  }  Sleep 100
  ;CoordMode Mouse
  clickX := FoundX + xOffset
  clickY := FoundY + yOffset
  Click, %clickX% %clickY%
  Sleep 100
  return
}

Esc::ExitApp
