pragma solidity ^0.8.18;

import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SpendingLimit {

    address private constant TOKEN_ADDRESS = 0x123456789; // Replace with the token contract address
    address private constant SAFE_ADDRESS = 0x987654321; // Replace with the Gnosis Safe contract address
    address private constant OWNER_ADDRESS = 0x111111111; // Replace with the owner's address

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
