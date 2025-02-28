﻿using namespace System.Net

Function Invoke-ExecStartManagedFolderAssistant {
    <#
    .FUNCTIONALITY
        Entrypoint
    .ROLE
        Exchange.Mailbox.ReadWrite
    #>
    [CmdletBinding()]
    param($Request, $TriggerMetadata)

    $APIName = $Request.Params.CIPPEndpoint
    $Headers = $Request.Headers
    Write-LogMessage -Headers $Headers -API $APIName -message 'Accessed this API' -Sev 'Debug'

    # Interact with query parameters or the body of the request.
    $Tenant = $Request.Query.tenantFilter ?? $Request.Body.tenantFilter
    $ID = $Request.Query.ID ?? $Request.Body.ID

    try {
        $null = New-ExoRequest -tenantid $Tenant -cmdlet 'Start-ManagedFolderAssistant' -cmdParams @{Identity = $ID; AggMailboxCleanup = $true; FullCrawl = $true }
        $Result = "Successfully started Managed Folder Assistant for mailbox $($ID)."
        $Severity = 'Info'
        $StatusCode = [HttpStatusCode]::OK
    } catch {
        $ErrorMessage = Get-CippException -Exception $_
        $Result = "Failed to start Managed Folder Assistant for mailbox $($ID). Error: $($ErrorMessage.NormalizedError)"
        $Severity = 'Error'
        $StatusCode = [HttpStatusCode]::InternalServerError
    } finally {
        Write-LogMessage -Headers $Headers -API $APIName -tenant $Tenant -message $Result -Sev $Severity -LogData $ErrorMessage
    }

    $Body = [pscustomobject] @{ 'Results' = $Result }
    # Associate values to output bindings by calling 'Push-OutputBinding'.
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = $StatusCode
            Body       = $Body
        })
}
