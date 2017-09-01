# Configura para parar a execução do Script após algum erro.
$ErrorActionPreference = "Stop"

$msbuild = 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\msbuild.exe'
#$msbuild = 'C:\Program Files (x86)\MSBuild\14.0\Bin\msbuild.exe'

#$psscriptroot = 'C:\Users\BOSN\source\repos\Workshop\WorkShop.WebApp\SolutionFiles\Scripts\'
$psscriptroot2 = 'C:\Users\BOSN\source\repos\Workshop\WorkShop.WebApp\SolutionFiles\Scripts\'

#1. Buildar Aplicação
    #BUILD/PACKAGE
        $projPath = $psscriptroot2 + "\..\..\WorkShop.WebApp\WorkShop.WebApp.csproj"        
        $outputPathFile = $psscriptroot2 + "\..\..\WorkShop.WebApp\WorkShop.Website.zip"
    
    ## BUILD / CREATE PACKAGE
    & $msbuild $projPath /T:Package "/P:Configuration=WorkShopBuildProfile;OutDir=$outputPath"

    if ($LastExitCode -ne 0)
    {
        write-host "Error on build application" -foregroundcolor "RED"
        Return
    }
    else
    {
        write-host "SUCCESS!" -foregroundcolor "GREEN"
    }
        
#2. Cria aplicação    
    $application = New-EBApplication -ApplicationName "WorkShop"
        

#3. Cria ENVIRONMENT    
    $EBEnvironment = New-EBEnvironment -EnvironmentName "WorkShopEnvi" -ApplicationName "WorkShop" -SolutionStackName '64bit Windows Server 2012 R2 v1.2.0 running IIS 8.5'
    while ($EBEnvironment.Status -eq "Launching")
    {
        Write-Host "Creating Environment..." -ForegroundColor Yellow
        sleep 30
        $EBEnvironment = Get-EBEnvironment  -EnvironmentName "WorkShopEnvi" -ApplicationName "WorkShop"
    }

    if($EBEnvironment.Status -eq "Ready")
    {    
        Write-Host "Environment Created" -ForegroundColor Green
    }
    else
    {    
        Write-Host "Error on create Environment: Status " + $EBEnvironment.Status -ForegroundColor Red
        return
    }

#3. Upload Versão
    $random = Get-Random
    $versionLabel = "version-" + $random

    #Create S3
    $s3Bucket = New-EBStorageLocation
    Write-S3Object -BucketName $s3Bucket -File $outputPathFile

    $applicationVersion = New-EBApplicationVersion -ApplicationName "WorkShop" -VersionLabel $versionLabel -SourceBundle_S3Bucket $s3Bucket -SourceBundle_S3Key "WorkShop.Website.zip"
    $UpdateVersion = Update-EBEnvironment -ApplicationName "WorkShop" -EnvironmentName "WorkShopEnvi" -VersionLabel $versionLabel

    while ($UpdateVersion.Status -eq "Updating" -or $UpdateVersion.Status -eq "Launching")
    {
        Write-Host "Updating Environment..." -ForegroundColor Yellow
        sleep 30
        $UpdateVersion = Get-EBEnvironment -ApplicationName "WorkShop" -EnvironmentName "WorkShopEnvi"
    }
    if($UpdateVersion.Status -eq "Ready")
    {    
        Write-Host "Environment Updated" -ForegroundColor Green
    }
    else
    {    
        Write-Host "Error on update environment: Status " + $UpdateVersion.Status -ForegroundColor Red
        return
    }
    
    
        
$EBEnvironment = Get-EBEnvironment  -EnvironmentName "WorkShopEnvi" -ApplicationName "WorkShop"
Write-Host "DONE, URL =>" $EBEnvironment.EndpointURL -ForegroundColor Black -BackgroundColor Green