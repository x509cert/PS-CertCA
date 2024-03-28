##################################################################
# make-root-ca.ps1
# Written by Michael Howard, Azure Data Platform, Microsoft Corp.
# 
# Code to setup a Certificate Authority using PowerShell
# This is for *experimental purposes only* so you don't need
# to use self-signed certificates.
# So long as the root CA cert is installed in the Root CA 
# store there is no need to use TrustServerCert=true in 
# SQL connection strings. This mimics a PKI hierarchy without
# setting up a PKI hierarchy!
#
##################################################################

Set-StrictMode -Version Latest

'START'
'Creating root CA cert and private key'

$RootCACertFileName = '.\RootCACert.cer'
$RootCAName = 'Mikehow Root CA Cert'
$ServerName = 'mikehow-atx2'

$ServerCertStore = 'Cert:\CurrentUser\My'
$RootCACertStore = 'Cert:\CurrentUser\Root'

$CAparams = @{
  DnsName = $RootCAName
  KeyLength = 4096
  KeyAlgorithm = 'RSA'
  HashAlgorithm = 'SHA512'
  KeyExportPolicy = 'Exportable'
  NotAfter = (Get-Date).AddYears(2)
  CertStoreLocation = $ServerCertStore # Cannot create a cert in the Root store
  KeyUsage = 'CertSign','CRLSign' 
}

$rootCA = New-SelfSignedCertificate @CAparams

'Copying root CA Cert to the Trusted Root CA Store'
Export-Certificate -Cert $rootCA -FilePath $RootCACertFileName -Type CERT | Out-Null
Import-Certificate -FilePath $RootCACertFileName -CertStoreLocation $RootCACertStore | Out-Null

# Delete the root CA cert file.
# It is temporarily exported after creation and 
# then moved to the root store
if (Test-Path -Path $RootCACertFileName) {
    Remove-Item -Path $RootCACertFileName -Force
}

'Creating a server cert, signed by the root CA key'
$Serverparams = @{
  DnsName = $ServerName
  Signer = $rootCA 
  KeyLength = 2048
  KeyAlgorithm = 'RSA'
  HashAlgorithm = 'SHA256'
  KeyExportPolicy = 'Exportable'
  NotAfter = (Get-Date).AddYears(1)
  CertStoreLocation = $ServerCertStore
  KeyUsage = 'DigitalSignature', 'KeyEncipherment', 'KeyAgreement'
}
 
$ServerCert = New-SelfSignedCertificate @Serverparams | Out-Null

"The Root CA Cert is in $RootCACertStore named $RootCAName"
"The server cert is in $ServerCertStore named $ServerName"

'DONE'
