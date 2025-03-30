' tYDiSync~ - Silent Launcher
' This script launches the tYDiSync~ system silently
' without showing any console window.
'
' Part of the tY FischEYe ecosystem connecting with the "Dreamflo ~" philosophy

Option Explicit

Dim WshShell, scriptPath, nodePath, workingDir, commandToRun

' Get the script directory
workingDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)

' Set up paths
nodePath = "node"
scriptPath = workingDir & "\sync-system\core\tydisync.js"  ' Path to main script file

' Create shell object
Set WshShell = CreateObject("WScript.Shell")

' Change to working directory
WshShell.CurrentDirectory = workingDir

' Build command line
commandToRun = nodePath & " """ & scriptPath & """ --watch"

' Execute the command silently (0 = hidden window)
WshShell.Run commandToRun, 0, False

' Clean up
Set WshShell = Nothing 