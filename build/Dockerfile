FROM rust:1.81.0-bookworm AS rust-base

WORKDIR /tmp
RUN apt-get update
RUN apt-get install git
RUN git clone https://github.com/ambarltd/pgt-proxy.git
RUN mv pgt-proxy /pgt_proxy

WORKDIR /pgt_proxy
RUN git fetch
RUN git checkout tags/v1.3
RUN cargo build --release

# Here we are keeping images small (and secure), by only copying the executable to a new barebones image.
# It's important to use debian-buster because that's where we compiled originally.
# E.g., https://andygrove.io/2020/05/why-musl-extremely-slow/
FROM debian:bookworm-20240926-slim

RUN mkdir -p /etc/pgt_proxy
RUN mkdir -p /etc/pgt_proxy/client_tls
RUN mkdir -p /etc/pgt_proxy/server_tls

# Option to Trust Firefox Certificates
# It can only be activated deliberately by passing "--client-ca-roots-path" at runtime
RUN mkdir -p /etc/pgt_proxy/client_tls/firefox
RUN apt-get update
RUN apt-get -y install openssl
RUN apt-get -y install ca-certificates
RUN update-ca-certificates
RUN cp /etc/ssl/certs/ca-certificates.crt /etc/pgt_proxy/client_tls/firefox/firefox.pem

# Option to Trust RDS Certificates
# It can only be activated deliberately by passing "--client-ca-roots-path" at runtime
# From https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html#UsingWithRDS.SSL.CertificatesAllRegions
RUN mkdir -p /etc/pgt_proxy/client_tls/aws_rds
COPY client_tls/aws_rds/ /etc/pgt_proxy/client_tls/aws_rds/

# Option to Trust Azure + Digicert Certificates
# It can only be activated deliberately by passing "--client-ca-roots-path" at runtime
# From: https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-networking-ssl-tls#read-replicas-with-certificate-pinning-scenarios
RUN mkdir -p /etc/pgt_proxy/client_tls/azure_digicert
COPY client_tls/azure_digicert/ /etc/pgt_proxy/client_tls/azure_digicert/

# Self Issued Certificate (for testing only)
# It can only be activated deliberately by passing "--server-private-key-path", "--server-certificate-path" at runtime
COPY server_tls/self_issuing_openssl.conf /tmp/self_issuing_openssl.conf
RUN mkdir -p /etc/pgt_proxy/server_tls/self_issued_for_testing/
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048  \
    -keyout /etc/pgt_proxy/server_tls/self_issued_for_testing/self_issued_key.pem  \
    -out /etc/pgt_proxy/server_tls/self_issued_for_testing/self_issued_cert.pem \
    -config /tmp/self_issuing_openssl.conf

COPY --from=rust-base /pgt_proxy/target/release/pgt_proxy  /etc/pgt_proxy/run

ENTRYPOINT ["/etc/pgt_proxy/run"]
