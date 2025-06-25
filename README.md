# Subasta-Smart-Contract

## 📜 Descripción General

El contrato permite realizar una subasta pública donde los participantes pueden ofertar enviando ETH. La subasta se rige por las siguientes reglas:

- La mejor oferta debe superar la actual en **al menos un 5%**.
- La duración por defecto es de **2 minutos**.
- Los oferentes no ganadores pueden retirar su depósito con una comisión del **2%**.
- El contrato emite eventos importantes como `NuevaOferta`, `SubastaFinalizada` y `FondosRetirados`

## 📦 Estructura del Contrato

### Variables principales

- `owner`: Dirección del creador del contrato.
- `mejorOferente`: Dirección del participante con la mejor oferta.
- `mejorOferta`: Monto actual más alto.
- `inicio`: Timestamp del inicio de la subasta.
- `duracion`: Duración de la subasta (por defecto: 2 minutos).
- `finalizada`: Indica si la subasta fue finalizada.
- `depositos`: Mapeo que guarda los depósitos por dirección.

## ⚙️ Funcionalidades Implementadas

### 🛠️ Constructor

```solidity
constructor() {
    owner = msg.sender;
    inicio = block.timestamp;
}

Inicializa el contrato con el owner como quien lo despliega y marca el inicio de la subasta.

🏷️ Función ofertar()
Permite a un usuario hacer una oferta si:

La subasta está activa.
El monto ofrecido supera la mejor oferta en al menos 5%.
El ETH enviado se acumula al depósito anterior del oferente.

require(total >= minimoRequerido, "La oferta debe superar en al menos 5%");

Función finalizar()
Solo puede ser ejecutada por el owner una vez que el tiempo ha terminado.

Marca la subasta como finalizada y emite el evento:
emit SubastaFinalizada(mejorOferente, mejorOferta);

💸 Función retirar()
Permite a los oferentes no ganadores retirar su depósito, descontando una comisión del 2%:

uint comision = (deposito * 2) / 100;
uint reembolso = deposito - comision;

💰 Función retirarFondos()
Permite al owner retirar todos los fondos disponibles del contrato después de finalizada la subasta.

🕒 Función tiempoRestante()
Devuelve los segundos que faltan para que la subasta termine.

💼 Función verBalance()
Consulta el balance en ETH del contrato.

📢 Eventos

NuevaOferta(address oferente, uint monto): Emitido cuando un participante realiza una nueva oferta válida.
SubastaFinalizada(address ganador, uint monto): Emitido al finalizar la subasta.
FondosRetirados(address to, uint amount): Emitido al retirar los fondos del contrato.



