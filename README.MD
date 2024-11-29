# PGT-Proxy (Docker)

![Latest Version - Build Status](https://github.com/ambarltd/pgt-proxy-docker/actions/workflows/test.yaml/badge.svg)

PostgreSQL TLS Proxy (PGT-Proxy) is an intermediary server to easily and securely connect TLS enabled PG clients 
to TLS enabled PG servers. This repository contains the Docker deployment for PGT-Proxy. The source code for PGT-Proxy 
lives separately in another repository.

- Pushed to DockerHub [repository](https://hub.docker.com/r/ambarltd/pgt-proxy)
- Rust source code available [on GitHub](https://github.com/ambarltd/pgt-proxy)
- Read why we open sourced PGT Proxy [on our website](https://ambar.cloud/blog/connect-to-postgresql-securely-with-pgt-proxy)

### Architecture Diagram

![Architecture Diagram](PGT-Proxy-Diagram.png)

## Usage

**Step 1.** Run the Docker image ambarltd/pgt-proxy, overriding the Docker CMD with the arguments
that PGT-Proxy requires. You will need to mount volumes for:

1. PGT-Proxy's private key
2. PGT-Proxy's certificate,
3. The certificate authority/authorities that PGT-Proxy should trust (optional, you can also choose preset CAs).

See below, 4 examples using docker compose.

```yaml
services:
    pgt-proxy-conecting-to-aws-rds:
        image: ambarltd/pgt-proxy:latest
        ports:
            - "5432:5432"
        volumes:
            - ./path/to/pgt_proxy/your_tls_private_key.pem:/etc/pgt_proxy/server_tls/key.pem
            - ./path/to/pgt_proxy/your_tls_certificate.pem:/etc/pgt_proxy/server_tls/certificate.pem
        command: [
            "--server-private-key-path", "/etc/pgt_proxy/server_tls/key.key", \
            "--server-certificate-path", "/etc/pgt_proxy/server_tls/certificate.pem", \
            "--server-port", "5432", \
            "--client-connection-host-or-ip", "destination.host.example.amazonaws.com", \
            "--client-connection-port", "5432", \
            "--client-tls-validation-host", "destination.host.example.amazonaws.com", \
            "--client-ca-roots-path", "/etc/pgt_proxy/client_tls/aws_rds/"
        ]
    pgt-proxy-connecting-to-azure-digicert:
        image: ambarltd/pgt-proxy:latest
        ports:
            - "5433:5432"
        volumes:
          - ./path/to/pgt_proxy/your_tls_private_key.pem:/etc/pgt_proxy/server_tls/key.pem
          - ./path/to/pgt_proxy/your_tls_certificate.pem:/etc/pgt_proxy/server_tls/certificate.pem
        command: [
              "--server-private-key-path", "/etc/pgt_proxy/server_tls/key.key", \
              "--server-certificate-path", "/etc/pgt_proxy/server_tls/certificate.pem", \
              "--server-port", "5432", \
              "--client-connection-host-or-ip", "destination.host.example.azure.com", \
              "--client-connection-port", "5432", \
              "--client-tls-validation-host", "destination.host.example.azure.com", \
              "--client-ca-roots-path", "/etc/pgt_proxy/client_tls/azure_digicert/"
        ]
    pgt-proxy-connecting-to-database-with-certificate-authorities-trusted-by-firefox-web-browser:
        image: ambarltd/pgt-proxy:latest
        ports:
            - "5433:5432"
        volumes:
          - ./path/to/pgt_proxy/your_tls_private_key.pem:/etc/pgt_proxy/server_tls/key.pem
          - ./path/to/pgt_proxy/your_tls_certificate.pem:/etc/pgt_proxy/server_tls/certificate.pem
        command: [
              "--server-private-key-path", "/etc/pgt_proxy/server_tls/key.key", \
              "--server-certificate-path", "/etc/pgt_proxy/server_tls/certificate.pem", \
              "--server-port", "5432", \
              "--client-connection-host-or-ip", "destination.host.example.com", \
              "--client-connection-port", "5432", \
              "--client-tls-validation-host", "destination.host.example.com", \
              "--client-ca-roots-path", "/etc/pgt_proxy/client_tls/firefox/"
        ]
    pgt-proxy-connecting-to-database-with-custom-certificate-authorities:
          image: ambarltd/pgt-proxy:latest
          ports:
              - "5432:5432"
          volumes:
                - ./path/to/pgt_proxy/your_tls_private_key.pem:/etc/pgt_proxy/server_tls/key.pem
                - ./path/to/pgt_proxy/your_tls_certificate.pem:/etc/pgt_proxy/server_tls/certificate.pem
                - ./path/to/postgres_destination_server/your_certificate_authority_certificates_in_pem_format/:/etc/pgt_proxy/client_tls/custom_cas/
          command: [
                "--server-private-key-path", "/etc/pgt_proxy/server_tls/key.key", \
                "--server-certificate-path", "/etc/pgt_proxy/server_tls/certificate.pem", \
                "--server-port", "5432", \
                "--client-connection-host-or-ip", "destination.host.example.com", \
                "--client-connection-port", "5432", \
                "--client-tls-validation-host", "destination.host.example.com", \
                "--client-ca-roots-path", "/etc/pgt_proxy/client_tls/custom_cas/"
          ]
```

**Step 2.** Make sure the machine in which you have deployed ambarltd/pgt-proxy allows incoming traffic on the port you
picked. In the examples above, PGT-Proxy's server serves traffic on port 5432.

**Step 3.** Using DNS, point the hostname associated with the certificate in `/etc/pgt_proxy/server_tls/certificate.pem` 
to the IP address of the machine in step 2.

**Step 4.** Connect to PGT-Proxy from another machine, using your favorite pg client. E.g., 

```bash
psql 'sslmode=verify-full host=pgtproxy.example.com port=5432 user=admin password=pass dbname=postgres channel_binding=disable'
# Notice that channel binding needs to be disabled for PGT-Proxy to work.
```

**Suggestions**
- Deploy PGT-Proxy on AWS EC2, AWS Fargate, GCP CloudRun, Kubernetes, or wherever you feel most comfortable.
- Use infrastructure as code where possible (e.g., Terraform, Pulumi).
- Integrate deployment and TLS certificate issuance/renewal into your CI/CD system.
- For high availability in vendors such as AWS and GCP, deploy PGT-Proxy redundantly in more than one availability zone.
- Restrict network traffic to the machine that runs PGT-Proxy. E.g., only allow traffic from trusted IPs.
