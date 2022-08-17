#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force

version := "v0.2.1"
programName := "HF Automation Script "version

;Setup loop
loop
{
  if !FileExist("config.ini") ;First time setup
  {
    InputBox, userInitials, %programName%, What is your intials?
    if ErrorLevel
        ExitApp
    IniWrite, %userInitials%, config.ini, userDetails, userInitials

    CoordMode, Mouse
    MsgBox, ,%programName%, Please press on the search bar
    MouseDisabling := !MouseDisabling
    Send {Home}
    sleep 200
    KeyWait, LButton, D
    MouseGetPos, xpos, ypos
    searchBarX := xpos
    searchBarY := ypos

    MouseDisabling := !MouseDisabling
    MsgBox, ,%programName%, Please press on the interaction
    MouseDisabling := !MouseDisabling
    Send {Home}
    sleep 200
    KeyWait, LButton, D
    MouseGetPos, xpos, ypos
    interactionX := xpos
    interactionY := ypos
    MouseDisabling := !MouseDisabling

    IniWrite, %searchBarX%, config.ini, Button Locations, searchBarX
    IniWrite, %searchBarY%, config.ini, Button Locations, searchBarY
    IniWrite, %interactionX%, config.ini, Button Locations, interactionX
    IniWrite, %interactionY%, config.ini, Button Locations, interactionY
    IniWrite, false, config.ini, userDetails, formatDateUS
    IniWrite, %version%, config.ini, Info, version
  }
  else ; Usual start up
  {
    IniRead, versionConfig, config.ini, Info, version
    if (version != versionConfig) {
      FileDelete, config.ini
      continue
    }
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

    IniRead, searchBarX, config.ini, Button Locations, searchBarX
    IniRead, searchBarY, config.ini, Button Locations, searchBarY
    IniRead, interactionX, config.ini, Button Locations, interactionX
    IniRead, interactionY, config.ini, Button Locations, interactionY
    IniRead, userInitials, config.ini, userDetails, userInitials
    IniRead, formatDateUS, config.ini, userDetails, formatDateUS
    break
  }
}

/*
*Main script. This should be started on the upgradeAmount column.
*/
Alt::
;Check if it is a conversion or not and get neccasary information
CoordMode, Mouse
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
Send, 200
Send, {Home}
Sleep 500

;Find the search bar and click on it
Click %searchBarX% %searchBarY%
Sleep 200
Send ^a
Sleep 100
Send {BackSpace}

;Enter consistents ID and enter
Send, ^v
Sleep 100
Send, {Enter}
Sleep 1000
Send, {Enter}

MsgBox, , %programName%, Has the account loaded, 5
;Go to interaction
Send, {Home}
Sleep 350
Click %interactionX% %interactionY%
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
Sleep 500
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
if (formatDateUS = "true") {
  FormatTime, TimeString,, MM/dd/yyyy
} else {
  FormatTime, TimeString,,dd/MM/yyyy
}

Send, %TimeString% ;Expected date
Sleep 1000
tab(5)
Send Phone - Outgoing ;Contact method
Send {Tab}
Sleep 100
Send {Tab}
Send %TimeString% ;Actual date
tab(4)

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
tab(3)

Return

/*
*Shorthand for looping through lots of tabs.
*/
tab(numOfTimes:=1)
{
  Loop, %numOfTimes% {
    Send, {Tab}
    Sleep 100
  }
  return
}

#if  MouseDisabling
LButton::return
#if 