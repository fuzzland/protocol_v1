const sendSignTxn = async (web3, method, address, key, env="node") => {
    // try {
        console.log(
            `Calling the function in contract at address ${address}`
        );

        if (env === "browser") {
            // web3.eth.defaultAccount = web3.eth.accounts[0];
            // console.log(web3.eth)
            console.log(web3.currentProvider.selectedAddress)
            return await method.send({       from: web3.currentProvider.selectedAddress, gas: 2000000 });

        }
        const gas = await method.estimateGas({
            from: key.address,
        });
        console.log(`Estimated gas: ${gas}`);

        // Sign Tx with PK
        const createTransaction = await web3.eth.accounts.signTransaction(
            {
                from: key.address,
                to: address,
                data: method.encodeABI(),
                gas,

            },
            key.privateKey
        );

        // Send Tx and Wait for Receipt
    return await web3.eth.sendSignedTransaction(createTransaction.rawTransaction);
    // }
};



module.exports = sendSignTxn;