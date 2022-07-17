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
        if (campaign < 30) {
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
WinGetPos, X, Y, W, H, A
if (W < 985) { ;At this point the distnace does not decrease
  clickX := 756
} else if (W <= 1215) { ;There is a step
  clickX := W*0.477 + 290
} else { ;When it is the largest
  clickX := W*0.477 + 292  - 80
}
Click, %clickX% 144

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
  Send %outcomeFinal%
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
  Send , from $%originalAmount% to $%totalAmount%.{Space}
}



Send -{Space}
Send %userInitials%

Loop, 3 {
  Send {Tab}
  Sleep 100
}

Return

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

return
