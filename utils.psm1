function CreateTemplate {
    param (
        [string] $source,
        [string] $destination
    )

    if(Test-Path -Path $destination) {
        throw "Folder '$destination' already exists"
    }
    
    New-Item -Path $destination -ItemType "directory"
    Copy-Item -Path $source -Destination $destination -Recurse
}

function ReplaceTemplate {
    param (
        [string] $path,
        [string] $template,
        [string] $value
    )

    # rename file
    Get-ChildItem -Path $path -Recurse | Where-Object {$_.Name -match $template} | Rename-Item -NewName { $_.Name.Replace($template, $value) }

    # replace file content
    $files = Get-ChildItem -File -Path $path -Recurse 
    foreach($file in $files) {
        $filePath = $file.FullName
        (Get-Content $filePath) | ForEach-Object { $_ -replace $template, $value  } | Set-Content $filePath
    }
}

function ReplaceGuid {
    param (
        [string] $path
    )

    for ($i=1; $i -le 2; $i++) {
        $value = GenGuid
        $template = "PROJECT_GUID#$i"
        ReplaceTemplate -path $path -template $template $value
    }
}

function GenGuid {
    return [guid]::NewGuid().ToString("B").ToUpperInvariant() # {04BB1EC1-B133-44EA-A762-2BA040D3C268}
}

function UpperCaseFirstLetter {
    param (
        [string] $text
    )    
    return $text.substring(0,1).toupper() + $text.substring(1)
}

function GetAbsolutePath  {
    param (
        [string] $root,
        [string] $path
    )
    
    if(![IO.Path]::IsPathRooted($root)){
        $root = [IO.Path]::GetFullPath($root)
    }
    return [IO.Path]::Combine($root, $path)
}

function InitGitRepo {
    param (
        $path,
        $username,
        $useremail
    )
    
    Push-Location
    Set-Location $path
    Invoke-Expression "git init"

    if($username) {
        Invoke-Expression "git config user.name '$username'"    
    }
    if($useremail) {
        Invoke-Expression "git config user.email '$useremail'"    
    }

    Invoke-Expression "git add --all"
    Invoke-Expression "git commit -m 'Big Bang!'"
    Invoke-Expression "git tag -a v0.1 -m 'v0.1'"
    Pop-Location
}
