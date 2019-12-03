<#
    .SYNOPSIS
        Add a note to a ServiceDesk Plus request. 

    .EXAMPLE
        PS C:\> Get-ServiceDeskRequest -Id 12345 | Add-ServiceDeskNote -Message "This is an important note!"
        Add a note to ServiceDesk Plus request with id 12345

    .EXAMPLE
        PS C:\> "12345", "67890" | Get-ServiceDeskRequest | Add-ServiceDeskNote -Message "This is a public note, visible to requestors." -Public
        Add a note to ServiceDesk Plus requests 12345 and 67890

    .EXAMPLE
        PS C:\> Get-ServiceDeskRequest -Id 12345 | Add-ServiceDeskNote -Message "This is a note. Technician will be notified" -Notify
        Add a note to ServiceDesk Plus request 12345 and notify the assigned technician
#>

function Add-ServiceDeskNote {
    param (
        # ID of the ServiceDesk Plus request
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int[]]
        $Id,

        # Note content
        [ValidateNotNullOrEmpty()]
        $Message,

        # Make the note visible to requestor
        [switch] $Public,

        # Notify the technician
        [switch] $Notify,

        # Base URI of the ServiceDesk Plus server, i.e. https://sdp.example.com
        [Parameter(Mandatory)]
        $Uri,

        # ServiceDesk Plus API key
        [Parameter(Mandatory)]
        $ApiKey
    )

    begin {
        $InputData = @{
            request_note = @{
                description = $Message
                show_to_requester = [bool] $Public
                notify_technician = [bool] $Notify
                mark_first_response = $false
                add_to_linked_requests = $false
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
                Uri = "$Uri/api/v3/requests/$RequestId/notes"
            }

            $Response = Invoke-RestMethod @Parameters

            [PSCustomObject] @{
                Message = $Response.response_status.status
            }
        }
    }
}