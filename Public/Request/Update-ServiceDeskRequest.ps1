<#
    .SYNOPSIS
        Updates a ServiceDesk Plus request by id.

    .DESCRIPTION
        Updates a ServiceDesk Plus request by id.

    .EXAMPLE
        PS C:\> Update-ServiceDeskRequest -Id 12345 -Subject "New Subject"
        Update subject of ServiceDesk Plus request with id 12345

    .EXAMPLE
        PS C:\> Get-ServiceDeskRequest -Id 12345 | Update-ServiceDeskRequest -Technician "New Technician"
        Update technician of ServiceDesk Plus request with id 12345

    .EXAMPLE
        PS C:\> "12345", "67890" | Update-ServiceDeskRequest -Status Open
        Update status of ServiceDesk Plus requests 12345 and 67890
#>

function Update-ServiceDeskRequest {
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
        $ApiKey,

        # Status field
        [ValidateSet("Open", "Closed", "Resolved", "OnHold")]
        $Status,

        # Subject field
        [ValidateLength(5, 75)]
        $Subject,

        # Description field
        $Description,

        # Impact field
        [ValidateSet("Critical", "High", "Medium", "Low")]
        $Impact,

        # Priority field        
        [ValidateSet("High", "Medium", "Normal", "Low")]
        $Priority,

        # Requestor field
        $Requestor,

        # Category field
        $Category,

        # SubCategory field
        $SubCategory,

        # SubCategory Item field
        $SubCategoryItem,

        # Group field
        $Group,

        # Site field
        $Site
    )

    begin {
        $InputData = @{
            request = @{ }
        }

        if ($Status) {
            $InputData.request.status = @{ name = $Status }
        }

        if ($Subject) {
            $InputData.request.subject = $Subject
        }

        if ($Description) {
            $InputData.request.description = $Description
        }

        if ($Impact) {
            $InputData.request.impact = @{ name = $Impact }
        }

        if ($Priority) {
            $InputData.request.priority = @{ name = $Priority }
        }

        if ($Requestor) {
            $InputData.request.requester = @{ name = $Requestor }
        }

        if ($Category) {
            $InputData.request.category = @{ name = $Category }
        }

        if ($SubCategory) {
            $InputData.request.subcategory = @{ name = $SubCategory }
        }

        if ($SubCategoryItem) {
            $InputData.request.item = @{ name = $SubCategoryItem }
        }

        if ($Group) {
            $InputData.request.group = @{ name = $Group }
        }

        if ($Site) {
            $InputData.request.site = @{ name = $Site }
        }
    }

    process {
        foreach ($RequestId in $Id) {
            $Parameters = @{
                Headers = @{
                    TECHNICIAN_KEY = $ApiKey
                }
                Method = "Put"
                Uri = "$Uri/api/v3/requests/$RequestId`?input_data=$($InputData | ConvertTo-Json -Depth 5 -Compress)"
            }

            $Response = Invoke-RestMethod @Parameters

            [PSCustomObject] @{
                Id = $Response.request.id
                Message = $Response.response_status.status
            }
        }
    }
}