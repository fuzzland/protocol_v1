const protocol_address = "0xd2BCBafD329c2440B69E42055448B9B15978c600";
const token_address = "0x2F8a09e4c252B29b651FFC51AFE0DC7f74805415";
const uvuln_address = "0xC0131846163cdCB2fcCF3fD309eF4736991a476B";
const vvuln_address = "0x9784b57De5dEdEeb2D35A421B464A7827f0E612c";
const RPC_ADDRESS = "https://rpc-mumbai.matic.today"
const MYSQL_HOST = "localhost"
const MYSQL_USER = "root"
const MYSQL_PASSWORD = "123"
const MYSQL_DB = "fuzzland"

const URL_SUFFIX = "dev.fuzz.land"

module.exports = {
    protocol_address,
    token_address,
    uvuln_address,
    vvuln_address,
    RPC_ADDRESS,
    MYSQL_HOST,
    MYSQL_USER,
    MYSQL_PASSWORD,
    MYSQL_DB,
    STATS_API_URL: `https://stats-api.${URL_SUFFIX}`,
    IPFS_GW_API: `https://ipfs.${URL_SUFFIX}`,
    PRICE_ESTIMATOR: `https://pricing-api.${URL_SUFFIX}`,
    TELEMETRY_API: `34.69.22.45:50051`,
    MAX_PER_FETCH: 3000,
    START_FETCH_BLOCK: 28560000
}