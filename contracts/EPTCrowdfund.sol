pragma solidity ^0.4.15;

import './helpers/BasicToken.sol';
import './EPTToken.sol';

contract EPTCrowdfund {
    
    using SafeMath for uint256;

    EPTToken public token;                                      // Token contract reference
    
    address public beneficiaryAddress;                          // Address where all funds get allocated 
    address public founderAddress;                              // Founders address
    uint256 public crowdfundStartTime = 1516579201;             // Monday, 22-Jan-18 00:00:01 UTC
    uint256 public crowdfundEndTime = 1518998399;               // Sunday, 18-Feb-18 23:59:59 UTC
    uint256 public presaleStartTime = 1513123201;               // Wednesday, 13-Dec-17 00:00:01
    uint256 public presaleEndTime = 1516579199;                 // Sunday, 21-Jan-18 23:59:59
    uint256 public ethRaised;                                   // Counter to track the amount raised
    bool private tokenDeployed = false;                         // Flag to track the token deployment -- only can be set once
    uint256 public tokenSold;                                   // Counter to track the amount of token sold
    uint256 private ethRate;
    
    
    //events
    event ChangeFounderAddress(address indexed _newFounderAddress , uint256 _timestamp);
    event TokenPurchase(address indexed _beneficiary, uint256 _value, uint256 _amount);
    event CrowdFundClosed(uint256 _timestamp);
    
    enum State {PreSale, CrowdSale, Finish}
    
    //Modifiers
    modifier onlyfounder() {
        require(msg.sender == founderAddress);
        _;
    }

    modifier nonZeroAddress(address _to) {
        require(_to != 0x0);
        _;
    }

    modifier onlyPublic() {
        require(msg.sender != founderAddress);
        _;
    }

    modifier nonZeroEth() {
        require(msg.value != 0);
        _;
    }

    modifier isTokenDeployed() {
        require(tokenDeployed == true);
        _;
    }

    modifier isBetween() {
        require(now >= presaleStartTime && now <= crowdfundEndTime);
        _;
    }

    /**
        @dev EPTCrowdfund Constructor used to initialize the required variable.
        @param _founderAddress Founder address 
        @param _ethRate Rate of ether in dollars at the time of deployment.
        @param _beneficiaryAddress Address that hold all funds collected from investors

     */

    function EPTCrowdfund(address _founderAddress, address _beneficiaryAddress, uint256 _ethRate) {
        beneficiaryAddress = _beneficiaryAddress;
        founderAddress = _founderAddress;
        ethRate = uint256(_ethRate);
    }
   
    /**
        @dev setToken Function used to set the token address into the contract.
        @param _tokenAddress variable that contains deployed token address 
     */

    function setToken(address _tokenAddress) nonZeroAddress(_tokenAddress) onlyfounder {
         require(tokenDeployed == false);
         token = EPTToken(_tokenAddress);
         tokenDeployed = true;
    }
    
    
    /**
        @dev changeFounderWalletAddress used to change the wallet address or change the ownership
        @param _newAddress new founder wallet address
     */

    function changeFounderWalletAddress(address _newAddress) onlyfounder nonZeroAddress(_newAddress) {
         founderAddress = _newAddress;
         ChangeFounderAddress(founderAddress,now);
    }

    
    /**
        @dev buyTokens function used to buy the tokens using ethers only. sale 
            is only processed between start time and end time. 
        @param _beneficiary address of the investor
        @return bool 
     */

    function buyTokens (address _beneficiary)
    isBetween
    onlyPublic
    nonZeroAddress(_beneficiary)
    nonZeroEth
    isTokenDeployed
    payable
    public
    returns (bool)
    {
         uint256 amount = msg.value.mul(((ethRate.mul(100)).div(getRate())));
    
        if (token.transfer(_beneficiary, amount)) {
            fundTransfer(msg.value);
            
            ethRaised = ethRaised.add(msg.value);
            tokenSold = tokenSold.add(amount);
            token.changeTotalSupply(amount); 
            TokenPurchase(_beneficiary, msg.value, amount);
            return true;
        }
        return false;
    }

    /**
        @dev setEthRate function used to set the ether Rate
        @param _newEthRate latest eth rate
        @return bool
     
     */

    function setEthRate(uint256 _newEthRate) onlyfounder returns (bool) {
        require(_newEthRate > 0);
        ethRate = _newEthRate;
        return true;
    }

    /**
        @dev getRate used to get the price of each token on weekly basis
        @return uint256 price of each tokens in dollar
    
     */

    function getRate() internal returns(uint256) {

        if (getState() == State.PreSale) {
            return 10;
        } 
        if(getState() == State.CrowdSale) {
            if (now >= crowdfundStartTime + 3 weeks && now <= crowdfundEndTime) {
                return 30;
             }
            if (now >= crowdfundStartTime + 2 weeks) {
                return 25;
            }
            if (now >= crowdfundStartTime + 1 weeks) {
                return 20;
            }
            if (now >= crowdfundStartTime) {
                return 15;
            }  
        } else {
            return 0;
        }
              
    }  

    /**
        @dev `getState` used to findout the state of the crowdfund
        @return State 
     */

    function getState() private returns(State) {
        if (now >= crowdfundStartTime && now <= crowdfundEndTime) {
            return State.CrowdSale;
        }
        if (now >= presaleStartTime && now <= presaleEndTime) {
            return State.PreSale;
        } else {
            return State.Finish;
        }

    }

    /**
        @dev endCrowdFund called only after the end time of crowdfund . use to end the sale.
        @return bool
     */

    function endCrowdFund() onlyfounder returns(bool) {
        require(now > crowdfundEndTime);
        uint256 remainingtoken = token.balanceOf(this);

        if (remainingtoken != 0) {
            token.transfer(founderAddress,remainingtoken);
            CrowdFundClosed(now);
            return true;
        }
        CrowdFundClosed(now);
        return false;    
 } 

    /**
        @dev fundTransfer used to transfer collected ether into the beneficary address
     */

    function fundTransfer(uint256 _funds) private {
        beneficiaryAddress.transfer(_funds);
    }

    // Crowdfund entry
    // send ether to the contract address
    // gas used 200000
    function () payable {
        buyTokens(msg.sender);
    }

}
