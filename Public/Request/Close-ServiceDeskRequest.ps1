<#
    .SYNOPSIS
        Closes a ServiceDesk Plus request by id.

    .DESCRIPTION
        Closes a ServiceDesk Plus request by id.

    .EXAMPLE
        PS C:\> Close-ServiceDeskRequest -Id 12345
        Close ServiceDesk Plus request with id 12345

    .EXAMPLE
        PS C:\> Get-ServiceDeskRequest -Id 12345 | Close-ServiceDeskRequest
        Close ServiceDesk Plus request with id 12345

    .EXAMPLE
        PS C:\> "12345", "67890" | Close-ServiceDeskRequest
        Close ServiceDesk Plus requests 12345 and 67890
#>

function Close-ServiceDeskRequest {
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
    
    begin {
        $InputData = @{
            request = @{
                closure_info = @{
                    requester_ack_resolution = $true
                }
            }
        }
    }

    process {
        foreach ($RequestId in $Id) {
            $Parameters = @{
                Headers = @{
                    TECHNICIAN_KEY = $ApiKey
                }
                Method = "Put"
                Uri = "$Uri/api/v3/requests/$RequestId/close`?$($InputData | ConvertTo-Json -Depth 5 -Compress)"
            }

            $Response = Invoke-RestMethod @Parameters

            [PSCustomObject] @{
                Message = $Response.response_status.status
            }
        }
    }
}