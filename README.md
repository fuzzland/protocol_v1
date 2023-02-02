# FuzzLand Protocol


### Staging Environment:

```
stats-backend: https://stats-api-stg.fuzz.land
telemetry-backend: https://telemetry-grpc-gw-stg.fuzz.land
ipfs-gateway: https://ipfs.fuzz.land
frontend: https://stg.fuzz.land

token: 0xeA15a49Bf2f30d9C165049e46d2F329ecEDEF37c
protocol: 0xE4f0AAB052983a8Bd49E4c7aB265a1eDDEdF3d49
uvuln: 0xF559B6030fa2460c525372F67eAB9DfB62b79BFE
vvuln: 0x0F6Ee3Ea28838a88EC4C78C0352A74b72E46A8fa
```

### Contracts

Install foundry: https://github.com/foundry-rs/foundry

Install solc:
```
npm i solc -g
```

Build with foundry or solc
```
# foundry build
cd contracts && forge build && forge test

# solc build (for running with slither)
cd contracts && ./solc_build.sh
```

Deploy to testnet
```
cd contracts && ./deploy.sh
```

### Deploy Backend & Frontend
```
gcloud container clusters get-credentials fuzzland-1 --region us-central1-a
# use AMD machine to build, otherwise it breaks k8s on gcp
./build_images.sh
kubectl get deployment
```

### Ingress
```
kubectl expose deployment [NAME] --port=[SRC_PORT] --target-port=[DST_PORT]
vim deploy/nginx-ingress/ingress.yaml
kubectl apply -f deploy/nginx-ingress/ingress.yaml
```
