pragma solidity ^0.4.15;

import './helpers/BasicToken.sol';
import './lib/safeMath.sol';

contract EPTToken is BasicToken {

    using SafeMath for uint256;

    string public name = "e-Pocket Token";                      //name of the token
    string public symbol = "EPT";                               //symbol of the token
    uint8 public decimals = 18;                                 //decimals
    uint256 public totalSupply = 64000000 * 10**18;           //total supply of Tokens

    //variables
    uint256 public totalAllocatedTokens;                         //variable to keep track of funds allocated
    uint256 public tokensAllocatedToCrowdFund;                   //funds allocated to crowdfund
    uint256 public foundersAllocation;                           //funds allocated to founder

    //addresses
    address public founderMultiSigAddress;                       //Multi sign address of founder
    address public crowdFundAddress;                             //Address of crowdfund contract

    //events
    event ChangeFoundersWalletAddress(uint256 _blockTimeStamp, address indexed _foundersWalletAddress);
    
    //modifierss

    modifier nonZeroAddress(address _to){
        require(_to != 0x0);
        _;
    }

    modifier onlyFounders(){
        require(msg.sender == founderMultiSigAddress);
        _;
    }

    modifier onlyCrowdfund(){
        require(msg.sender == crowdFundAddress);
        _;
    }

    /**
        @dev EPTToken Constructor to initiate the variables with some input argument
        @param _crowdFundAddress This is the address of the crowdfund which leads the distribution of tokens
        @param _founderMultiSigAddress This is the address of the founder which have the hold over the contract.
    
     */
    
    function EPTToken(address _crowdFundAddress, address _founderMultiSigAddress) {
        crowdFundAddress = _crowdFundAddress;
        founderMultiSigAddress = _founderMultiSigAddress;
    
        //token allocation
        tokensAllocatedToCrowdFund = 32 * 10**24;
        foundersAllocation = 32 * 10**24;

        // Assigned balances
        balances[crowdFundAddress] = tokensAllocatedToCrowdFund;
        balances[founderMultiSigAddress] = foundersAllocation;

        totalAllocatedTokens = balances[founderMultiSigAddress];
    }

    /**
        @dev changeTotalSupply is the function used to variate the variable totalAllocatedTokens
        @param _amount amount of tokens are sold out to increase the value of totalAllocatedTokens
     */

    function changeTotalSupply(uint256 _amount) onlyCrowdfund {
        totalAllocatedTokens += _amount;
    }


    /**
        @dev changeFounderMultiSigAddress function use to change the ownership of the contract
        @param _newFounderMultiSigAddress New address which will take the ownership of the contract
     */
    
    function changeFounderMultiSigAddress(address _newFounderMultiSigAddress) onlyFounders nonZeroAddress(_newFounderMultiSigAddress) {
        founderMultiSigAddress = _newFounderMultiSigAddress;
        ChangeFoundersWalletAddress(now, founderMultiSigAddress);
    }

  
}
