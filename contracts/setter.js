const P = require("./protocols/protocol");
const {vvuln_address, uvuln_address, RPC_ADDRESS, protocol_address} = require("../const");
const Web3 = require("web3");
const fs = require("fs");

const web3 = new Web3(new Web3.providers.HttpProvider(RPC_ADDRESS));

const protocol = new P(web3, protocol_address, web3.eth.accounts.privateKeyToAccount(
    "5a0358916d3cf1e0756686c334b1e68b2e92255900a333861f8a664cc6102156"
), fs)

async function main() {
    await protocol.SetNFT(vvuln_address, uvuln_address);
}

main().then(r => console.log(r)).catch(e => console.log(e))

