#NoEnv                                              ; Recommended for performance and compatibility with future AutoHotkey releases.
#Include ./Eval.ahk                                 ; Does the math
SendMode Input                                      ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%                         ; Ensures a consistent starting directory.
NLpress = 0                                         ; Prepare variable

DetectTextbox()
  {
    boardBK := Clipboard
    Clipboard :=
    send {{}+{left}^c{right}
    ClipWait, 1
    if (Clipboard = "{")
      {
        Clipboard := boardBK
        return true
      }
    else
    {
      Clipboard := boardBK
      return false
    }
}

OnKey(x,y)
  {
    sendraw %y%
    return
  }

Inline()
{
  Equation := InputHook(, "{sc11c}")                ; Get keypresses for the Equation
  Equation.NotifyNonText := True                    ; Allow next line to see everythin
  Equation.OnChar := Func("OnKey")                  ; When a key is pressed that isnt enter, passthrough
  send {}}{Left}                                    ; Send right brace
  Equation.start()                                  ; Start watching
  Equation.Wait()                                   ; Wait for enter key
  string := Eval(Equation.Input).1                  ; Set the result string
  L := StrLen(Equation.Input)
  send {del}                                        ; Clear the closing brace
  Loop, %L%                                         ; Clear the equation
    {
      send {BS}
    }
  send {bs}                                         ; Clear the opening brace
  Send %string%                                     ; Send the result
  return
}

~NumLock::                                          ; Doesnt block NumLock from system bc of ~
  if (NLpress = 0)
    SetTimer, Reset, -400                           ; Wait 400 ms for more presses then reset
  NLpress += 1                                      ; SetTimer already started, so we log the keypress instead.
  if (NLpress = 3)
  {
  SetTimer, Reset, Off                              ; Stop the timer
  SetNumLockState, On                               ; Ensure NumLock is on
    if (DetectTextbox())                            ; Detect if user is in a textbox
    {
      Inline()                                      ; Does inline math
    }
    else
      {
      if WinActive("Calculator")                    ; If Calculator is already open, reopen saved window
        WinActivate, %Title%
      else                                          ; If its not, open it
        {
          WinGetActiveTitle, Title                  ; Save the window
          WinActivate Calculator, ,Calculator.ahk   ; Try to activate the calculator window
          if WinActive("Calculator") = 0            ; If it didnt work, start the calculator
            Run Calc.exe
      }
    }
  Goto reset
  }
  return
Reset:
  NLpress := 0                                      ; Reset for next counter
  return
