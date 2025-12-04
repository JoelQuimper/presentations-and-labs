param (
    [Parameter(Mandatory = $true)]
    [string]$UserEmailAddress
)

"Getting basic details for user with email address: $UserEmailAddress"
try {
    az login --identity --allow-no-subscription

    $token = az account get-access-token --resource-type ms-graph | ConvertFrom-Json
    $secureAccessToken = $token.accessToken | ConvertTo-SecureString -AsPlainText -Force
    Connect-MgGraph -AccessToken $secureAccessToken

    $user = Get-MgUser -UserId $UserEmailAddress -Property "DisplayName,Id,UserPrincipalName,Mail,JobTitle,Department,AccountEnabled"
    "User Details:"
    " - User ID: $($user.Id)"
    " - Display Name: $($user.DisplayName)"
    " - User Principal Name: $($user.UserPrincipalName)"
    " - Email: $($user.Mail)"
} catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
} finally {
    Disconnect-MgGraph
}