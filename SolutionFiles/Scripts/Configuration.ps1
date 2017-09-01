#Clear-AWSCredential
#Remove-AWSCredentialProfile -ProfileName ProfileName

# 16.
    Set-ExecutionPolicy RemoteSigned


# 17.
Import-Module AWSPowerShell


# 18.
Get-AWSPowerShellVersion -ListServiceVersionInfo
Get-EC2Instance


$AccessKey = ""
$SecretKey = ""

# 21.
    #Profile
        Set-AWSCredential -AccessKey  $AccessKey -SecretKey $SecretKey -StoreAs default
        Get-AWSCredential -ListProfileDetail
        Initialize-AWSDefaultConfiguration -ProfileName myProfileName -Region us-west-2
    #Sem Profile
        Set-AWSCredential -AccessKey  $AccessKey -SecretKey $SecretKey
        Get-EC2Instance -AccessKey  $AccessKey -SecretKey $SecretKey