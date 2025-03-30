' invisible.vbs
' This VBScript runs a command invisibly in the background
' Used by start-tydisync-background.bat to run the MD-JSON sync system
' without showing a console window

' Get command-line arguments
Set args = WScript.Arguments
scriptPath = args(0)

' Additional arguments (if any)
Dim cmdArgs
cmdArgs = ""
If args.Count > 1 Then
    For i = 1 To args.Count - 1
        cmdArgs = cmdArgs & " " & args(i)
    Next
End If

' Create shell object
Set WshShell = CreateObject("WScript.Shell")

' Build the command
nodeCommand = "node """ & scriptPath & """" & cmdArgs

' Run the command invisibly (0 = hide window)
WshShell.Run nodeCommand, 0, False

' Clean up
Set WshShell = Nothing 