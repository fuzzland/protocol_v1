const sendSignTxn = require("./caller");


const abi_path = "../contracts/builds/Protocol_sol_Protocol.abi";
const abi_path_remote = "/contracts/Protocol_sol_Protocol.abi";


class Protocol {
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
        await (await this.get_contract())
    }

    async _sendSignTxn(method) {
        return await sendSignTxn(this.web3, method, this.address, this.key, this.fs ? "node" : "browser");
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

    async SetNFT(vvuln, uvuln) {
        return await this._sendSignTxn((await this.get_contract()).methods.SetNFT(vvuln, uvuln))
    }

    async AddProject(ipfsHash, initialDeposit, isImplicit, initialTestcases, rewardSplittingSpec, projectName="NA") {
        return await this._sendSignTxn((await this.get_contract()).methods.AddProject(ipfsHash, initialDeposit, isImplicit, initialTestcases, rewardSplittingSpec, projectName))
    }

    async WithdrawDeposit(projectId, amount) {
        return await this._sendSignTxn((await this.get_contract()).methods.WithdrawDeposit(projectId, amount))
    }

    async AddDeposit(projectId, amount) {
        return await this._sendSignTxn((await this.get_contract()).methods.AddDeposit(projectId, amount))
    }

    async GetProjectInfo(projectId) {
        return await (await this.get_contract()).methods.GetProjectInfo(projectId).call()
    }

    async GetProjectCount() {
        return await (await this.get_contract()).methods.GetProjectCount().call()
    }

    async IsOracleFreezed(projectId, oracleId) {
        return await (await this.get_contract()).methods.IsOracleFreezed(projectId, oracleId).call()
    }

    async Stake(amt) {
        return await this._sendSignTxn((await this.get_contract()).methods.Stake(amt))
    }

    async Unstake(amt) {
        return await this._sendSignTxn((await this.get_contract()).methods.Unstake(amt))
    }

    async UnstakeAll() {
        return await this._sendSignTxn((await this.get_contract()).methods.UnstakeAll())
    }

    async StakeAmount(addr) {
        return await (await this.get_contract()).methods.StakeAmount(addr).call()
    }

    async IsStaker(addr) {
        return await (await this.get_contract()).methods.IsStaker(addr).call()
    }

    async IsVoteReady(addr) {
        return await (await this.get_contract()).methods.IsVoteReady(addr).call()
    }

    async VoteAye(nftId) {
        return await this._sendSignTxn((await this.get_contract()).methods.VoteAye(nftId))
    }

    async VoteNay(nftId) {
        return await this._sendSignTxn((await this.get_contract()).methods.VoteNay(nftId))
    }

    async VotePostProcessAye(nftId) {
        return await this._sendSignTxn((await this.get_contract()).methods.VotePostProcessAye(nftId))
    }

    async VotePostProcessNay(nftId) {
        return await this._sendSignTxn((await this.get_contract()).methods.VotePostProcessNay(nftId))
    }
}

module.exports = Protocol;