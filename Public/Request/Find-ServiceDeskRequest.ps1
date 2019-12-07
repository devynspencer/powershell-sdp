<#
    .SYNOPSIS
        Returns all ServiceDesk Plus requests matching specific criteria. 

    .DESCRIPTION
        Returns all ServiceDesk Plus requests matching specific criteria.
        
        Includes all default request filters, and allows sorting by commonly used fields.

    .EXAMPLE
        PS C:\> Find-ServiceDeskRequest -Subject "file share" -Filter "MY_OPEN"
        Find all of a user's ServiceDesk Plus tickets with a subject containing "file share"

    .EXAMPLE
        PS C:\> Find-ServiceDeskRequest -Subject "broken" -SortBy "PRIORITY"
        Find all ServiceDesk Plus tickets with a subject containing "broken", sorted by priority
#>

function Find-ServiceDeskRequest {
    param (
        # Base URI of the ServiceDesk Plus server, i.e. https://sdp.example.com
        [Parameter(Mandatory)]
        $Uri,

        # ServiceDesk Plus API KEY
        [Parameter(Mandatory)]
        $ApiKey,

        # Search for tickets with a specific subject
        $Subject = "",

        # Results per page, if results paginated
        [ValidateRange(1, 100)]
        $RowCount = 100,

        # Maximum retries for gathering paginated results
        $MaxRetries = 10,

        # Which ServiceDesk Plus request field to sort by
        [ValidateSet(
            "CREATED",
            "CREATOR",
            "DUE_BY",
            "ID",
            "LAST_UPDATED",
            "PRIORITY",
            "REQUESTOR",
            "STATUS",
            "SUBJECT",
            "TECHNICIAN"
        )]
        $SortBy = "ID",

        [switch] $Ascending,

        # Which ServiceDesk Plus request filter to apply
        [ValidateSet(
            "ALL_COMPLETE",
            "ALL_DUE_TODAY",
            "ALL_GROUPS",
            "ALL_ON_HOLD",
            "ALL_OPEN",
            "ALL_OVERDUE",
            "ALL_PENDING_APPROVAL",
            "ALL_PENDING",
            "ALL_UNASSIGNED",
            "ALL",
            "MY_AWAITING",
            "MY_COMPLETE",
            "MY_DUE_TODAY",
            "MY_ON_HOLD",
            "MY_OPEN_OR_UNASSIGNED",
            "MY_OPEN",
            "MY_OVERDUE",
            "MY_PENDING_APPROVAL",
            "MY_PENDING",
            "MY_REQUESTS",
            "MY_UPDATED",
            "SHARED_PENDING",
            "SHARED"
        )]
        $Filter = "ALL"
    )

    # Determine sort order
    $SortOrder = "desc"
    if ($Ascending) {
        $SortOrder = "asc"
    }

    # Translate sort by
    $SortField = switch ($SortBy) {
        "CREATED" { "created_time" }
        "CREATOR" { "created_by" }
        "DUE_BY" { "due_by_time" }
        "ID" { "id" }
        "LAST_UPDATED" { "last_updated_time" }
        "PRIORITY" { "priority" }
        "REQUESTOR" { "requester" }
        "STATUS" { "status" }
        "SUBJECT" { "subject" }
        "TECHNICIAN" { "technician" }
        default { "id" }
    }

    # Determine request filter
    $FilterBy = switch ($Filter) {
        "ALL_COMPLETE" { "All_Completed" }
        "ALL_GROUPS" { "ALL_QUEUE" }
        "ALL_PENDING" { "All_Pending" }
        "ALL" { "All_Requests" }
        "DUE_TODAY" { "Overdue_System_Today" }
        "MY_AWAITING" { "Waiting_Update" }
        "MY_COMPLETE" { "All_Completed_User" }
        "MY_DUE_TODAY" { "Due_Today_User" }
        "MY_ON_HOLD" { "Onhold_User" }
        "MY_OPEN_OR_UNASSIGNED" { "MyOpen_Or_Unassigned" }
        "MY_OPEN" { "Open_User" }
        "MY_OVERDUE" { "Overdue_User" }
        "MY_PENDING_APPROVAL" { "My_Pending_Approval" }
        "MY_PENDING" { "All_Pending_User" }
        "MY_REQUESTS" { "All_User" }
        "MY_UPDATED" { "Updated_By_Me" }
        "ON_HOLD" { "Onhold_System" }
        "OPEN" { "Open_System" }
        "OVERDUE" { "Overdue_System" }
        "PENDING_APPROVAL" { "Pending_Approval" }
        "SHARED_PENDING" { "Share_Pending" }
        "SHARED" { "Share_All_Requests" }
        "UNASSIGNED" { "Unassigned_System" }
        default { "All_Requests" }
    }

    # Maximum retries added to avoid infinite request loop
    $CurrentRetry = 1

    # Make at least one initial request, after which start_index is determined by response
    $CurrentIndex = 1
    $Paginate = $true

    # Continue requesting until no more responses available
    while ($Paginate -and ($CurrentRetry -le $MaxRetries)) {
        # Configure request parameters
        $InputData = @{
            list_info = @{
                row_count = $RowCount
                start_index = $CurrentIndex
                sort_field = $SortField
                sort_order = $SortOrder
                get_total_count = $true
                search_fields = @{
                    subject = $Subject
                }
                filter_by = @{
                    name = $FilterBy
                }
            }
        }

        # Set request parameters
        $Parameters = @{
            Body = @{
                TECHNICIAN_KEY = $ApiKey
                input_data = ($InputData | ConvertTo-Json -Depth 5 -Compress)
            }
            Method = "Get"
            Uri = "$Uri/api/v3/requests"
        }

        # Request the next page of results
        $Response = Invoke-RestMethod @Parameters

        # Return results using the pipeline
        foreach ($Request in $Response.requests) {
            [PSCustomObject] @{
                Id = $Request.id
                Subject = $Request.subject
                Requestor = $Request.requester.name
                Technician = $Request.technician.name
                CreatedTime = if ($Request.created_time) { $Request.created_time.display_value | Get-Date } else { $null }
                Group = $Request.group.name
                Description = $Request.short_description
                Priority = $Request.priority.name
                Status = $Request.status.name
                Site = $Request.site.name
                Template = $Request.template.name
            }
        }

        # Increment the index to the start of the next page
        $CurrentIndex = $Response.list_info.start_index + $RowCount

        # Increment the total number of requests made to the API
        $CurrentRetry += 1

        # Determine whether to continue paginating responses
        $Paginate = [System.Convert]::ToBoolean($Response.list_info.has_more_rows)
    }
}