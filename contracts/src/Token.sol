// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/Token.sol";
import "openzeppelin-contracts/contracts/utils/math/SafeMath.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/security/Pausable.sol";

contract FuzzToken is IFuzzToken, Ownable, Pausable {
    using SafeMath for uint256;
    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 private _totalSupply;
    
    string internal constant ALREADY_LOCKED = 'Tokens already locked';
    string internal constant NOT_LOCKED = 'No tokens locked';
    string internal constant AMOUNT_ZERO = 'Amount can not be 0';

    /* always capped by 10B tokens */
    uint256 internal constant MAX_TOTAL_SUPPLY = 10000000000;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => bool) frozenAccount;

    event FreezeAccount(address _address, bool frozen);

    constructor(
        uint256 _totalSupply_,
        uint8 _decimals)

    {
        symbol = "FUZL";
        name = "FuzzLand";
        decimals = _decimals;
        _totalSupply = _totalSupply_ * 10**uint256(_decimals);
        balances[owner()] = _totalSupply;

        emit Transfer(address(0), owner(), _totalSupply);
    }

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return _totalSupply;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value)
        internal
        returns (bool success)
    {
        require (balances[_from] >= _value);
        require(!frozenAccount[_from]);
        require(!frozenAccount[_to]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    function transfer(
        address _to,
        uint256 _value)
        public
        whenNotPaused
        returns (bool success)
    {
        return _transfer(msg.sender, _to, _value);
    }

    function approve(
        address _spender,
        uint256 _value)
        public
        whenNotPaused
        returns (bool success)
    {
        require(!frozenAccount[msg.sender]);
        require(!frozenAccount[_spender]);

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value)
        public
        whenNotPaused
        returns (bool success)
    {
        require(!frozenAccount[msg.sender]);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        return _transfer(_from, _to, _value);
    }

    function balanceOf(
        address _address)
        public
        view
        returns (uint256 remaining)
    {
        return balances[_address];
    }


    function allowance(
        address _owner,
        address _spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    function freezeAccount(
        address _address,
        bool freeze)
        public
        onlyOwner
        returns (bool success)
    {
        frozenAccount[_address] = freeze;
        emit FreezeAccount(_address, freeze);
        return true;
    }

    function isFrozenAccount(
        address _address)
        public
        view
        returns (bool frozen)
    {
        return frozenAccount[_address];
    }

    function mint(
        uint256 amount) 
        public 
        onlyOwner 
        returns (bool success)
    {
        uint256 newSupply = _totalSupply + amount;
        require(newSupply <= MAX_TOTAL_SUPPLY * 10 **uint256(decimals), "ERC20: exceed maximum total supply");

        _totalSupply = newSupply;
        balances[owner()] += amount;
        emit Transfer(address(0), address(owner()), amount);
        return true;
    }

    function burn(
        uint256 amount) 
        public 
        whenNotPaused
        returns (bool success)
    {
        require (balances[msg.sender] >= amount);
        require(!frozenAccount[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(amount);
        _totalSupply -= amount;

        emit Transfer(msg.sender, address(0), amount);
        return true;
    }

}
