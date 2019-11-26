# Load public and private functions
foreach ($File in (ls "$PSScriptRoot\Public", "$PSScriptRoot\Private" -Recurse -Filter "*.ps1")) {
    . $File.FullName
}

# Export all public functions
foreach ($File in (ls "$PSScriptRoot\Public" -Recurse -Filter "*.ps1")) {
    Export-ModuleMember $File.BaseName
}