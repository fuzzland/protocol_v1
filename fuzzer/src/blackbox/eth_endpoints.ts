import * as os from "os";
// Node 18 uses undici fetch, so you don't have to import fetch. But you can.
// import { Agent } from "undici";

// const SOCKET = os.platform() === "darwin" ? "~/Library/Ethereum/geth.ipc" : "~/.ethereum/geth.ipc";
// const CONN = "https://rpc-mumbai.matic.today";
const CONN = "https://bsc-dataseed1.binance.org/";
import fetch from 'node-fetch';
import {add} from "mcl-wasm";

const request_eth = async (method, params) : Promise<string> => {
    let result = await fetch(CONN, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        // body: '{"method":"eth_getStorageAt","params":["0x295a70b2de5e3953354a6a8344e616ed314d7251", "0x6661e9d6d8b923d5bbaab1b96e1dd51ff6ea2a93520fdc9eb75d059238b8c5e9", "latest"],"id":1,"jsonrpc":"2.0"}',
        body: JSON.stringify({
            'method': method,
            'params': params,
            'id': 1,
            'jsonrpc': '2.0'
        })
    });
    const res = await result.json();
    return res["result"];
}

// @ts-ignore
let storage_cache = {};
// @ts-ignore
let code_cache = {};



const getStorageAt = async (address: string, location: string) : Promise<string> => {
    if (address.slice(0, 2) != "0x") {
        address = "0x" + address;
    }
    if (location.slice(0, 2) != "0x") {
        location = "0x" + address;
    }
    const key = `${address}-${location}`;
    if (storage_cache[key] !== undefined) {
        return storage_cache[key];
    }
    const result = await request_eth('eth_getStorageAt', [address, location, 'latest']);
    storage_cache[key] = result;
    return result.slice(2);
}

const getCode = async (address: string) : Promise<string> => {
    if (address.slice(0, 2) != "0x") {
        address = "0x" + address;
    }
    if (code_cache[address] !== undefined) {
        return code_cache[address];
    }
    const result = await request_eth('eth_getCode', [address, "latest"]);
    code_cache[address] = result;
    return result.slice(2);
}


export {
    getStorageAt,
    getCode,
}
