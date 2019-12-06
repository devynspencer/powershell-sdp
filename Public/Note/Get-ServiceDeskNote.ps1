<#
    .SYNOPSIS
        Returns all notes for a ServiceDesk Plus request. 

    .EXAMPLE
        PS C:\> Get-ServiceDeskRequest -Id 12345 | Get-ServiceDeskNote
        Return all notes for ServiceDesk Plus request with id 12345

    .EXAMPLE
        PS C:\> "12345", "67890" | Get-ServiceDeskRequest | Get-ServiceDeskNote
        Return all notes for ServiceDesk Plus requests 12345 and 67890
#>

function Get-ServiceDeskNote {
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
        $ApiKey
    )

    process {
        foreach ($RequestId in $Id) {
            $Parameters = @{
                Body = @{
                    TECHNICIAN_KEY = $ApiKey
                }
                Method = "Get"
                Uri = "$Uri/api/v3/requests/$RequestId/notes"
            }

            $Response = Invoke-RestMethod @Parameters

            foreach ($Note in $Response.notes) {
                [PSCustomObject] @{
                    Id = $Id
                    NoteId = $Note.id
                    Author = $Note.created_by.name
                    Public = [System.Convert]::ToBoolean($Note.show_to_requester)
                    CreatedTime = if ($Note.created_time) { $Note.created_time.display_value | Get-Date } else { $null }
                    RequestId = $Note.request.id
                }
            }
        }
    }
}