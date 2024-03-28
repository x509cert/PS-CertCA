Written by Michael Howard, Azure Data Platform, Microsoft Corp.

Code to setup a Certificate Authority using PowerShell. This is for *experimental purposes only* so you don't need to use self-signed certificates.

So long as the root CA cert is installed in the Root CA store there is no need to use TrustServerCert=true in SQL connection strings. This mimics a PKI hierarchy without setting up a PKI hierarchy!
