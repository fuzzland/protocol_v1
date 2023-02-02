const sendSignTxn = require("./caller");

const abi_path = "../contracts/builds/Token_sol_FuzzToken.abi";
const abi_path_remote = "/contracts/Token_sol_FuzzToken.abi";

class Token {
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

    async transfer(to, amount) {
        return await this._sendSignTxn((await this.get_contract()).methods.transfer(to, amount))
    }

    async balanceOf(account) {
        return await this._sendSignTxn((await this.get_contract()).methods.balanceOf(account))
    }

    async approve(spender, amount) {
        return await this._sendSignTxn((await this.get_contract()).methods.approve(spender, amount))
    }

    async allowance(owner, spender) {
        return await ((await this.get_contract()).methods.allowance(owner, spender).call())
    }

}

module.exports = Token;