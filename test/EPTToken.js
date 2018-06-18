var EPTToken = artificats.require('./EPTToken.sol');
var EPTCrowdfund = artificats.require('./EPTCrowdfund.sol');
var Utils = require('./helpers/Utils');
var BigNumer = require('bignumber.js');

let crowdfundAddress ;
let founderWalletAddress;
let owner;

contract('EPTToken',(accounts) => {
    before(async ()=>{
    crowdfundAddress = address[1];
    founderWalletAddress = address[2];
    owner = address[3];
    let token = await EPTToken.new(crowdfundAddress,founderWalletAddress,{from:owner});
    });


it("Constructor Parameter",async()=>{
    let token = await EPTToken.new(crowdfundAddress, founderWalletAddress,{from:owner});
    let founderAddress = await token
                        .founderWalletAddress
                        .call();
    assert.equal(founderAddress,founderWalletAddress);
    let allocToCrowdfund = await token
                         .tokensAllocatedToCrowdFund
                         .call();
    assert.strictEqual(allocToCrowdfund.dividedBy(new BigNumber(10).pow(18)).toNumber(),32000000);
    let allocToFounder = await token
                        .tokensAllocatedToCrowdFund
                        .call();
    assert.strictEqual(allocToFounder.dividedBy(new BigNumber(10).pow(18)).toNumber(),32000000);
});



});