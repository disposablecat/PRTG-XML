#####Functions#####

function Get-PRTGXMLInheritanceBreaks{
<#
.SYNOPSIS
    Finds all PRTG objects that have inheritance breaks
.DESCRIPTION
    Finds all PRTG objects that have inheritance breaks. Must point at the PRTG config file. Will return an array of objects(probes, groups, devices, sensors) that match
    along with the settings that have changed.
.PARAMETER File
    Provide the path to the PRTG configuration file. It is recommnded that you use a backup of your configuration file.
.NOTES
    Version:        1.0
    Author:         disposablecat
    Purpose/Change: Initial script development
.EXAMPLE
    Get-PRTGXMLInheritanceBreaks -File ".\PRTG Configuration.dat"
    Returns all objects that have inheritance breaks and what settings have changed.
.EXAMPLE
    Get-PRTGXMLInheritanceBreaks -File "D:\ProgramData\Paessler\PRTG Network Monitor\PRTG Configuration.old"
    Returns all objects that have inheritance breaks and what settings have changed.
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[System.Object]])]
    
    #Define parameters
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [string[]]$File
    )

    Begin
    {
        #Create node list
        $Nodes = New-Object System.Collections.Generic.List[System.Object]
        #Base object for changes
        $ChangeObjectBase = New-Object PSObject; 
        $ChangeObjectBase | Add-Member -type Noteproperty -Name Name -Value $Null
        $ChangeObjectBase | Add-Member -type Noteproperty -Name ID -Value $Null
        $ChangeObjectBase | Add-Member -type Noteproperty -Name Type -Value $Null
        $ChangeObjectBase | Add-Member -type Noteproperty -Name SettingsNotInherit -Value $Null
        #Base array for collecting settings
        $TempInheritBase = @()
        #Name filter for probe settings
        $ProbeNameMatch = 'accessrights$|analysisgroup$|awsak$|awssk$|cloudcredentials$|dbauth$|dbcredentials$|dbpassword$|dbport$|dbtimeout$|dbuser$|depdelay$|dependency$|Dependencytype$|elevationnamesu$|elevationnamesudo$|elevationpass$|errorintervalsdown$|esxpassword$|esxprotocol$|esxuser$|force32$|httpproxy$|ignoreoverflow$|ignorezero$|inherittriggers$|interval$|intervalgroup$|linuxconnection$|linuxloginmode$|linuxloginpassword$|linuxloginusername$|locationgroup$|maintenable$|portend$|portstart$|portupdateoid$|privatekey$|proxy$|proxypassword$|proxyport$|proxyuser$|retrysnmp$|scheduledependency$|snmpauthmode$|snmpauthpass$|snmpcommv1$|snmpcommv2$|snmpcompatibilty$|snmpcontext$|snmpdebuglog$|snmpdelay$|snmpencmode$|snmpencpass$|snmpport$|snmptimeout$|snmpuser$|snmpversion$|snmpversiongroup$|sshelevatedrights$|sshport$|sshversion_devicegroup$|sysinfo$|trafficportname$|unitconfig$|unitconfiggroup$|updateportname$|usedbcustomport$|usesingleget$|vmwareconnection$|vmwaresessionpool$|wantsimilarity$|wantunusual$|wbemport$|wbemportmode$|wbemprotocol$|windowsconnection$|windowslogindomain$|windowsloginpassword$|windowsloginusername$|wmicompatibility$|wmiorpc$|wmitimeout$|wmitimeoutmethod$'
        #Name filter for group settings
        $GroupNameMatch = 'accessrights$|analysisgroup$|awsak$|awssk$|cloudcredentials$|dbauth$|dbcredentials$|dbpassword$|dbport$|dbtimeout$|dbuser$|depdelay$|dependency$|Dependencytype$|elevationnamesu$|elevationnamesudo$|elevationpass$|errorintervalsdown$|esxpassword$|esxprotocol$|esxuser$|force32$|httpproxy$|ignoreoverflow$|ignorezero$|inherittriggers$|interval$|intervalgroup$|linuxconnection$|linuxloginmode$|linuxloginpassword$|linuxloginusername$|locationgroup$|maintenable$|portend$|portstart$|portupdateoid$|privatekey$|proxy$|proxypassword$|proxyport$|proxyuser$|retrysnmp$|scheduledependency$|snmpauthmode$|snmpauthpass$|snmpcommv1$|snmpcommv2$|snmpcompatibilty$|snmpcontext$|snmpdebuglog$|snmpdelay$|snmpencmode$|snmpencpass$|snmpport$|snmptimeout$|snmpuser$|snmpversion$|snmpversiongroup$|sshelevatedrights$|sshport$|sshversion_devicegroup$|sysinfo$|trafficportname$|unitconfig$|unitconfiggroup$|updateportname$|usedbcustomport$|usesingleget$|vmwareconnection$|vmwaresessionpool$|wantsimilarity$|wantunusual$|wbemport$|wbemportmode$|wbemprotocol$|windowsconnection$|windowslogindomain$|windowsloginpassword$|windowsloginusername$|wmicompatibility$|wmiorpc$|wmitimeout$|wmitimeoutmethod$'
        #Name filter for device settings
        $DeviceNameMatch = 'accessrights$|analysisgroup$|awsak$|awssk$|cloudcredentials$|dbauth$|dbcredentials$|dbpassword$|dbport$|dbtimeout$|dbuser$|depdelay$|dependency$|Dependencytype$|elevationnamesu$|elevationnamesudo$|elevationpass$|errorintervalsdown$|esxpassword$|esxprotocol$|esxuser$|force32$|httpproxy$|ignoreoverflow$|ignorezero$|inherittriggers$|interval$|intervalgroup$|linuxconnection$|linuxloginmode$|linuxloginpassword$|linuxloginusername$|locationgroup$|maintenable$|portend$|portstart$|portupdateoid$|privatekey$|proxy$|proxypassword$|proxyport$|proxyuser$|retrysnmp$|scheduledependency$|snmpauthmode$|snmpauthpass$|snmpcommv1$|snmpcommv2$|snmpcompatibilty$|snmpcontext$|snmpdebuglog$|snmpdelay$|snmpencmode$|snmpencpass$|snmpport$|snmptimeout$|snmpuser$|snmpversion$|snmpversiongroup$|sshelevatedrights$|sshport$|sshversion_devicegroup$|sysinfo$|trafficportname$|unitconfig$|unitconfiggroup$|updateportname$|usedbcustomport$|usesingleget$|vmwareconnection$|vmwaresessionpool$|wantsimilarity$|wantunusual$|wbemport$|wbemportmode$|wbemprotocol$|windowsconnection$|windowslogindomain$|windowsloginpassword$|windowsloginusername$|wmicompatibility$|wmiorpc$|wmitimeout$|wmitimeoutmethod$'
        #Name filter for sensor settings
        $SensorNameMatch = 'accessrights$|interval$|inherittriggers$|schedule$'   
    }
    Process
    {
        ForEach($F in $File)
        {
            Try
            {
                #Test if file exists and can be read.
                Write-Verbose "$(Get-Date -Format "yyyy-MM-dd:HH:mm:ss:ff") - Verifying if File can be read."
                if(Test-Path -Path $F)
                {
                    Write-Verbose "$(Get-Date -Format "yyyy-MM-dd:HH:mm:ss:ff") - $($F) exists."
                }
                else
                {
                    throw "Cannot read $($F)."
                }
                #Load XML file
                $Xml=New-Object Xml
                $Xml.Load((Convert-Path -Path $F))
                #Get Probe nodes
                Write-Verbose "$(Get-Date -Format "yyyy-MM-dd:HH:mm:ss:ff") - Starting probe node iteration."
                $xml| Select-Xml -XPath "//nodes/probenode" | Select -ExpandProperty "node" | % {
                    $ChangeObject = $ChangeObjectBase | Select *
                    $ID = [int]$_.id
                    $ChangeObject.ID = $_.id
                    $ChangeObject.Name = $_.data.name.Trim()
                    $ChangeObject.Type = "probe"
                    $TempInherit = $TempInheritBase
                    #loop through settings nodes to compare and collect matching settings
                    ForEach ($Setting in $_.data.ChildNodes)
                    {
                        #Check for inherited flag, matching names, node value to see if inheritance is broken
                        if(($Setting.flags.inherited -eq $null) -and ($Setting.name -match $ProbeNameMatch) -and ($Setting.InnerText.Trim() -notmatch "1"))
                        {
                            $TempInherit += $Setting.name
                        }
                    }
                    #Check if TempInherit array is empty, if not add entry.
                    if($TempInherit.count -gt 0)
                    {
                        $ChangeObject.SettingsNotInherit = "$TempInherit"
                        $Nodes.Add($ChangeObject)
                    }
                }
                #Get Group nodes
                Write-Verbose "$(Get-Date -Format "yyyy-MM-dd:HH:mm:ss:ff") - Starting group node iteration."
                $xml| Select-Xml -XPath "//nodes/group" | Select -ExpandProperty "node" | % {
                    $ChangeObject = $ChangeObjectBase | Select *
                    $ID = [int]$_.id
                    $ChangeObject.ID = $_.id
                    $ChangeObject.Name = $_.data.name.Trim()
                    $ChangeObject.Type = "group"
                    $TempInherit = $TempInheritBase
                    #Skip root group. Cannot inherit from anywhere.
                    if ($ID -eq 0)
                    {
                        Write-Verbose "$(Get-Date -Format "yyyy-MM-dd:HH:mm:ss:ff") - Found root group. Skipping."
                    }
                    #Check all other nodes besides root group
                    else
                    {
                        #loop through settings nodes to compare and collect matching settings
                        ForEach ($Setting in $_.data.ChildNodes)
                        {
                            #Check for inherited flag, matching names, node value to see if inheritance is broken
                            if(($Setting.flags.inherited -eq $null) -and ($Setting.name -match $GroupNameMatch) -and ($Setting.InnerText.Trim() -notmatch "1"))
                            {
                                $TempInherit += $Setting.name
                            }
                        }
                        #Check if TempInherit array is emptry, if not add entry.
                        if($TempInherit.count -gt 0)
                        {
                            $ChangeObject.SettingsNotInherit = "$TempInherit"
                            $Nodes.Add($ChangeObject)
                        }
                    }
                }

                #Get Device nodes
                Write-Verbose "$(Get-Date -Format "yyyy-MM-dd:HH:mm:ss:ff") - Starting device node iteration."
                $xml| Select-Xml -XPath "//nodes/device" | Select -ExpandProperty "node" | % {
                    $ChangeObject = $ChangeObjectBase | Select *
                    $ID = [int]$_.id
                    $ChangeObject.ID = $_.id
                    $ChangeObject.Name = $_.data.name.Trim()
                    $ChangeObject.Type = "device"
                    $TempInherit = $TempInheritBase
                    #loop through settings nodes to compare and collect matching settings
                    ForEach ($Setting in $_.data.ChildNodes)
                    {
                        #Check for inherited flag, matching names, node value to see if inheritance is broken
                        if(($Setting.flags.inherited -eq $null) -and ($Setting.name -match $DeviceNameMatch) -and ($Setting.InnerText.Trim() -notmatch "1"))
                        {
                            $TempInherit += $Setting.name
                        }
                    }
                    #Check if TempInherit array is empty, if not add entry.
                    if($TempInherit.count -gt 0)
                    {
                        $ChangeObject.SettingsNotInherit = "$TempInherit"
                        $Nodes.Add($ChangeObject)
                    }
                }

                #Get Sensor nodes
                Write-Verbose "$(Get-Date -Format "yyyy-MM-dd:HH:mm:ss:ff") - Starting sensor node iteration."
                $xml| Select-Xml -XPath "//nodes/sensor" | Select -ExpandProperty "node" | % {
                    $ChangeObject = $ChangeObjectBase | Select *
                    $ID = [int]$_.id
                    $ChangeObject.ID = $_.id
                    $ChangeObject.Name = $_.data.name.Trim()
                    $ChangeObject.Type = "sensor"
                    $TempInherit = $TempInheritBase
                    #loop through settings nodes to compare and collect matching settings
                    ForEach ($Setting in $_.data.ChildNodes)
                    {
                        #Check for inherited flag, matching names, node value to see if inheritance is broken
                        if(($Setting.flags.inherited -eq $null) -and ($Setting.name -match $SensorNameMatch) -and ($Setting.InnerText.Trim() -notmatch "1"))
                        {
                            $TempInherit += $Setting.name
                        }
                    }
                    #Check if TempInherit array is empty, if not add entry.
                    if($TempInherit.count -gt 0)
                    {
                        $ChangeObject.SettingsNotInherit = "$TempInherit"
                        $Nodes.Add($ChangeObject)
                    }
                }
                Write-Verbose "$(Get-Date -Format "yyyy-MM-dd:HH:mm:ss:ff") - Iteration done."
            }
            Catch
            {
                #Catch any error.
                Write-Verbose “$(Get-Date -Format "yyyy-MM-dd:HH:mm:ss:ff") - Exception Caught: $($_.Exception.Message)”
            }
        }
        return $Nodes
    }
    End
    {
        #Will execute last. Will execute once. Good for cleanup. 
    }
}
