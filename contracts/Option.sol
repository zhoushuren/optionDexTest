
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;


contract Option {

    mapping(address => uint256) callBalanceOf;

    address token;
    uint256 endTime;
    uint256 strikePrice;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transferFrom(address,address,uint256,uint256,uint256,uint256,uint256)')));


    constructor(address _token, uint256 _endTime, uint256 _strikePrice, string _direction) public {
        token = _token;
        endTime = _endTime;
        strikePrice = _strikePrice;
        direction = _direction;
    }

    function mintCall(uint256 amount) {

        uint256 newTokenStart = block.timestamp;
        uint256 newTokenEnd = endTime;

        // 全段token 如s（FSN） 的转过来。 mint 两段期权token， 前段拿去卖，后段自己留着. 如果到期后用户不行权那就自己行权把token赎回.. 不对，这里mint的期权token也是完整的。转账的时候切
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, from, address(this), amount, tokenStart, tokenEnd, newTokenStart, newTokenEnd));
         require(success && (data.length == 0 || abi.decode(data, (bool))), 'Frc758: TRANSFER_FAILED');

        _mintCall(amount);
        return true;
    }


    // 在这里切时间。按照endTime来切。 前段切给比尔呢，后段留给自己s
    function transferFrom() public {
        
    }
    function _mintCall(uint256 amount) private {
        callBalanceOf[msg.sender] += amount;
    }

    function exercise(uint256 amount) {
        require(endTime > block.timestamp, 'time out');
        _burn(msg.sender, amount);

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, address(this), msg.sender , amount, tokenStart, tokenEnd, newTokenStart, newTokenEnd));
         require(success && (data.length == 0 || abi.decode(data, (bool))), 'Frc758: TRANSFER_FAILED');
    }

    function _burn(address from, uint256 value) {
        balanceOf[from] = balanceOf[from].sub(value);
    }
}