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
        if (campagin < 30) {
          widthOfSpreadSheet := 36
        } else {
          widthOfSpreadSheet := 40
        }
        break
      }
    }
    IniRead, userInitials, config.ini, userDetails, userInitials
    break
  }
}

Home::
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
loop %widthOfSpreadSheet%
{
  Send, {Left}
  Sleep 100
}
Sleep 500
Send, ^c
Sleep 100
;Move to the Kete Tab
Send, ^{Tab}
Sleep 500

;Find the search bar and click on it
pressImage("searchBar.png")
Sleep 2000


;Enter consistents ID and enter
Send, ^v
Sleep 500
Send, {Enter}
Sleep 1000
Send, {Enter}

Sleep 2000
;Go to interaction
pressImage("interaction.png")
Sleep 1000


;Fill out the interaction


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
Send %outcomeFinal%

Send {Tab}
Send Completed
Send {Tab}
Send Telemarketing
Send {Tab}
Sleep 1000
Send +{Tab}

if (conversion) {
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

if (conversion) ;If it is a conversion
{
  Send of $%upgradeAmount%{Space}
}

Send , from $%originalAmount% to $%totalAmount%.{Space}

Send -{Space}
Send %userInitials%

Loop, 3 {
  Send {Tab}
  Sleep 100
}

Return

pressImage(imageFileName)
{
  ;CoordMode Pixel
  Loop
  {
    ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *6 searchImages\%imageFileName%
    if (ErrorLevel = 2){
      MsgBox Could not conduct the search.
      Exit
    }
    if (ErrorLevel = 0) {
      break
    }
  }
  Sleep 100
  ;CoordMode Mouse
  FoundX := FoundX + 10
  FoundY := FoundY + 10
  Click, %FoundX% %FoundY%
  Sleep 100
  return
}

Esc::ExitApp
