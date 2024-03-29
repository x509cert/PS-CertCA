############################################################################################################
# make-root-ca.ps1
# Written by Michael Howard, Azure Data Platform, Microsoft Corp.
# 
# Code to setup a Certificate Authority using PowerShell
# This is for *experimental purposes only* so you don't need to use self-signed certificates.
# So long as the root CA cert is installed in the Root CA store there is no need to use 
# TrustServerCert=true in SQL connection strings. This mimics a PKI hierarchy without 
# setting up a PKI hierarchy!
#
# Background info:
# https://learn.microsoft.com/en-US/sql/database-engine/configure-windows/configure-sql-server-encryption
#
############################################################################################################

Set-StrictMode -Version Latest

'START'

$ServerName = '<servername>', '<alternateservername>'

########################### ROOT CA CERT ###############################
'Creating root CA cert and private key'

$RootCAName = 'My Awesome Test CA'
$RootCACertFileName = '.\RootCACert.cer'
#$TempRootCACertStore = 'Cert:\CurrentUser\My'

$CAparams = @{
  DnsName = $RootCAName
  KeyLength = 4096
  KeyAlgorithm = 'RSA'
  Provider = 'Microsoft RSA SChannel Cryptographic Provider'
  HashAlgorithm = 'SHA256'
  KeyExportPolicy = 'Exportable'
  NotBefore = (Get-Date).AddDays(-1)
  NotAfter = (Get-Date).AddYears(2)
  #CertStoreLocation = $TempRootCACertStore # Cannot create a cert in the Root store
  KeyUsage = 'CertSign','CRLSign' 
}

$rootCACert = New-SelfSignedCertificate @CAparams

'Copying root CA Cert to the Trusted Root CA Store'
Export-Certificate -Cert $rootCACert -FilePath $RootCACertFileName -Type CERT | Out-Null
#Import-Certificate -FilePath $RootCACertFileName -CertStoreLocation $RootCACertStore | Out-Null
#Gci "$TempRootCACertStore\$rootCACert.Thumbprint"

# Delete the root CA cert file.
# It is temporarily exported after creation and 
# then moved to the root store
#if (Test-Path -Path $RootCACertFileName) {
#    Remove-Item -Path $RootCACertFileName -Force
#}

########################### SERVER CERT ###############################
'Creating a server cert, signed by the root CA key'

$ServerCertStore = 'Cert:\CurrentUser\My'

$Serverparams = @{
  DnsName = $ServerName
  Signer = $rootCACert 
  KeyLength = 2048
  KeyAlgorithm = 'RSA'
  Provider = 'Microsoft RSA SChannel Cryptographic Provider'
  HashAlgorithm = 'SHA256'
  KeyExportPolicy = 'Exportable'
  NotBefore = (Get-Date).AddDays(-1)
  NotAfter = (Get-Date).AddYears(1)
  CertStoreLocation = $ServerCertStore
  KeyUsage = 'DigitalSignature', 'KeyEncipherment', 'KeyAgreement'
  KeySpec = 'KeyExchange'
}

#-CertStoreLocation "Cert:\LocalMachine\My"
 
$ServerCert = New-SelfSignedCertificate @Serverparams 

$PrimaryName = $ServerName[0]

# Expert the PFX file, which is the cert + key and encrypt the PFX blob
$ServerPfxFile = $PrimaryName + '.pfx'
$PfxPwd = ConvertTo-SecureString -String $PrimaryName -Force -AsPlainText
Export-PfxCertificate -Cert $ServerCert -FilePath $ServerPfxFile -Password $PfxPwd

# Export just the cert
$SeverCertFile = $PrimaryName + '.cer'
Export-Certificate -Cert $ServerCert -FilePath $SeverCertFile -Type CERT | Out-Null

$PrimaryName = $ServerName[0]
#"`nThe Root CA Cert is in $RootCACertStore named $RootCAName"
#"The server cert is in file $ServerPfxFile, with a password $PrimaryName"

'DONE'

