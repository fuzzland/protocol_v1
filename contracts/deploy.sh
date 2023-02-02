PRIVATE_KEY=5a0358916d3cf1e0756686c334b1e68b2e92255900a333861f8a664cc6102156
RPC=https://rpc-mumbai.matic.today
TOKEN_ADDRESS=""

if [ $1 = "token" ]
then
forge create --rpc-url $RPC \
    --constructor-args 10000000 18 \
    --private-key $PRIVATE_KEY --optimize --optimizer-runs 99999 \
    src/Token.sol:FuzzToken
elif [ $1 = "protocol" ]
then
forge create --rpc-url $RPC \
    --constructor-args $2 \
    --private-key $PRIVATE_KEY --optimize --optimizer-runs 99999 \
    src/Protocol.sol:Protocol
elif [ $1 = "uvuln" ]
then
forge create --rpc-url $RPC \
    --constructor-args $2 \
    --private-key $PRIVATE_KEY --optimize --optimizer-runs 99999 \
    src/uVulns.sol:VulnsUnverified
elif [ $1 = "vvuln" ]
then
forge create --rpc-url $RPC \
    --constructor-args $2 \
    --private-key $PRIVATE_KEY --optimize --optimizer-runs 99999 \
    src/vVulns.sol:VulnsVerified
elif [ $1 = "all" ]
then
  TOKEN_ADDRESS=`forge create --rpc-url $RPC \
      --constructor-args 10000000 18 \
      --private-key $PRIVATE_KEY --optimize --optimizer-runs 99999 \
      src/Token.sol:FuzzToken | grep Deployed | awk '{print $3}'`
  echo "Token deployed at $TOKEN_ADDRESS"
  PROTOCOL_ADDRESS=`forge create --rpc-url $RPC \
      --constructor-args $TOKEN_ADDRESS \
      --private-key $PRIVATE_KEY --optimize --optimizer-runs 99999 \
      src/Protocol.sol:Protocol | grep Deployed | awk '{print $3}'`
  echo "Protocol deployed at $PROTOCOL_ADDRESS"
  UVULN_ADDRESS=`forge create --rpc-url $RPC \
      --constructor-args $PROTOCOL_ADDRESS \
      --private-key $PRIVATE_KEY --optimize --optimizer-runs 99999 \
      src/uVulns.sol:VulnsUnverified | grep Deployed | awk '{print $3}'`
  echo "uVuln deployed at $UVULN_ADDRESS"
  VVULN_ADDRESS=`forge create --rpc-url $RPC \
      --constructor-args $PROTOCOL_ADDRESS \
      --private-key $PRIVATE_KEY --optimize --optimizer-runs 99999 \
      src/vVulns.sol:VulnsVerified | grep Deployed | awk '{print $3}'`
  echo "vVuln deployed at $VVULN_ADDRESS"
fi
