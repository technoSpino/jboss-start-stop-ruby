Set WshShell = CreateObject("WScript.Shell") 
Set objArgs = WScript.Arguments
jboss_home=WshShell.ExpandEnvironmentStrings("%JBOSS_HOME%")
WshShell.Run chr(34) & jboss_home & "bin\run.bat " & Chr(34) & "-c " & objArgs(0) & " -b " & objArgs(1) & " -Djboss.service.binding.set=" & objArgs(2),0  
Set WshShell = Nothing
