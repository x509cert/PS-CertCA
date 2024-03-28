Written by Michael Howard, Azure Data Platform, Microsoft Corp.

Code to setup a Certificate Authority using PowerShell. This is for *experimental purposes only* so you don't need to use self-signed certificates.

So long as the root CA cert is installed in the Root CA store of a client computer there is no need to use TrustServerCertificate=true in SQL connection strings on that client. This mimics a paid-for PKI hierarchy without setting up a paid-for PKI hierarchy!
All you need to do is change these two lines:

```
$RootCAName = '<String naming your CA>'
$ServerName = '<Add your server name>'
```

and then run the code. 

For example, for the DNS name of your server:

```
$RootCAName = 'Bilbo's Awesome CA'
$ServerName = 'frodo.hobbiton.com'
```

You could also use the NetBIOS name or IP address of your server. Remember, this is for experimental purposes only!

At it's core the code uses New-SelfSignedCertificate, which does much more than create a self-signed certificate, You can read more here https://learn.microsoft.com/en-us/powershell/module/pki/new-selfsignedcertificate?view=windowsserver2022-ps. 

You can also add Subject Altername Name(s) by adding more than one name to the $ServerName variable:

```
$ServerName = 'frodo.hobbiton.com', 'sauron.mordor.com'
````
