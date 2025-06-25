// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Subasta {
   address public owner;
   address public mejorOferente;
   uint public mejorOferta;

   uint public inicio;
   uint public duracion = 2 minutes;
   bool public finalizada;

   mapping(address => uint) public depositos;

   event NuevaOferta(address indexed oferente, uint monto);
   event SubastaFinalizada(address ganador, uint monto);
   event FondosRetirados(address indexed to, uint amount);

   constructor() {
       owner = msg.sender;
       inicio = block.timestamp;
   }

   modifier subastaActiva() {
       require(!finalizada, "Subasta finalizada");
       require(block.timestamp <= inicio + duracion, "Tiempo terminado");
       _;
   }

   modifier soloOwner() {
       require(msg.sender == owner, "No eres el owner");
       _;
   }

   function ofertar() external payable subastaActiva {
       require(msg.value > 0, "Debes enviar ETH");

       uint total = depositos[msg.sender] + msg.value;
       uint minimoRequerido = mejorOferta + (mejorOferta * 5) / 100;

       require(total >= minimoRequerido, "La oferta debe superar en al menos 5%");

       depositos[msg.sender] = total;
       mejorOferente = msg.sender;
       mejorOferta = total;

       emit NuevaOferta(msg.sender, total);
   }

   function finalizar() external soloOwner {
       require(!finalizada, "Ya finalizo");
       require(block.timestamp >= inicio + duracion, "Aun no termina");

       finalizada = true;

       emit SubastaFinalizada(mejorOferente, mejorOferta);
   }

   function retirar() external {
       require(finalizada, "Subasta no finalizada");
       require(msg.sender != mejorOferente, "Ganador no puede retirar");

       uint deposito = depositos[msg.sender];
       require(deposito > 0, "Nada para retirar");

       uint comision = (deposito * 2) / 100;
       uint reembolso = deposito - comision;

       depositos[msg.sender] = 0;
       payable(msg.sender).transfer(reembolso);
   }

   /// Permite al owner retirar los fondos ganadores
   function retirarFondos() external soloOwner {
       require(finalizada, "Subasta no finalizada");
       require(address(this).balance > 0, "Sin balance disponible");

       uint monto = address(this).balance;
       (bool exito, ) = payable(owner).call{value: monto}("");
       require(exito, "Fallo al transferir al owner");
       emit FondosRetirados(owner, monto);
   }

   /// Retorna los segundos restantes hasta el fin de la subasta
   function tiempoRestante() external view returns (uint) {
       if (block.timestamp >= inicio + duracion || finalizada) {
           return 0;
       } else {
           return (inicio + duracion) - block.timestamp;
       }
   }

   /// Consulta del balance del contrato
   function verBalance() external view returns (uint) {
       return address(this).balance;
   }
}