#!/usr/bin/env bash
#
# init.sh
#
# Init docker containers for kerberos cluster.

cd "$(dirname "$0")"
cd ..

source .env.values

suffix_realm=$(echo "${REALM_KRB5}" | sed 's/\./-/g' | tr [:upper:] [:lower:])
kdc_server_container="${PREFIX_KRB5}-kdc-server-${suffix_realm}"
service_container="${PREFIX_KRB5}-singlestoredb-${suffix_realm}"

echo "=== Init ${kdc_server_container} docker container ==="
docker exec "${kdc_server_container}" /bin/bash -c "
# Create users alice as admin and singlestore as normal user
# and add principal for the service
cat << EOF  | kadmin.local
add_principal -pw alice \"alice/admin@${REALM_KRB5}\"
add_principal -pw singlestore \"singlestore@${REALM_KRB5}\"
add_principal -randkey \"host/${service_container}.${DOMAIN_CONTAINER}@${REALM_KRB5}\"
ktadd -k /etc/singlestore.keytab -norandkey \"singlestore@${REALM_KRB5}\"
listprincs
quit
EOF
"

echo "=== Copy keytabs to ${service_container} and ./.build-example-com/b ==="
tmp_folder="$(mktemp -d)"
docker cp "${kdc_server_container}":/etc/singlestore.keytab "${tmp_folder}/singlestore.keytab"
docker cp "${tmp_folder}/singlestore.keytab" "${service_container}":/etc/singlestore.keytab
cp "${tmp_folder}/singlestore.keytab" ./dev-local/singlestore.keytab

rm -vrf "${tmp_folder}"

echo "=== Init "${service_container}" docker container ==="
docker exec --user root "${service_container}" /bin/bash -c "
chmod 777 /etc/singlestore.keytab
echo -e 'gssapi-keytab-path = /etc/singlestore.keytab\n' >> /data/master/memsql.cnf
echo -e 'gssapi-principal-name = singlestore@EXAMPLE.COM\n' >> /data/master/memsql.cnf
"

echo "=== Restart "${service_container}" docker container ==="
docker restart "${service_container}"

echo "=== Create singlestore db user==="
docker exec "${service_container}" /bin/bash -c "
until echo \"create database if not exists kerberos_db; CREATE USER IF NOT EXISTS 'singlestore'@'%' IDENTIFIED WITH 'authentication_gss' AS '/^singlestore@EXAMPLE\.COM$'; GRANT ALL ON kerberos_db.* to 'singlestore'@'%';\" | singlestore -v -v -v --user=root -h 127.0.0.1 -P 3306 --password=root; do
  echo Waiting for SingleStore database started ...
  sleep 3
done
"
