<#
    .SYNOPSIS
        Returns a ServiceDesk Plus request by id. 

    .DESCRIPTION
        Returns a ServiceDesk Plus request by id. 
        
        Includes additional fields than Find-ServiceDeskRequest.

    .EXAMPLE
        PS C:\> Get-ServiceDeskRequest -Id 12345
        Return ServiceDesk Plus request with id 12345

    .EXAMPLE
        PS C:\> "12345", "67890" | Get-ServiceDeskRequest
        Return ServiceDesk Plus requests 12345 and 67890
#>

function Get-ServiceDeskRequest {
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
                Uri = "$Uri/api/v3/requests/$RequestId"
            }

            $Response = Invoke-RestMethod @Parameters

            [PSCustomObject] @{
                Id = $Response.request.id
                Status = $Response.request.status.name
                Subject = $Response.request.subject
                Requestor = $Response.request.requester.name
                Department = $Response.request.department.name
                Category = $Response.request.category.name
                Technician = $Response.request.technician.name
                Group = $Response.request.group.name
                Priority = $Response.request.priority.name
                Site = $Response.request.site.name
                Description = $Response.request.description
                Template = $Response.request.template.name
                SLA = $Response.request.sla.name
                ClosureAcknowledged = [System.Convert]::ToBoolean($Response.request.closure_info.requester_ack_resolution)
                ClosureType = $Response.request.closure_info.requester_ack_comments
                CreatedTime = $Response.request.created_time.display_value | Get-Date
                AssignedTime = $Response.request.assigned_time.display_value | Get-Date
                FirstResponseDueTime= $Response.request.first_response_due_by_time.display_value | Get-Date
                DueTime= $Response.request.due_by_time.display_value | Get-Date
                ResolvedTime= $Response.request.resolved_time.display_value | Get-Date
                CompletedTime = $Response.request.completed_time.display_value | Get-Date
                LastUpdatedTime = $Response.request.last_updated_time.display_value | Get-Date
                ElapsedTime = $Response.request.time_elapsed.display_value
            }
        }
    }
}