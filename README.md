# PowerShell Module: ServiceDeskPlus
PowerShell module focused on manipulating the ManageEngine ServiceDesk Plus API.

## Setup
Clone the module into your PowerShell modules directory:

```powershell
git clone "https://github.com/devynspencer/powershell-sdp" "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\ServiceDeskPlus"
```

Alternatively, create a symlink:

```powershell
$ProjectPath = "$env:USERPROFILE\projects\powershell-sdp"
$InstallPath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\ServiceDeskPlus"

cmd /c mklink /d $InstallPath $ProjectPath
```

Add your [ServiceDesk Plus](https://www.manageengine.com/products/service-desk/) API key and server URI to your PowerShell profile as [default parameter values](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_parameters_default_values?view=powershell-6):

```powershell
# Update default parameters hash with SDP API key and server URI
$PSDefaultParameterValues["*-ServiceDesk*:Uri"] = "https://sdp.example.com"
$PSDefaultParameterValues["*-ServiceDesk*:ApiKey"] = "B42550F3-006D-48EB-8011-F6C7D6323EE7"
```
