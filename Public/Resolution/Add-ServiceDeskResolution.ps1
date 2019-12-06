<#
    .SYNOPSIS
        Add a resolution to a service desk request.

    .DESCRIPTION
        Add a resolution to a service desk request.

        The same resolution can be applied to many requests all at once.

    .EXAMPLE
        PS C:\> Get-ServiceDeskRequest -Id 12345 | Add-ServiceDeskResolution -Message "Fixed issue, resolving ticket."
        Add resolution to ServiceDesk Plus request with id 12345

    .EXAMPLE
        PS C:\> "12345", "67890" | Get-ServiceDeskRequest | Add-ServiceDeskResolution -Message "Fixed issue, resolving ticket."
        Add resolution to ServiceDesk Plus requests 12345 and 67890
#>

function Add-ServiceDeskResolution {
    param (
        # ID of the ServiceDesk Plus request
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int[]]
        $Id,

        # Message to add as the ServiceDesk Plus request resolution
        [ValidateNotNullOrEmpty()]
        $Message = "Work complete, resolving ticket.",

        # Base URI of the ServiceDesk Plus server, i.e. https://sdp.example.com
        [Parameter(Mandatory)]
        $Uri,

        # ServiceDesk Plus API key
        [Parameter(Mandatory)]
        $ApiKey
    )

    begin {
        $InputData = @{
            resolution = @{
                content = $Message
            }
        }
    }

    process {
        foreach ($RequestId in $Id) {
            $Parameters = @{
                Body = @{
                    TECHNICIAN_KEY = $ApiKey
                    input_data = ($InputData | ConvertTo-Json -Depth 5 -Compress)
                }
                Method = "Post"
                Uri = "$Uri/api/v3/requests/$RequestId/resolutions"
            }

            $Response = Invoke-RestMethod @Parameters

            [PSCustomObject] @{
                Id = $Id
                Message = $Response.response_status.messages.message
            }
        }
    }
}