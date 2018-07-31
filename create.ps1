Param(
    [Parameter(Mandatory = $true, HelpMessage="Project output root folder. Example: c:\projects\")]
    [ValidateNotNullOrEmpty()]
    [string] $output_folder,

    [Parameter(Mandatory = $true, HelpMessage="Project root namespace. Any non-whitespace")]
    [ValidatePattern("^\S+$")] # any non-whitespace
    [string] $project_namespace,

    [Parameter(Mandatory = $true, HelpMessage="Project name. Any non-whitespace")]
    [ValidatePattern("^\S+$")] # any non-whitespace
    [string] $project_name,

    [Parameter(Mandatory = $true, HelpMessage="Project company name")]
    [ValidateNotNullOrEmpty()]
    [string] $project_company,

    [Parameter(Mandatory = $true, HelpMessage="Project authors")]
    [ValidateNotNullOrEmpty()]
    [string] $project_authors,

    [Parameter(Mandatory = $true, HelpMessage="Project description")]
    [ValidateNotNullOrEmpty()]
    [string] $project_description,

    [Parameter(Mandatory = $true, HelpMessage="Project url")]
    [ValidateNotNullOrEmpty()]
    [string] $project_url,

    [Parameter(Mandatory = $true, HelpMessage="Package tags (semicolon-delimited)")]
    [ValidateNotNullOrEmpty()]
    [string]$package_tags,

    [Parameter(HelpMessage="Git user name (optional)")]
    [string] $git_user_name,

    [Parameter(HelpMessage="Git user email (optional)")]
    [string] $git_user_email,

    [switch] $dryrun
)

Import-Module .\utils.psm1 -Force

$project_namespace  = UpperCaseFirstLetter -text $project_namespace
$project_name       = UpperCaseFirstLetter -text $project_name
$project_company    = UpperCaseFirstLetter -text $project_company
$project_copyright  = "Copyright (c) $project_company $((Get-Date).Year)"
$project_url        = $project_url.ToLower();
$package_tags       = $package_tags.ToLower();
$project_folder     = GetAbsolutePath -root $output_folder -path $project_name

Write-Host "##############################################"
Write-Host "#                                            #"
Write-Host "#     Welcome to net core lib generator!     #"
Write-Host "#                                            #"
Write-Host "##############################################"
Write-Host ""
Write-Host "Project folder      :'$project_folder'"
Write-Host "Project namespace   :'$project_namespace'"
Write-Host "Project name        :'$project_name'"
Write-Host "Project authors     :'$project_authors'"
Write-Host "Project company     :'$project_company'"
Write-Host "Project description :'$project_description'"
Write-Host "Project copyright   :'$project_copyright'"
Write-Host "Project URL         :'$project_url'"
Write-Host "Package tags        :'$package_tags'"

if($git_user_name) {
    Write-Host "Git user name       :'$git_user_name'"
}
if($git_user_email) {
    Write-Host "Git user email      :'$git_user_email'"
}

if($dryrun) {
    exit
}

CreateTemplate -source ".\\template\*" -destination $project_folder

ReplaceTemplate -path $project_folder -template "PROJECT_NAMESPACE" $project_namespace
ReplaceTemplate -path $project_folder -template "PROJECT_NAME" $project_name
ReplaceTemplate -path $project_folder -template "PROJECT_COMPANY" $project_company
ReplaceTemplate -path $project_folder -template "PROJECT_AUTHORS" $project_authors
ReplaceTemplate -path $project_folder -template "PROJECT_DESCRIPTION" $project_description
ReplaceTemplate -path $project_folder -template "PROJECT_COPYRIGHT" $project_copyright
ReplaceTemplate -path $project_folder -template "PROJECT_URL" $project_url
ReplaceTemplate -path $project_folder -template "PACKAGE_TAGS" $package_tags
ReplaceGuid -path $project_folder

InitGitRepo -path $project_folder -username $git_user_name -useremail $git_user_email

Write-Host "Completed!"