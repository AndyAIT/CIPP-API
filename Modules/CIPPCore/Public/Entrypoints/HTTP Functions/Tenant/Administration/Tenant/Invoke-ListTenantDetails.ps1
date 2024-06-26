using namespace System.Net

Function Invoke-ListTenantDetails {
    <#
    .FUNCTIONALITY
    Entrypoint
    #>
    [CmdletBinding()]
    param($Request, $TriggerMetadata)

    $APIName = $TriggerMetadata.FunctionName

    Write-LogMessage -user $request.headers.'x-ms-client-principal' -API $APINAME -message 'Accessed this API' -Sev 'Debug'

    try {
        $tenantfilter = $Request.Query.TenantFilter
        $org = New-GraphGetRequest -uri 'https://graph.microsoft.com/beta/organization' -tenantid $tenantfilter | Select-Object displayName, id, city, country, countryLetterCode, street, state, postalCode,
        @{ Name = 'businessPhones'; Expression = { $_.businessPhones -join ', ' } },
        @{ Name = 'technicalNotificationMails'; Expression = { $_.technicalNotificationMails -join ', ' } },
        tenantType, createdDateTime, onPremisesLastPasswordSyncDateTime, onPremisesLastSyncDateTime, onPremisesSyncEnabled, assignedPlans
    } catch {
        $org = [PSCustomObject]@{
            displayName                        = 'Error loading tenant'
            id                                 = ''
            city                               = ''
            country                            = ''
            countryLetterCode                  = ''
            street                             = ''
            state                              = ''
            postalCode                         = ''
            businessPhones                     = ''
            technicalNotificationMails         = ''
            createdDateTime                    = ''
            onPremisesLastPasswordSyncDateTime = ''
            onPremisesLastSyncDateTime         = ''
            onPremisesSyncEnabled              = ''
            assignedPlans                      = @()
        }
    } finally {
        $Body = $org
    }

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::OK
            Body       = $Body
        })
    

}
