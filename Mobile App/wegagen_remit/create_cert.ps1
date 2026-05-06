# Create a simple self-signed certificate for localhost
$cert = New-SelfSignedCertificate -Subject "CN=localhost" -DnsName "localhost" -KeyAlgorithm RSA -KeyLength 2048 -NotBefore (Get-Date) -NotAfter (Get-Date).AddYears(1) -CertStoreLocation "Cert:\CurrentUser\My" -FriendlyName "Flutter Dev Certificate" -HashAlgorithm SHA256 -KeyUsage DigitalSignature, KeyEncipherment -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.1")

# Export certificate to PEM format
$certPath = "cert.pem"
$keyPath = "key.pem"

# Get the certificate
$certBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
$certPem = [System.Convert]::ToBase64String($certBytes, [System.Base64FormattingOptions]::InsertLineBreaks)

# Create cert.pem
$certContent = "-----BEGIN CERTIFICATE-----`n$certPem`n-----END CERTIFICATE-----"
$certContent | Out-File -FilePath $certPath -Encoding ASCII

Write-Host "Certificate created: $certPath"
Write-Host "Certificate thumbprint: $($cert.Thumbprint)"

# Note: Private key extraction is complex in PowerShell
# We'll use a simpler approach with Flutter's built-in certificate support