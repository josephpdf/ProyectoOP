// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./CommerceNFTCollection.sol";

contract BrandAmbassadorCollection is ERC721URIStorage, Ownable {
    uint256 public tokenCounter;//Mantiene el número total de NFTs que se han minteado en esta colección.
    address public commerceNFTAddress;//Almacena la dirección del contrato CommerceNFTCollection. Se usa para interactuar con la colección de NFTs del comercio.
    mapping(address => uint256[]) public ambassadorTransactions;//Mapping que asocia cada dirección de embajador con una lista de IDs de NFTs que han recibido.

    event BrandAmbassadorMinted(address indexed ambassador, uint256 indexed commerceNFTId, uint256 newTokenId, string tokenURI);//Evento que se emite cuando se mintea un nuevo NFT para un embajador. Incluye la dirección del embajador, el ID del NFT del comercio, el nuevo ID del NFT, y la URI del token.

    constructor(address _commerceNFTAddress) ERC721("BrandAmbassadorCollection", "BAC") {
        tokenCounter = 0;
        commerceNFTAddress = _commerceNFTAddress;
    }

    function mintAmbassadorNFT(address ambassador/*La dirección del embajador que recibirá el nuevo NFT.*/, uint256 commerceNFTId/*El ID del NFT de la colección del comercio relacionado con este nuevo NFT.*/, string memory tokenURI/*La URI del token*/) public onlyOwner/*Modificador que asegura que solo el propietario del contrato pueda ejecutar esta función.*/ returns (uint256) {
        //Esta función permite al propietario del contrato mintear un NFT para un embajador de marca.
        uint256 newItemId = tokenCounter;//Asigna el valor actual de tokenCounter como el ID del nuevo NFT.
        _safeMint(ambassador, newItemId);//Crea el NFT y lo asigna a la dirección ambassador.
        _setTokenURI(newItemId, tokenURI);//Asocia la URI proporcionada con el nuevo NFT.
        tokenCounter += 1;//Se incrementa en 1.
        
        ambassadorTransactions[ambassador].push(newItemId);//Agrega el ID del nuevo NFT a la lista de transacciones del embajador.

        emit BrandAmbassadorMinted(ambassador, commerceNFTId, newItemId, tokenURI);//Emite un evento para registrar que se ha minteado un nuevo NFT para el embajador.

        return newItemId;
    }

    function generateAmbassadorNFTs(address ambassador/*La dirección del embajador.*/) public onlyOwner/*Modificador que asegura que solo el propietario del contrato pueda ejecutar esta función.*/ {
        //Esta función genera NFTs para un embajador basado en la colección del comercio.
        CommerceNFTCollection commerceNFT = CommerceNFTCollection(commerceNFTAddress);//Crea una instancia del contrato CommerceNFTCollection utilizando la dirección almacenada.
        uint256 totalNFTs = commerceNFT.tokenCounter();//Obtiene el número total de NFTs en la colección del comercio.

        for (uint256 i = 0; i < totalNFTs; i++) {//Itera sobre cada NFT de la colección del comercio.
            string memory tokenURI = commerceNFT.tokenURI(i);//Obtiene la URI del token del comercio.
            string memory deepLinkTokenURI = string(abi.encodePacked(tokenURI, "?ambassador=", toAsciiString(ambassador), "&commerceNFTId=", uint2str(i)));//Crea un deep link URI que incluye la dirección del embajador y el ID del NFT del comercio.
            mintAmbassadorNFT(ambassador, i, deepLinkTokenURI);//Mintea un nuevo NFT para el embajador usando el deep link URI.
        }
    }

    function toAsciiString(address x) internal pure returns (string memory) {
        //Convierte una dirección de Ethereum a su representación ASCII.
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        //Convierte un byte a su representación de carácter ASCII.
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function uint2str(uint _i) internal pure returns (string memory str) {
        //Convierte un número entero en su representación de cadena de caracteres.
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        str = string(bstr);
    }
}