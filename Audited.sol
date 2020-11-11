//utiliser une version stable du compilateur (pas de ^)
//Aussi, utiliser une version plus récente du compilateur (0.6.12 pour être compatible avec OpenZepplin et la librairie SafeMath)
//import manquant pour SafeMath
pragma solidity ^0.5.12;
 
contract Crowdsale {
   using SafeMath for uint256;
 
   address public owner; // the owner of the contract
   //l'adresse escrow, vers qui on envoie des paiements, doit être déclarée en address payable
   address public escrow; // wallet to collect raised ETH
   
   //initialiser un uint à 0 n'est pas nécessaire et consomme du gas inutilement.
   uint256 public savedBalance = 0; // Total amount raised in ETH
   mapping (address => uint256) public balances; // Balances in incoming Ether
 
   // Initialization
   
   //le constructeur doit être déclaré en tant que constructor
   function Crowdsale(address _escrow) public{
       
       //utiliser msg.sender au lieu de tx.origin
       owner = tx.origin;
       // add address of the specific contract
       escrow = _escrow;
   }
  
   // function to receive ETH
   
   //une fonction de réception d'ETH doit être payable
   //de plus, il est souhaitable d'utiliser la fonction receive external
   function() public {
   
        //Vérifier que le montant envoyé n'est pas nul pour éviter des executions superflues
   
       balances[msg.sender] = balances[msg.sender].add(msg.value);
       savedBalance = savedBalance.add(msg.value);
       
       //éviter d'utiliser la fonction send pour effectuer un paiement, utiliser la fonction call est préférable
       escrow.send(msg.value);
   }
  
   // refund investisor
   function withdrawPayments() public{
        //l'adresse payee reçoit de l'argent, et doit donc être déclarée en address payable
       address payee = msg.sender;
       uint256 payment = balances[payee];
 
 
        //Effectuer le remboursement avant de réinitialiser la balance du compte peut être exploité par une réentrance.
        //Il est nécessaire d'effectuer le remboursement après avoir réinitialisé la balance du compte, ainsi que d'ajouter un require au début de la fonction
        //pour s'assurer que la balance du compte n'est pas à 0, et ainsi ne pas effectuer des remboursements vides qui coûteraient du gas.
        //Egalement ne pas utiliser la fonction send
       payee.send(payment);
 
       savedBalance = savedBalance.sub(payment);
       //utiliser un delete pour réinitialiser une case d'un tableau permet de rembourser du gas
       balances[payee] = 0;
   }
}
