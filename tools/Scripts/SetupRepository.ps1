. "$PSScriptRoot\SymbolicLinkHelpers.ps1"

Set-Location (Split-Path $MyInvocation.MyCommand.Path)
Write-Host "`n"

# Enable symlink support for the repository. This is necessary
# for inter-directory linking to build the HolographicCamera.Unity project
# as well as for the samples to include submodule repository content
# via directory symlinks.
Write-Output "Enabling symbolic links for the repository."
git config core.symlinks true

# Ensure consistent line endings.
Write-Output "Configuring the repository to use crlf line endings."
git config core.autocrlf true

# Ensure that submodules are initialized and cloned.
Write-Output "Updating all submodules."
git submodule update --init

# If any links were created to the submodules but were broken,
# restore those symlinks now that the submodules are cloned.
Write-Output "Fixing all symbolic links."
dir "$PSScriptRoot\..\..\" -Recurse -File | ?{$_.LinkType -eq "SymbolicLink" } | Restore-SymbolicLink

# If any links were created before the repository was configured to use
# symlinks, those links need to be restored.
git status --porcelain | Restore-SymbolicLinkFromTypeChange

Write-Host "`n"
Write-Host -NoNewLine 'Setup Completed. Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
Write-Host "`n"