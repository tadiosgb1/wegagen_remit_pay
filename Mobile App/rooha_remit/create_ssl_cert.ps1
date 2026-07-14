# Create SSL certificate for localhost Flutter development
Write-Host "Creating SSL certificate for localhost..."

# Create a config file for the certificate
$configContent = @"
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
C = US
ST = State
L = City
O = Organization
CN = localhost

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = 127.0.0.1
IP.1 = 127.0.0.1
"@

$configContent | Out-File -FilePath "localhost.conf" -Encoding ASCII

# Generate private key
openssl genrsa -out localhost-key.pem 2048

# Generate certificate
openssl req -new -x509 -key localhost-key.pem -out localhost-cert.pem -days 365 -config localhost.conf

Write-Host "SSL certificate created successfully!"
Write-Host "Files created:"
Write-Host "  - localhost-cert.pem (certificate)"
Write-Host "  - localhost-key.pem (private key)"

# Clean up config file
Remove-Item "localhost.conf"