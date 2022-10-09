pragma solidity ^0.8.13;

import "solmate/tokens/ERC20.sol";
import "solmate/auth/Owned.sol";

contract SimpleOracle is Owned {
    uint256 public price;

    constructor() Owned(msg.sender) {}

    function setPrice(uint newPrice) external onlyOwner {
        price = newPrice;
    }
}


contract Overcollateralized is ERC20 {
    uint256 public constant cRatio = 1.5 ether;
    SimpleOracle public oracle;

    struct CDP {
        uint256 collateral;
        uint256 debt;
    }

    mapping (address => CDP) public cdps;

    event Liquidated(address who);

    constructor(SimpleOracle oracle_) ERC20(
        "Collateralized",
        "Nikolai",
        18
    ) {
        oracle = oracle_;
    }

    function addCollateral() external payable {
        cdps[msg.sender].collateral += msg.value;
    }

    function generateDebt(uint amount) external {
        require(getCRatio(
            cdps[msg.sender].collateral,
            cdps[msg.sender].debt + amount
        ) >= cRatio, "unhealthy");

        cdps[msg.sender].debt += amount;
        _mint(msg.sender, amount);
    }

    function liquidate(address cdp) external {
        require(getCRatio(
            cdps[cdp].collateral,
            cdps[cdp].debt
        ) < cRatio, "healthy");

        emit Liquidated(cdp);
        payable(address(0xdeadbeef)).transfer(cdps[cdp].collateral);
        delete cdps[cdp];

    }

    function getCRatio(uint collateral, uint256 debt) public view returns (uint256) {
        return (collateral * oracle.price()) / debt;
    }



}