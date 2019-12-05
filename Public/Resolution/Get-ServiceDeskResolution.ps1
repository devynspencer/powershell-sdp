<#
    .SYNOPSIS
        Returns the resolution of a ServiceDesk Plus request by id. 

    .EXAMPLE
        PS C:\> Get-ServiceDeskRequest -Id 12345 | Get-ServiceDeskResolution
        Return the resolution of ServiceDesk Plus request with id 12345

    .EXAMPLE
        PS C:\> "12345", "67890" | Get-ServiceDeskRequest | Get-ServiceDeskResolution
        Return the resolution of ServiceDesk Plus requests 12345 and 67890
#>

function Get-ServiceDeskResolution {
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
                Method = "Get"
                Uri = "$Uri/api/v3/requests/$RequestId/resolutions"
            }

            $Response = Invoke-RestMethod @Parameters

            [PSCustomObject] @{
                Message = $Response.resolution.content
                Attachments = $Response.resolution.resolution_attachments
                AuthorName = $Response.resolution.submitted_by.name
                AuthorEmail = $Response.resolution.submitted_by.email_id.ToLower()
                SubmissionTime = if ($Response.resolution.submitted_on) { $Response.resolution.submitted_on.display_value | Get-Date } else { $null }
            }
        }
    }
}