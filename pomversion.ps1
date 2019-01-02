function Get-POMVersion {
  param( [string]$Path)
  [xml] $Xml = Get-ChildItem -Path $Path -Filter pom.xml -Recurse | gc
  $version = $xml.project.version
  $version
}

$Path = "$(Build.SourcesDirectory)"

#Get version in POM file
$POMVersion = Get-POMVersion -Path $Path

Write-Host "POMVersion = $($POMVersion)"

#Write-Host "Pulling all tags"
. git checkout master -q

invoke-expression "git tag" | Where {$_ -match $POMVersion} | %{
  Write-Host "Found tag $($_ ) in repo. Checking in master branch"
  #Check if tag exist in master branch
Write-Host "git branch master --contains tags/$($_ )"
  invoke-expression "git branch master --contains tags/$($_ )"
  $result = invoke-expression "git branch master -a --contains tags/$($_ )"
  if($result.Length -gt 0){
    Write-Host "##vso[task.logissue type=error;] Tag already exists in Master branch"
    Exit 1
  }
}

