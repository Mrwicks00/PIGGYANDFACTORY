//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

pragma solidity 0.8.28;

contract PiggyCA {
    error chopRicechopRice();
    error InvalidToken();
    error InsufficientFunds();
    error notYetTime();
    error TimePassed();
    error noMoneyInTheBank();
    error InsufficientBalance();

    string savingPurpose;

    uint256 endTime;
    uint256 constant PENALTY_FEE = 15; //Know this and know peace
    address developerAddress;
    address owner;

    bool withdrawn;

    struct TokenDetails {
        address tokenAddress;
        uint256 balance;
    }

    enum Tokens {
        DAI,
        USDT,
        USDC
    }

    mapping(Tokens => TokenDetails) public tokenDetails;

    event Save(address indexed to, uint256 amount);
    event Withdrawn(address to, uint256 amount);

    constructor(
        string memory _savingPurpose,
        uint256 _endTime,
        address _owner,
        address _devAddy
    ) {
        require(
            _endTime > block.timestamp,
            "Unlock time must be in the future"
        );
        savingPurpose = _savingPurpose;

        endTime = block.timestamp + _endTime;
        owner = _owner;
        developerAddress = _devAddy;

        //Initializing our token addresses, Let's fire down 🔥
        tokenDetails[Tokens.DAI] = TokenDetails(
            0x6B175474E89094C44Da98b954EedeAC495271d0F,
            0
        );
        tokenDetails[Tokens.USDT] = TokenDetails(
            0xdAC17F958D2ee523a2206206994597C13D831ec,
            0
        );
        tokenDetails[Tokens.USDC] = TokenDetails(
            0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            0
        );
    }

    modifier isWithdrawn() {
        require(withdrawn == false, "Already withdrawn");
        _;
    }
    modifier onlyOwner() {
        require(owner == msg.sender, "Only Owner can Withdraw");
        _;
    }

    function save(Tokens tokenId, uint256 _amount) external isWithdrawn {
        address _tokenAddress = tokenDetails[tokenId].tokenAddress;
        if (tokenDetails[tokenId].tokenAddress == address(0))
            revert InvalidToken();
        if (_amount == 0) revert chopRicechopRice();
        if (block.timestamp > endTime) revert TimePassed();
        if (IERC20(_tokenAddress).balanceOf(msg.sender) < _amount)
            revert InsufficientFunds();
        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount);
        tokenDetails[tokenId].balance += _amount;
        emit Save(address(this), _amount);
    }

    function withdraw(Tokens tokenId) external onlyOwner isWithdrawn {
        address _tokenAddress = tokenDetails[tokenId].tokenAddress;
        uint256 _balance = tokenDetails[tokenId].balance;
        if (endTime > block.timestamp) revert notYetTime();
        if (_balance == 0) revert InsufficientBalance();
        if (IERC20(_tokenAddress).balanceOf(address(this)) == 0)
            revert noMoneyInTheBank();
        uint256 contractBalance = IERC20(_tokenAddress).balanceOf(
            address(this)
        );
        _balance = 0;
        withdrawn = true;
        IERC20(_tokenAddress).transfer(msg.sender, contractBalance);
        emit Withdrawn(msg.sender, contractBalance);
    }

    function EmergencyWithdrawal(
        Tokens tokenId
    ) external onlyOwner isWithdrawn {
        if (block.timestamp < endTime) {
            address _tokenAddress = tokenDetails[tokenId].tokenAddress;
            uint256 _amount = tokenDetails[tokenId].balance;
            uint256 penaltyAmount = calculatePenaltyFee(_amount);
            uint256 remainingBalance = _amount - penaltyAmount;
            tokenDetails[tokenId].balance = 0;
            IERC20(_tokenAddress).transfer(msg.sender, remainingBalance);
            IERC20(_tokenAddress).transfer(developerAddress, penaltyAmount);
            withdrawn = true;
            emit Withdrawn(msg.sender, remainingBalance);
            emit Withdrawn(developerAddress, penaltyAmount);
        }
    }

    function calculatePenaltyFee(
        uint256 _amount
    ) private pure returns (uint256) {
        return (_amount * PENALTY_FEE) / 100;
    }

    function getBalance(Tokens tokenId) external view returns (uint256) {
        uint256 balance = tokenDetails[tokenId].balance;
        return balance;
    }
}
