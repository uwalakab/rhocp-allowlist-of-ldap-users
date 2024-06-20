## Written by B. Uwalaka (15/04/2024)
## Script is for use with LDAPs and RHOCP (need to be logged into cluster as admin)
## What Red Hat don't explain in detail in their docs is that in order to manually provision an identity
## you need to base64 encode the DN of the user and remove the final character of that string and use that as the identity.

read -p "User email address : " USEREMAIL

## Values used in ldap url search
LDAPHOST="ldaps://myldapserver.com"
LDAPPORT="636"
LDAPBASEDN="o=test.com"
LDAPATTRIB="emailAddress"
LDAPDEPTH="sub"
LDAPFILTER="(&(objectclass=person)(emailAddress=$USEREMAIL))"

## Name of the RHOCP cluster admin group
CLUSTERADMINGROUP="allowlist-admins-group"

## Name of the Identity Provider (IDP) that will be used in the cluster Oauth
IDPNAME="allowlist-users"

## Find actual email address in LDAP (Note: RHOCP user name is case-sensitive)
USEREMAIL=$(curl -ks "${LDAPHOST}:${LDAPPORT}/${LDAPBASEDN}?${LDAPATTRIB}?${LDAPDEPTH}?${LDAPFILTER}"|awk '{IGNORECASE=1}/emailAddress: '"$USEREMAIL"'/{print $2}')

## Abort if user is not found in LDAP
if [[ -z ${USEREMAIL} ]]
    then
    echo -e "\n\n  User not found in LDAP. Exiting script.\n\n"
    exit 1
fi

echo -e "\n\n  Found user : $USEREMAIL\n\n"

## Get the Distinguished Name (DN) of the user found
DNSTRINGCLEAN=$(curl -ks "${LDAPHOST}:${LDAPPORT}/${LDAPBASEDN}?${LDAPATTRIB}?${LDAPDEPTH}?${LDAPFILTER}"|awk '/^DN/{split($0, dn, "DN: "); print dn[2]}')

## Create the base64 encoded string for the user identity
DNSTRING=$(echo $DNSTRINGCLEAN|base64 -iw0)
DNSTRING=${DNSTRING%?}

## Show user details on console
echo -e "\n\nIDP\t: ${IDPNAME}\nUSER\t: ${USEREMAIL}\nDN-CODE\t: ${DNSTRING}\nDN\t: ${DNSTRINGCLEAN}\n"

## Confirm the user details are correct
echo -e "\nProceed with these details?\n\n"
read -p "(yes/no): " ANSWER

## If yes create the user and their identity and mapping between the two. No problem if user already exists RHOCP users
if [[ "$ANSWER" = "yes" ]]
then
    oc create user ${USEREMAIL}
    oc create identity ${IDPNAME}:${DNSTRING}
    oc create useridentitymapping ${IDPNAME}:${DNSTRING} ${USEREMAIL}
    oc adm groups add-users ${CLUSTERADMINGROUP} ${USEREMAIL}
    echo -e "\n\nUser ${USEREMAIL} provisioned to allowlist.\n\n"
## Otherwise abort
else
    echo -e "\n\nABORTED PROVISIONING USER FOR CLUSTER.\n"
fi
