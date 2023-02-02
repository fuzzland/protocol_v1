const sendSignTxn = require("./caller")

const abi_path = "../contracts/builds/vVulns_sol_VulnsVerified.abi";
const abi_path_remote = "/contracts/vVulns_sol_VulnsVerified.abi";

class VVulns {
    contract = null;
    address = "0x0000000000000000000000000000000000000000";
    web3 = null;

    constructor(w3, contract_address, key, fs=null) {
        this.web3 = w3;
        this.address = contract_address;
        this.key = key;
        this.fs = fs;
    }

    async init() {
        await this.get_contract()
    }

    async _sendSignTxn(method) {
        await sendSignTxn(this.web3, method, this.address, this.key, this.fs ? "node" : "browser");
    }

    async get_contract() {
        if (!this.contract) {
            const abi = JSON.parse(
                this.fs ?
                    this.fs.readFileSync(abi_path) :
                    await fetch(abi_path_remote).then(res => res.text())
            );
            this.contract = new this.web3.eth.Contract(abi, this.address);
        }
        return this.contract;
    }

    async GetMeta(tokenId) {
        return await (await this.get_contract()).methods.get_meta(tokenId).send()
    }

}

module.exports = VVulns;