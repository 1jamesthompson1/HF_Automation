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
    InputBox, widthOfSpreadSheet, %programName%, What is the width
    if ErrorLevel
      ExitApp
    loop {
      InputBox, campaign, %programName%, What is the campagin?
      if (campaign != 6 && campaign != 18 && campaign != 30) {
        MsgBox, Please just enter either 6, 18, or 30
      }
      else break 1
    }
    IniRead, userInitials, config.ini, userDetails, userInitials
    break
  }
}

Home::F14

F14::
;Grab the constituents ID
loop %widthOfSpreadSheet%
{
  Send, {Left}
  Sleep 100
}
Send, ^c
Sleep 100
;Move to the Kete Tab
Send, ^{Tab}
Sleep 500

;Find the search bar and click on it
pressImage("searchBar.png")
Sleep 1000

;Enter consistents ID and enter
Send, ^v
Send, {Enter}
Sleep 1000
Send, {Enter}

Sleep 2000
;Go to interaction
pressImage("interaction.png")
Sleep 1000
;Get wether it is a conversion or NTC
MsgBox , 260,YTC or NTC, Was it a YTC?
IfMsgBox Yes
  InputBox, upgradeAmount, Upgrade amount, What was the upgrade amount please?
else
  upgradeAmount := 0


outcomeStart := "TM-RG "
outcomeEnd := " to Upgrade"
if (upgradeAmount > 0) ;If it is a conversion
{
  outcome := "Yes"
}
else ;not a conversion
{
  outcome := "No"
}
outcomeFinal := outcomeStart . outcome . outcomeEnd
Send %outcomeFinal%

Send {Tab}
Send Completed
Send {Tab}
Send Telemarketing
Send {Tab}
Sleep 1000
Send +{Tab}

if (upgradeAmount > 0) {
  Send TM Upgrade
  Send {Space}
  Send %campaign%
  Send {Space}
  Send Months
}
else {
  Send outcomeFinal
}

Send {Tab}
FormatTime, TimeString,, dd/MM/yyyy
Send, %TimeString%
Sleep 1000
Loop, 5
{
  Send {Tab}
  Sleep 100
}
Send Phone - Outgoing
Send {Tab}
Sleep 100
Send {Tab}
Send %TimeString%
Loop, 4 {
  Send {Tab}
  Sleep 100
}
;Filling out comments
Send Telefund -{Space}
outcomeComment := outcome . outcomeEnd
Send %outcomeComment%{Space}

if (upgradeAmount > 0) ;If it is a conversion
{
  Send of %upgradeAmount%{Space}
}
Send -{Space}
Send %userInitials%

Loop, 3 {
  Send {Tab}
  Sleep 100
}

Return

pressImage(imageFileName)
{
  CoordMode Pixel
  Loop
  {
    ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, searchImages\%imageFileName%
    if (ErrorLevel = 2){
      MsgBox Could not conduct the search.
      Exit
    }
    if (ErrorLevel = 0) {
      break
    }
  }
  Sleep 100
  CoordMode Mouse
  Click, %FoundX% %FoundY%
  Sleep 100
  return
}
