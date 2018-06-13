$commonItems = @(
     "Microsoft.BingWeather"
     "Microsoft.GetHelp"
     "Microsoft.Messaging"
     "Microsoft.MicrosoftOfficeHub"
     "Microsoft.MicrosoftStickyNotes"
     "Microsoft.MSPaint"
     "Microsoft.People"
     "Microsoft.Print3D"
     "Microsoft.Wallet"
     "Microsoft.WindowsAlarms"
     "Microsoft.WindowsCamera"
     "microsoft.windowscommunicationsapps"
     "Microsoft.WindowsFeedbackHub"
     "Microsoft.WindowsMaps"
     "Microsoft.WindowsSoundRecorder"
     "Microsoft.Windows.Photos"
     "Microsoft.XboxApp"
     "Microsoft.ZuneMusic"
     "Microsoft.ZuneVideo"
     "*skype*"
)

function NewArray()
{
    return New-Object -TypeName System.Collections.ArrayList
}

function ListAppx($name, $out)
{
    Get-AppxPackage $name | foreach {
        $out.Add($_) | Out-Null
    }
}

function RemoveItem($item)
{
    $name = $item.Name
    $answer = Read-Host "Remove $name (Y/N)?"
    $answer = $answer.ToLower()

    if ($answer[0] -eq 'y')
    {
        Write-Host "Removing $name..."
        $item | Remove-AppxPackage
    }
}

function RemoveItems($list)
{
    Write-Host "Do you wish to uninstall the following packages?"
    $list | foreach {
        $name = $_.Name
        Write-Host "    $name"
    }

    Write-Host ""
    $answer = Read-Host "[Y]es, [A]sk per item, [N]o?"
    $answer = $answer.ToLower()
    
    if ($answer[0] -eq 'y')
    {
        Write-Host "Removing all..."
        $list | Remove-AppxPackage
    }
    elseif ($answer[0] -eq 'a')
    {
        $list | foreach {
            RemoveItem $_
        }
    }
    else
    {
        Write-Host "Not removing anything."
    }
}

function GetCommonItems
{
    $list = NewArray
    $commonItems | foreach {
        ListAppx $_ $list
    }

    return $list
}

function RemoveCommonItems()
{
    $list = GetCommonItems
    RemoveItems $list
}

function ManualRemovePackage()
{
    while ($true)
    {
        $answer = Read-Host "Search string (enter nothing to abort)"
        if ($answer -eq "")
        {
            return
        }

        $list = Get-AppxPackage *$answer*
        if ($list.Count -eq 0)
        {
            Write-Host "No packages found."
        }
        elseif ($list.Count -eq 1)
        {
            RemoveItem $list[0]
        }
        else
        {
            RemoveItems $list
        }

        Write-Host ""
    }
}

function ListAllPackages()
{
    Write-Host "Full package list:"
    Get-AppxPackage | foreach {
        $name = $_.Name
        Write-Host "    $name"
    }
}

function main()
{
    Write-Host "Appx Clean Up"

    $quit = $false
    while ($quit -eq $false)
    {
        Write-Host ""
        Write-Host "Main Menu:"
        Write-Host "    1 - Remove common items"
        Write-Host "    2 - Manually remove package"
        Write-Host "    3 - List all packages"
        Write-Host "    Q - Quit"
        Write-Host ""

        $answer = Read-Host "Choice"
        $answer = $answer.ToLower()

        Write-Host ""

        switch ($answer[0])
        {
            '1' { RemoveCommonItems; break }
            '2' { ManualRemovePackage; break }
            '3' { ListAllPackages; break; }
            'q' { $quit = $true; break }
        }
    }
}

main