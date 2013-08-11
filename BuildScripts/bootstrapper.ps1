function Get-Boxstarter {
    if(Check-Chocolatey ){    
        Write-Output "Chocoltey installed, Installing Boxstarter Modules."
        cinst Boxstarter.Chocolatey
    }
    else {
        Write-Output "Did not detect Chocolatey and unable to install. Installation of Boxstarter is aborted."
    }
}

function Check-Chocolatey {
    if(-not $env:ChocolateyInstall -or -not (Test-Path "$env:ChocolateyInstall")){
        if(Confirm-Install){
            $env:ChocolateyInstall = "$env:systemdrive\chocolatey"
            New-Item $env:ChocolateyInstall -Force -type directory | Out-Null
            $url="http://chocolatey.org/api/v2/package/chocolatey/"
            iex ((new-object net.webclient).DownloadString("http://chocolatey.org/install.ps1"))
            Import-Module $env:ChocolateyInstall\chocolateyinstall\helpers\chocolateyInstaller.psm1
            $env:path="$env:path;$env:systemdrive\chocolatey\bin"
            Enable-Net40
        }
        else{
            return $false
        }
    }
    return $true
}

function Is64Bit {  [IntPtr]::Size -eq 8  }

function Enable-Net40 {
    if(Is64Bit) {$fx="framework64"} else {$fx="framework"}
    if(!(test-path "$env:windir\Microsoft.Net\$fx\v4.0.30319")) {
        Write-Output "Download and install .NET 4.0 Framework"
        $env:chocolateyPackageFolder="$env:temp\chocolatey\webcmd"
        Install-ChocolateyZipPackage 'webcmd' 'http://www.iis.net/community/files/webpi/webpicmdline_anycpu.zip' $env:temp
        .$env:temp\WebpiCmdLine.exe /products: NetFramework4 /SuppressReboot /accepteula
    }
}

function Confirm-Install {
    $caption = "Installing Chocoltey"
    $message = "Chocolatey is going to be downloaded and installed on your machine. Do you want to proceed?"
    $yes = new-Object System.Management.Automation.Host.ChoiceDescription "&Yes","Yes";
    $no = new-Object System.Management.Automation.Host.ChoiceDescription "&No","No";
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no);
    $answer = $host.ui.PromptForChoice($caption,$message,$choices,0)

    switch ($answer){
        0 {return $true; break}
        1 {return $false; break}
    }    
}