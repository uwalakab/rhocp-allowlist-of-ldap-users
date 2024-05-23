# How to manually provision an allowlist of LDAP users and their cluster identities for accessing an RHOCP console

## Script to provision specific users to log into the console.
This can be used for giving individual LDAP based users access to the Red Hat OpenShift Cluster Platform server console v4.x
<br>There is no requirement for a dedicated group within LDAP itself as the manually provisioned allowlist in RHOCP governs which users have access to the console. However if you wanted, you could set up an LDAP based group and adjust the filter in the ldap url.
<br>The Identity Provider in this example has the "mappingMethod" value set to "lookup", and is configured to use LDAPS.

Script usage:<br>
`./provision-cluster-ldap-user.sh`<br>
Then enter the user email address, (E.g. someone@test.com, Joe Smith) and a check will be made to see if they exist in the LDAP Directory.
