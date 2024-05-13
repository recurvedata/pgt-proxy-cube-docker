# Development

## Test with Aurora Postgres

Assuming you have an Aurora Postgres instance, as well as docker and pgsql client installed locally, 
run the Docker image and use self issued certs.

```bash
docker build --tag pgt-test .
docker run -itd --name my-pgt-test pgt-test \
    "--server-private-key-path" "/etc/pgt_proxy/server_tls/self_issued_for_testing/self_issued_key.pem" \
    "--server-certificate-path" "/etc/pgt_proxy/server_tls/self_issued_for_testing/self_issued_cert.pem" \
    "--server-port" "5432" \
    "--client-connection-host-or-ip" "c-abcde.cluster-crawki498h3k.eu-west-1.rds.amazonaws.com" \
    "--client-connection-port" "5432" \
    "--client-tls-validation-host" "c-abcde.cluster-crawki498h3k.eu-west-1.rds.amazonaws.com" \
    "--client-ca-roots-path" "/etc/pgt_proxy/client_tls/aws_rds/"
docker exec -it my-pgt-test "cat" "/etc/pgt_proxy/server_tls/self_issued_for_testing/self_issued_cert.pem" > self_issued_cert.pem 
```

Find out the local IP address of the container. E.g., `172.17.0.2`
```bash
docker inspect my-pgt-test | grep '"IPAddress"' | tail -n 1
```

Run a connection test to postgres
```bash
psql 'sslmode=verify-full host=example.pgt_proxy hostaddr=172.17.0.2 port=5432 user=admin_user password=your_password dbname=postgres sslrootcert=self_issued_cert.pem channel_binding=disable'
```

Clean up after yourself!
```bash
docker stop my-pgt-test
docker rm my-pgt-test
rm self_issued_cert.pem
```