// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;
contract DFP {
    event PaidToProvider(address provider,address paidBy, uint256 amount);
    event Contributed(address receipent,address purpose);
    event ProviderUpdated(address provider,string name);
    uint256 public totalFunds = 0;
    mapping(address => string) public providers;
    struct Funds {
        address provider;
        uint256 funds;
    }
    //First is user addr, second is funds
    mapping(address=>Funds[]) public funds;
    function contribute(address receipent,address purpose) external payable {
        for(uint256 i=0; i<totalFunds; i++){
            Funds memory f = funds[receipent][i];
            if (f.provider==purpose){
                funds[receipent][i].funds+=msg.value;
                emit Contributed(receipent, purpose);
                return;
            }
        }
        Funds memory newFund;
        newFund.funds = msg.value;
        newFund.provider = purpose;
        funds[receipent].push(newFund);
        totalFunds++;
        emit Contributed(receipent, purpose);
    }

    function send(address purpose,uint256 amount) public {
          for(uint256 i=0; i<totalFunds; i++){
            Funds memory f = funds[msg.sender][i];
            if (f.provider==purpose){
                require(funds[msg.sender][i].funds>=amount,"not enough balance");
                funds[msg.sender][i].funds-=amount;
                  (bool success, ) = purpose.call{value:amount}("");
                     require(success, "Transfer failed.");
                 emit PaidToProvider(purpose,msg.sender,amount);
                    return;
            }

            require(false,"no funds found");
        }
    }

    function getFunds(address ofAddr) public view returns (Funds[] memory) {
        return funds[ofAddr];  
    }
    function registerUpdateProvider(string memory name) public {
        providers[msg.sender]=name;
        emit ProviderUpdated(msg.sender,name);
    }
}