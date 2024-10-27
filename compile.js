const path = require('path');
const fs = require('fs');
const solc = require('solc');

// Path to your SaleTicket contract file
const ticketPath = path.resolve(__dirname, 'contracts',  'SaleTicket.sol');
const source = fs.readFileSync(ticketPath, 'utf8');

// Compile the contract
const input = {
    language: 'Solidity',
    sources: {
        'SaleTicket.sol': {
            content: source,
        },
    },
    settings: {
        outputSelection: {
            '*': {
                '*': ['abi', 'evm.bytecode'],
            },
        },
    },
};

const output = JSON.parse(solc.compile(JSON.stringify(input)));

// Write ABI and bytecode to separate files
const contract = output.contracts['SaleTicket.sol'].SaleTicket;
fs.writeFileSync('SaleTicketABI.txt', JSON.stringify(contract.abi));
fs.writeFileSync('SaleTicketBytecode.txt', contract.evm.bytecode.object);

console.log("ABI and Bytecode generated successfully.");
