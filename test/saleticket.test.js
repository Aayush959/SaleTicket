
const assert = require('assert');
const Web3 = require('web3');
const ganache = require('ganache-cli');
const { abi, bytecode } = require('./compile');

const web3 = new Web3(ganache.provider());

let accounts;
let saleTicket;

beforeEach(async () => {
  // Get test accounts
  accounts = await web3.eth.getAccounts();

  // Deploy the contract
  saleTicket = await new web3.eth.Contract(abi)
    .deploy({ data: bytecode, arguments: [100, web3.utils.toWei('0.01', 'ether')] })
    .send({ from: accounts[0], gas: '3000000' });
});

describe('SaleTicket Contract', () => {
  it('deploys successfully', () => {
    assert.ok(saleTicket.options.address);
  });

  it('allows purchase of a ticket', async () => {
    await saleTicket.methods.buyTicket(1).send({
      from: accounts[1],
      value: web3.utils.toWei('0.01', 'ether'),
      gas: '3000000'
    });

    const ticketId = await saleTicket.methods.getTicketOf(accounts[1]).call();
    assert.equal(ticketId, 1);
  });

  it('prevents double purchase by the same account', async () => {
    await saleTicket.methods.buyTicket(2).send({
      from: accounts[1],
      value: web3.utils.toWei('0.01', 'ether'),
      gas: '3000000'
    });

    try {
      await saleTicket.methods.buyTicket(3).send({
        from: accounts[1],
        value: web3.utils.toWei('0.01', 'ether'),
        gas: '3000000'
      });
      assert(false); // Should not reach here
    } catch (error) {
      assert(error);
    }
  });

  it('allows ticket resale', async () => {
    await saleTicket.methods.buyTicket(4).send({
      from: accounts[1],
      value: web3.utils.toWei('0.01', 'ether'),
      gas: '3000000'
    });

    await saleTicket.methods.resaleTicket(web3.utils.toWei('0.009', 'ether')).send({
      from: accounts[1],
      gas: '3000000'
    });

    await saleTicket.methods.acceptResale(4).send({
      from: accounts[2],
      value: web3.utils.toWei('0.009', 'ether'),
      gas: '3000000'
    });

    const ticketId = await saleTicket.methods.getTicketOf(accounts[2]).call();
    assert.equal(ticketId, 4);
  });
});
