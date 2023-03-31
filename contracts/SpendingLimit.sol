pragma solidity ^0.8.18;

import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SpendingLimit {

    address private constant TOKEN_ADDRESS = 0x123456789; // Replace with the token contract address
    address private constant SAFE_ADDRESS = 0x987654321; // Replace with the Gnosis Safe contract address
    address private constant OWNER_ADDRESS = 0x111111111; // Replace with the owner's address

    struct Limit {
        uint256 amount; // the maximum amount that can be spent during the given period
        uint256 periodStart; // the start of the current period
        uint256 lastSpent; // the timestamp of the last spend
    }

    mapping(address => mapping(address => Limit)) public limits;

    function setLimit(address token, uint256 amount, uint256 period) external {
        require(amount > 0, "Amount must be greater than zero");
        limits[msg.sender][token].amount = amount;
        limits[msg.sender][token].periodStart = block.timestamp;
        limits[msg.sender][token].lastSpent = block.timestamp;
    }

    function spend(address token, uint256 amount) external {
        Limit storage limit = limits[msg.sender][token];
        require(amount <= limit.amount, "Amount exceeds spending limit");

        uint256 currentPeriod = (block.timestamp - limit.periodStart) / period;
        if (currentPeriod > 0) {
            limit.amount = limit.amount - (limit.amount * currentPeriod);
            limit.periodStart = block.timestamp;
        }

        require(amount <= limit.amount, "Amount exceeds spending limit");
        require(IERC20(token).allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");
        require(IERC20(token).balanceOf(msg.sender) >= amount, "Insufficient balance");

        IERC20(token).transferFrom(msg.sender, address(this), amount);
        limit.amount = limit.amount - amount;
        limit.lastSpent = block.timestamp;
    }

    //Makes normal calls to gnosis safe for transfering an erc20 token
    function transferTokens(address _recipient, uint256 _amount) public {
        IERC20 token = IERC20(TOKEN_ADDRESS);
        require(token.balanceOf(address(this)) >= _amount, "Insufficient tokens");
        token.transfer(_recipient, _amount);

        GnosisSafe safe = GnosisSafe(SAFE_ADDRESS);
        bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", _recipient, _amount);
        uint256 nonce = safe.nonce();
        bytes memory signature = signData(safe, data, nonce);

        safe.execTransactionFromModule(TOKEN_ADDRESS, 0, data, GnosisSafe.Operation.DelegateCall, 0, 0, 0, 0, signature);
    }

    //sign Safe tx
    function signData(GnosisSafe _safe, bytes memory _data, uint256 _nonce) private view returns (bytes memory) {
        bytes32 hash = keccak256(abi.encodePacked(
            _safe.DOMAIN_SEPARATOR(),
            keccak256(abi.encodePacked(
                _safe.getSafeTxHash(address(this), _data, _nonce)
            ))
        ));

        (bool success, bytes memory signature) = OWNER_ADDRESS.staticcall(abi.encodeWithSignature("sign(bytes32)", hash));
        require(success, "Signature failed");

        return signature;
    }

}
