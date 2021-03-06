function EventLogSuccess {
    Try {
        Get-WinEvent -ListLog Security|out-null
    }
    Catch { return 'PowerShell Get-WinEvent cmdlet Error. Please Use EventLogSuccessWevtutil' }
    Try {
        $Events = Get-WinEvent -LogName "Security" -FilterXPath "*[EventData[(Data[@Name='LogonType']='10')] and System[EventID=4624]]" -ErrorAction Stop
        ForEach ($Event in $Events) {
            $eventXML = [xml]$Event.ToXml()
            Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name "TimeCreate" -Value $Event.TimeCreated
            FOREACH ($j in $eventXML.Event.System.ChildNodes) {
                Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name $j.ToString() -Value $eventXML.Event.System.($j.ToString())
            }
            For ($i=0; $i -lt $eventXML.Event.EventData.Data.Count; $i++) {     
                Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name $eventXML.Event.EventData.Data[$i].name -Value $eventXML.Event.EventData.Data[$i].'#text'
            }
        }
        $Events |select TimeCreate,EventRecordID,TargetUserName,IpAddress,IpPort
    }
    Catch { return 'Result: Null'}
}