<#
    .SYNOPSIS
        Removes a ServiceDesk Plus request by id.

    .DESCRIPTION
        Removes a ServiceDesk Plus request by id.

    .EXAMPLE
        PS C:\> Remove-ServiceDeskRequest -Id 12345
        Remove ServiceDesk Plus request with id 12345

    .EXAMPLE
        PS C:\> Get-ServiceDeskRequest -Id 12345 | Remove-ServiceDeskRequest
        Remove ServiceDesk Plus request with id 12345

    .EXAMPLE
        PS C:\> "12345", "67890" | Remove-ServiceDeskRequest
        Remove ServiceDesk Plus requests 12345 and 67890
#>

function Remove-ServiceDeskRequest {
    param (
        # ID of the ServiceDesk Plus request
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int[]]
        $Id,

        # Base URI of the ServiceDesk Plus server, i.e. https://sdp.example.com
        [Parameter(Mandatory)]
        $Uri,

        # ServiceDesk Plus API KEY
        [Parameter(Mandatory)]
        $ApiKey
    )

    process {
        foreach ($RequestId in $Id) {
            $Parameters = @{
                Body = @{
                    TECHNICIAN_KEY = $ApiKey
                }
                Method = "Delete"
                Uri = "$Uri/api/v3/requests/$RequestId/move_to_trash"
            }

            $Response = Invoke-RestMethod @Parameters

            [PSCustomObject] @{
                Message = $Response.response_status.status
            }
        }
    }
}