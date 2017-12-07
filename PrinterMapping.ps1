# Configuration
################################
$p1 = 'DH-HVAPP02.dah.int'
$p2 = 'DH-HVPRINT01.dah.int'
$GroupPattern = 'ACB\Drucker_mit_*' 
#$LogPath = "C:\EDV\Log"
#$LogFile = "$env:USERNAME.log"

# Printer Definition File
################################
$CSVDelim = ';'
$PrnDelim = '@'
$PrinterList = "$(Split-Path -Path $SCRIPT:MyInvocation.MyCommand.Path -Parent)\Drucker_TS_PP.TXT"
$PrinterData = Import-Csv -Path $PrinterList -Delimiter $CSVDelim


#If (!(Test-Path $LogPath)) {New-Item $LogPath -type directory}

$net = New-Object -ComObject WScript.Network

# Read Usergroups
################################
$id = [Security.Principal.WindowsIdentity]::GetCurrent()
$groups = $id.Groups | foreach-object {$_.Translate([Security.Principal.NTAccount])} |  Where-Object {$_ -like $GroupPattern}

foreach ($group in $groups) { 
  $Printer2Map = ($PrinterData | Where-Object {$_.gruppe -like $Group.Value.Split('\')[-1]}).Drucker.Split($PrnDelim)
}

foreach ($printer in $Printer2Map) {
 if ($printer -like '\\$P1*') {$MapMe = $printer.replace('$P1',$p1)}
 elseif ($printer -like '\\$P2*') {$MapMe = $printer.replace('$P2',$p2)}
 
 Try {
    $net.AddWindowsPrinterConnection($MapMe) 
 }
 Catch 
 {
   # get error record
   [Management.Automation.ErrorRecord]$e = $_

   # retrieve information about runtime error
   $info = [PSCustomObject]@{
     Exception = $e.Exception.Message
     Reason    = $e.CategoryInfo.Reason
     Target    = $e.CategoryInfo.TargetName
     Script    = $e.InvocationInfo.ScriptName
     Line      = $e.InvocationInfo.ScriptLineNumber
     Column    = $e.InvocationInfo.OffsetInLine
   }
   
   # output information. Post-process collected info, and log info (optional)
   #$info
 }
 
}

