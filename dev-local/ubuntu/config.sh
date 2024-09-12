# usage: source config.sh

# Kerberos environment variables of MIT implementation
export KRB5_CONFIG="/etc/krb5-dev.conf"
#Krb5LoginModule by default will try to read TGT from ticket cache in /tmp/krb5cc_uid where the uid is numeric user identifier.
#https://docs.oracle.com/javase/8/docs/jre/api/security/jaas/spec/com/sun/security/auth/module/Krb5LoginModule.html
#@see com.singlestore.jdbc.plugin.authentication.addon.gssapi.StandardGssapiAuthentication#authenticate
export KRB5CCNAME="/tmp/krb5cc_"$UID
export KRB5_TRACE="/dev/stderr"

# other environment variables
export KEYTAB="/etc/singlestore.keytab"
