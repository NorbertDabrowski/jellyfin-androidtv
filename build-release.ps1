param(
	[Parameter(Mandatory)][string]$Device
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

function Invoke-Native([scriptblock]$Command) {
	& $Command
	if ($LASTEXITCODE -ne 0) { throw "Command failed with exit code ${LASTEXITCODE}: $Command" }
}

Invoke-Native { .\gradlew.bat assembleRelease }

$apk = Get-ChildItem app\build\outputs\apk\release\*.apk | Where-Object Name -NotMatch 'unsigned' | Select-Object -First 1
if (-not $apk) { throw 'No signed release APK found. Set keystore.file, keystore.password, signing.key.alias and signing.key.password in local.properties.' }

Invoke-Native { adb connect $Device }
Invoke-Native { adb -s $Device install -r $apk.FullName }
