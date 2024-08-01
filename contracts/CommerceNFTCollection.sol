// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CommerceNFTCollection is ERC721URIStorage, Ownable {
    uint256 public tokenCounter;

    constructor() ERC721("CommerceNFTCollection", "CNC") {
        tokenCounter = 0; //Contador que mantiene el número total de NFTs que se han minteado.
        //Inicializa en 0 y se incrementa con cada nuevo NFT.
    }

    function mintNFT(address recipient/*La dirección que recibirá el nuevo NFT.*/, string memory tokenURI/*La URI del token que apunta a los metadatos del NFT.*/ ) public onlyOwner/*Modificador de OpenZeppelin que asegura que solo el propietario del contrato pueda ejecutar esta función.*/ returns (uint256) {
        //Permite al propietario del contrato mintear (crear) nuevos NFTs.
        uint256 newItemId = tokenCounter;//Asigna el valor actual de tokenCounter como el ID del nuevo NFT.
        _safeMint(recipient, newItemId);//Función de OpenZeppelin que crea el NFT y lo asigna a la dirección recipient.
        _setTokenURI(newItemId, tokenURI);//Asocia la URI proporcionada con el nuevo NFT.
        tokenCounter += 1;//Se incrementa en 1 para preparar el siguiente ID de NFT.
        return newItemId;//Devuelve el ID del nuevo NFT.
    }
}