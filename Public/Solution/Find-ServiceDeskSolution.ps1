<#
    .SYNOPSIS
        Returns all ServiceDesk Plus solutions matching specific criteria.

    .EXAMPLE
        PS C:\> Find-ServiceDeskSolution -Title "file share" -Filter "Approved"
        Find all approved ServiceDesk Plus solutions with a title containing "file share"

    .EXAMPLE
        PS C:\> Find-ServiceDeskSolution -Title "broken"
        Find all ServiceDesk Plus solutions with a title containing "broken"
#>

function Find-ServiceDeskSolution {
    param (
        # Base URI of the ServiceDesk Plus server, i.e. https://sdp.example.com
        [Parameter(Mandatory)]
        $Uri,

        # ServiceDesk Plus API KEY
        [Parameter(Mandatory)]
        $ApiKey,

        # Search for solutions with a specific title
        $Title = "",

        # Results per page, if results paginated
        [ValidateRange(1, 100)]
        $RowCount = 100,

        # Maximum retries for gathering paginated results
        $MaxRetries = 10,

        [ValidateSet("Approved", "Rejected", "Approval Pending", "Unapproved")]
        $Filter
    )

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
                get_total_count = $true
            }
        }

        if ($Filter) {
            $InputData.filter = $Filter
        }

        # Set request parameters
        $Parameters = @{
            Body = @{
                TECHNICIAN_KEY = $ApiKey
                input_data = ($InputData | ConvertTo-Json -Depth 5 -Compress)
            }
            Method = "Get"
            Uri = "$Uri/api/v3/solutions"
        }

        # Request the next page of results
        $Response = Invoke-RestMethod @Parameters

        # Return results using the pipeline
        foreach ($Solution in $Response.solutions) {
            [PSCustomObject] @{
                Id = $Solution.id
                Creator = $Solution.created_by.name
                Title = $Solution.title
                Approved = $Solution.approval_status.name
                Public = $Solution.public
                Description = $Solution.description
                Topic = $Solution.topic.name
                Views = [int] $Solution.view_count
                Keywords = if ($Solution.key_words) { $Solution.key_words -split " " } else { @() }
                CreatedTime = if ($Solution.created_time) { $Solution.created_time.display_value | Get-Date } else { $null }
                LastUpdatedTime = if ($Solution.last_updated_time) { $Solution.last_updated_time.display_value | Get-Date } else { $null }
                LastUpdatedBy = $Solution.last_updated_by.name
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