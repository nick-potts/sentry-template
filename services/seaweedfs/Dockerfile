FROM chrislusf/seaweedfs:3.96_large_disk

ENV AWS_ACCESS_KEY_ID=sentry
ENV AWS_SECRET_ACCESS_KEY=sentry

EXPOSE 8080 8333 8888 9333

HEALTHCHECK --interval=30s --timeout=20s --retries=5 --start-period=60s \
  CMD wget -q -O- http://localhost:8080/healthz http://localhost:9333/cluster/healthz http://localhost:8333/healthz || exit 1

ENTRYPOINT ["weed"]
CMD ["server", "-dir=/data", "-filer=true", "-filer.port=8888", "-filer.port.grpc=18888", \
     "-filer.defaultReplicaPlacement=000", "-master=true", "-master.port=9333", \
     "-master.port.grpc=19333", "-metricsPort=9091", "-s3=true", "-s3.port=8333", \
     "-s3.port.grpc=18333", "-volume=true", "-volume.dir.idx=/data/idx", \
     "-volume.index=leveldbLarge", "-volume.max=0", "-volume.preStopSeconds=8", \
     "-volume.readMode=redirect", "-volume.port=8080", "-volume.port.grpc=18080", \
     "-ip=[::1]", "-ip.bind=[::]", "-webdav=false"]
