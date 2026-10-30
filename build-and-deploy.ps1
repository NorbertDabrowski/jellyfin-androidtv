param(
	[Parameter(Mandatory)][string]$Device,
	[string]$JavaHome = 'C:\Program Files\Eclipse Adoptium\jdk-21.0.5.11-hotspot'
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$env:JAVA_HOME = $JavaHome

function Invoke-Native([scriptblock]$Command) {
	& $Command
	if ($LASTEXITCODE -ne 0) { throw "Command failed with exit code ${LASTEXITCODE}: $Command" }
}

Invoke-Native { .\gradlew.bat assembleDebug }

$apk = Get-ChildItem app\build\outputs\apk\debug\*.apk | Select-Object -First 1
if (-not $apk) { throw 'No debug APK found.' }

Invoke-Native { adb connect $Device }
Invoke-Native { adb -s $Device install -r $apk.FullName }
