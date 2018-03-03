# download videos from a list using you-get.exe, Windows 10, powershell
# required: vlist.txt
#
# the script scanns the file and download links starting with "http"
# video failed to be downloaded or larger than 100 MB are stored in file "error.txt"

chcp 65001

$size_limit = 100 # in MB
$trial_limit = 10 # call you-get up to trial_limit times

if (!(Test-Path -PathType Leaf error.txt)) {
    New-Item -ItemType File error.txt
}

$VideoTitle = ""
foreach($line in Get-Content -Encoding UTF8 .\vlist.txt) {
    Copy-Item vlist.txt vlist-old.txt

    if ($line -match "http.*") {
        Write-Output $line
        if (!(Test-Path -Path Downloaded)) {
            New-Item -ItemType directory -Path Downloaded
        }
        $pvalue = 1
        while ($counter -ne $trial_limit) {
            Try{
                $json = you-get.exe --json --format=mp4 $line | ConvertFrom-Json
                if ([int]($json.'streams'.'mp4'.'size') -lt ($size_limit * 1000000)) {
                    you-get.exe -o Downloaded --format=mp4 $line
                    if ($LASTEXITCODE -match 1) {
                        continue
                    }
                    else {
                        $pvalue = 0
                        break
                    }
                }
                else {
                    Add-Content error.txt -Value $VideoTitle
                    Add-Content error.txt -Value $line
					$pvalue = 0
                    break
                }
            }
            Catch{
                Start-Sleep(3)
                continue
            }
        }

        if ($pvalue -eq 1) {
            Add-Content error.txt -Value $VideoTitle
            Add-Content error.txt -Value $line
        }

		get-content -encoding UTF8 vlist.txt | Select-Object -skip 2 | set-content -encoding UTF8 "tmp.txt"
		Move-Item tmp.txt vlist.txt -Force

    } else {
        $VideoTitle = $line
    }
}


# StopWatch
# $StopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
# $StopWatch.Start()  .Stop()   .IsRunning   .Elapsed
# $time = $StopWatch.Elapsed | ConvertTo-Json | ConvertFrom-Json

# Send key
# $x = New-Object -COM WScript.Shell
# $x.SendKeys($KeyToPress)
# $KeyToPress = '~' # ENTER key

