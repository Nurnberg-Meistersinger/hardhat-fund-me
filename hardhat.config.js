require("@nomicfoundation/hardhat-toolbox")
require("@nomiclabs/hardhat-etherscan")
require("./tasks/block-number")
require("hardhat-gas-reporter")
require("solidity-coverage")
require("hardhat-deploy")
require("dotenv").config()

// const RINKEBY_RPC_URL = process.env.RINKEBY_RPC_URL
// const MUMBAI_RPC_URL = process.env.MUMBAI_RPC_URL

const PRIVATE_KEY = process.env.PRIVATE_KEY
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY
const CMC_API_KEY = process.env.CMC_API_KEY

module.exports = {
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            chainId: 31337,
        },
        rinkeby: {
            url: "https://eth-rinkeby.alchemyapi.io/v2/Kjrkcs149UvnN9O4HM-P01zhgVYayldG",
            accounts: [process.env.PRIVATE_KEY],
            chainId: 4,
            blockConfirmations: 6,
        },
        mumbai: {
            url: "https://polygon-mumbai.g.alchemy.com/v2/haEi6_BMywzoUOiTw6pKPPxxjJDn08xn",
            accounts: [process.env.PRIVATE_KEY],
            chainId: 80001,
            blockConfirmations: 6,
        },
    },
    solidity: "0.8.7",
    etherscan: {
        apiKey: ETHERSCAN_API_KEY,
    },
    gasReporter: {
        enabled: true,
        outputFile: "gas-report.txt",
        noColors: true,
        currency: "USD",
        // coinmarketcap: "CMC_API_KEY",
    },
    namedAccounts: {
        deployer: {
            31337: 0,
            80001: 0,
            4: 0,
        },
    },
}
