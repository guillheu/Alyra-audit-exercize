pragma solidity 0.6.12;
 
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol";
 
contract Crowdsale {
   using SafeMath for uint256;
 
   address public owner; // the owner of the contract
   address payable public escrow; // wallet to collect raised ETH
   
   uint256 public savedBalance; // Total amount raised in ETH
   mapping (address => uint256) public balances; // Balances in incoming Ether
 
   // Initialization
   
   constructor(address payable _escrow) public{
       
       owner = msg.sender;
       // add address of the specific contract
       escrow = _escrow;
   }
  
   // function to receive ETH
   
   
   receive() external payable {
       balances[msg.sender] = balances[msg.sender].add(msg.value);
       savedBalance = savedBalance.add(msg.value);
       
       escrow.call{value: msg.value}("");
   }
  
   // refund investisor
   function withdrawPayments() public{
       require(balances[msg.sender] > 0, "Null balance");
       address payable payee = msg.sender;
       uint256 payment = balances[payee];
 
      savedBalance = savedBalance.sub(payment);
       delete balances[payee];
       
        
       payee.call{value: payment}("");
 
  
   }
}
