// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

interface tokenRecepient {
 function receiveApproval(
    address _from,
    uint256 _value,
    address _token,
    bytes calldata _extraData
  ) external;
}


contract ManualToken {

  string public name;
  uint8 public decimals = 18;
  uint256 public totalSupply;
  string public symbol;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address sender, uint256 value );
  event Burn(address indexed from, uint indexed value);

  mapping (address => uint256) public balanceOf;
  mapping (address => mapping (address => uint256)) allowance;

  constructor(string memory tokenName, uint256 initialSupply, string memory tokenSymbol) {
    name = tokenName;
    totalSupply = initialSupply * 10**uint256(decimals);
    balanceOf[msg.sender] = totalSupply;
    symbol = tokenSymbol;
  }


  //Contract of the deployer or msg.sender
  function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
    require(_to != address(0x0));
    require(balanceOf[_from] >= _value);
    require(balanceOf[_to] + _value >= balanceOf[_to]);
    uint256 previousBalance = balanceOf[_from] + balanceOf[_to];
    balanceOf[_from] -= _value;
    balanceOf[_to] += _value;   
    emit Transfer(_from, _to, _value);
    assert(balanceOf[_from] + balanceOf[_to] == previousBalance);
  }


  //Transfer by deployer
  function transfer(address to, uint256 value) public  returns (bool success) {
    _transfer(msg.sender, to, value);
    return true;
  }

  //Tranfer by other addresses
  function transferFrom(address from, address to, uint256 value) public returns(bool success){
    require(value <= allowance[from][msg.sender]);
    allowance[from][msg.sender] -= value;
    _transfer(from, to, value);
    return true;
  }

  //Sets allowance for other addresses
  function approve(address sender, uint256 value) public returns(bool success){
    allowance[msg.sender][sender] = value;
    emit Approval(msg.sender, sender, value);
    return true;
  }

  function approveCall(address _sender, uint256 _value, bytes memory _extraData) public returns(bool success){
    tokenRecepient sender = tokenRecepient(_sender);
    if(approve(_sender , _value)){
      sender.receiveApproval(msg.sender, _value, address(this), _extraData);
      return true;
    }
  }

  //Burn by deployer
  function burn(uint256 value) public returns(bool success){
   require(balanceOf[msg.sender] >= value);
   balanceOf[msg.sender] -= value;
   totalSupply -= value;
   emit Burn(msg.sender, value);
   return true;
  }

  function burnFrom(address _from, uint256 _value) public returns(bool success){
    require(balanceOf[_from] >= _value);
    require(_value <= allowance[_from][msg.sender]);
    balanceOf[_from] -= _value;
    allowance[_from][msg.sender] -= _value;
    totalSupply -= _value;
    emit Burn(_from, _value);
    return true;
 
  }
}
