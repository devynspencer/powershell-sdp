<#
    .SYNOPSIS
        Resolve a ServiceDesk Plus request by id. 

    .EXAMPLE
        PS C:\> Resolve-ServiceDeskRequest -Id 12345
        Resolve ServiceDesk Plus request with id 12345

    .EXAMPLE
        PS C:\> "12345", "67890" | Resolve-ServiceDeskRequest
        Resolve ServiceDesk Plus requests 12345 and 67890

    .NOTES
        Simple wrapper for adding a resolution and immediately resolving.
        Also demonstrates a dubious use of the "Resolve" verb.
#>

function Resolve-ServiceDeskRequest {
    param (
        # ID of the ServiceDesk Plus request
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int[]]
        $Id,

        # Base URI of the ServiceDesk Plus server, i.e. https://sdp.example.com
        [Parameter(Mandatory)]
        $Uri,

        # ServiceDesk Plus API key
        [Parameter(Mandatory)]
        $ApiKey,

        # Message to add as the ServiceDesk Plus request resolution
        [ValidateNotNullOrEmpty()]
        $Message = "Work complete, resolving ticket."
    )

    process {
        foreach ($RequestId in $Id) {
            Add-ServiceDeskResolution -Message $Message | Update-ServiceDeskRequest -Status "Resolved"
        }
    }
}