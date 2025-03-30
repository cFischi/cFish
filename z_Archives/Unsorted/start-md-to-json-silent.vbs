Option Explicit

' This script runs the MD-to-JSON watcher silently in the background
' It can be used with Windows Task Scheduler for automatic startup

' Get the script directory
Dim fso, scriptDir
Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)

' Run the batch file silently
Dim shell, cmd
Set shell = CreateObject("WScript.Shell")
cmd = """" & scriptDir & "\start-md-to-json-watcher.bat"""
shell.Run cmd, 0, False  ' Run minimized and don't wait

Set shell = Nothing
Set fso = Nothing

' Script ends immediately, but the watcher continues running in background 