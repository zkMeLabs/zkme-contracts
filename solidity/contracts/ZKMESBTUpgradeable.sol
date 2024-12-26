// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./KycData/KYCDataLib.sol";
import "./KycData/IKYCDataReadable.sol";
import "./interfaces/IERC721MetadataUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/interfaces/IERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * An experiment in zkMe Soul Bound Tokens (ZKMESBT's)
 */
contract ZKMESBTUpgradeable is
Initializable,
AccessControlUpgradeable,
IKYCDataReadable,
IERC721MetadataUpgradeable
{
    using StringsUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.AddressToUintMap;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.UintToAddressMap;

    EnumerableMapUpgradeable.UintToAddressMap private _ownerMap;
    EnumerableMapUpgradeable.AddressToUintMap private _tokenMap;

    CountersUpgradeable.Counter private _tokenId;

    string public name;
    string public symbol;
    string private _baseTokenURI;

    mapping(uint => KYCDataLib.UserData) private _kycMap;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function initialize(
        string memory name_,
        string memory symbol_,
        address admin_
    ) public reinitializer(1) {
        name = name_;
        symbol = symbol_;

        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
        _grantRole(OPERATOR_ROLE, admin_);
    }

    /**
    * @dev attest of ZkMe contract
     *   attest user with sbt
     */

    function attest(
        address to
    ) public onlyRole(OPERATOR_ROLE) returns (uint256) {
        return _attest(to);
    }

    function _attest(
        address to
    ) public onlyRole(OPERATOR_ROLE) returns (uint256) {
        require(to != address(0), "Empty address is not allowed");
        require(!_tokenMap.contains(to), "zkMeSBT already exists");

        _tokenId.increment();
        uint256 tokenId = _tokenId.current();

        bool tokenSet = _tokenMap.set(to, tokenId);
        require(tokenSet, "_tokenMap.set error");
        bool ownerMapSet = _ownerMap.set(tokenId, to);
        require(ownerMapSet, "_ownerMap.set error");

        emit Attest(to, tokenId);
        emit Transfer(address(0), to, tokenId);

        return tokenId;
    }
    /**
    * @dev attest of ZkMe contract
     *   batch attest users with sbts
     */
    function batchAttest(
        address[] calldata to
    ) external onlyRole(OPERATOR_ROLE) returns (uint256[] memory){
        uint256[] memory tokenIds = new uint256[](to.length);
        for (uint i = 0; i < to.length; i++) {
            tokenIds[i] = _attest(to[i]);
        }
        return tokenIds;
    }

    /**
    * @dev attest of ZkMe contract
     *   revoke single user's  sbts
     */
    function revoke(
        address from,
        uint256 tokenId
    ) external onlyRole(OPERATOR_ROLE) {
        require(from != address(0), "Empty address is not allowed");
        require(
            _tokenMap.contains(from),
            "The account does not have the zkMeSBT"
        );

        bool tokenRemove = _tokenMap.remove(from);
        require(tokenRemove, "_tokenMap.remove error");
        bool ownerRemove = _ownerMap.remove(tokenId);
        require(ownerRemove, "_ownerMap.remove error");

        emit Revoke(from, tokenId);
        emit Transfer(from, address(0), tokenId);
    }

    // we do not delete and remove data right here, since we need store data for 5 years and delete them manually
    function burn(uint256 tokenId) external {
        address sender = _msgSender();
        require(_ownerOf(tokenId)==sender, "The account must be owner itself");

        require(
            _tokenMap.contains(sender),
            "The account does not have the zkMeSBT"
        );

        bool tokenRemove = _tokenMap.remove(sender);
        require(tokenRemove, "_tokenMap.remove error");
        bool ownerRemove  = _ownerMap.remove(tokenId);
        require(ownerRemove, "_ownerMap.remove error");

        emit Burn(sender, tokenId);
        emit Transfer(sender, address(0), tokenId);
    }

    // if user burn their sbt and it through 5 years, we can use this function to remove rebundent data.
    function deleteExpire(uint256 tokenId) external onlyRole(OPERATOR_ROLE) {
        delete _kycMap[tokenId];
    }

    /**
    * @dev attest of ZkMe contract
     *   get user's sbt data
     */
    function getKycData(
        uint256 tokenId
    ) public view returns (KYCDataLib.UserData memory) {
        require(_ownerMap.contains(tokenId), "The zkMeSBT does not exist");

        return _kycMap[tokenId];
    }

    /**
    * deprecated
    * @dev attest of ZkMe contract
     *   set user's sbt data
     */

    function setKycData(
        uint256 tokenId,
        string calldata key,
        uint256 validity,
        string calldata data,
        string[] calldata questions
    ) public onlyRole(OPERATOR_ROLE) {
        require(_ownerMap.contains(tokenId), "The zkMeSBT does not exist");
        require(
            validity > block.timestamp,
            "The expiration date is too closed"
        );
        if (bytes(_kycMap[tokenId].key).length != 0) {
            require(
                keccak256(bytes(_kycMap[tokenId].key)) == keccak256(bytes(key)),
                "Dismatched user key"
            );
        }

        _setKycData(tokenId, key, validity, data, questions);
    }

    function _setKycData(
        uint256 tokenId,
        string calldata key,
        uint256 validity,
        string calldata data,
        string[] calldata questions
    ) internal {
        _kycMap[tokenId] = KYCDataLib.UserData(key, validity, data, questions);
    }

    /**
   * deprecated
   * @dev attest of ZkMe contract
     *   batch set users sbts data
     */

    function setKycDataBatch(KYCDataLib.KycData[] calldata kycDataArray) public onlyRole(OPERATOR_ROLE)  {
        for (uint i = 0; i < kycDataArray.length; i++) {
            if(!_ownerMap.contains(kycDataArray[i].tokenId)){
                continue;
            }
            if(kycDataArray[i].validity <= block.timestamp){
                continue;
            }
            _setKycData(kycDataArray[i].tokenId, kycDataArray[i].key, kycDataArray[i].validity, kycDataArray[i].data, kycDataArray[i].questions);
        }
    }

    /**
   * @dev attest of ZkMe contract
     *   combined attest and set data for batch user
     * in order to improve the speed of mint
     */


    function mintSbt(KYCDataLib.MintData[] calldata mintDataArray) public{
        require(hasRole(OPERATOR_ROLE, _msgSender()), "no auth user for caller");
        require(mintDataArray.length <= 5, "mintDataArray size is larger than 5");
        unchecked{
            for (uint i = 0; i < mintDataArray.length; i++){
                uint256 tokenId = _attestMint(mintDataArray[i].to);
                if(!_tokenMap.contains(mintDataArray[i].to)){
                    continue;
                }
                if(mintDataArray[i].validity <= block.timestamp){
                    continue;
                }
                if (bytes(_kycMap[tokenId].key).length != 0) {
                    require(
                        keccak256(bytes(_kycMap[tokenId].key)) == keccak256(bytes(mintDataArray[i].key)),
                        "Dismatched user key"
                    );
                }
                _setKycData(tokenId, mintDataArray[i].key, mintDataArray[i].validity, mintDataArray[i].data, mintDataArray[i].questions);
            }
        }
    }





    function _attestMint(
        address to
    ) internal returns (uint256) {
        require(to != address(0), "Empty address is not allowed");
        require(!_tokenMap.contains(to), "zkMeSBT already exists");

        _tokenId.increment();
        uint256 tokenId = _tokenId.current();

        bool tokenSet = _tokenMap.set(to, tokenId);
        require(tokenSet, "_tokenMap.set error");
        bool ownerMapSet = _ownerMap.set(tokenId, to);
        require(ownerMapSet, "_ownerMap.set error");

        emit Attest(to, tokenId);
        emit Transfer(address(0), to, tokenId);

        return tokenId;
    }




    /**
     * @dev Update _baseTokenURI
     */
    function setBaseTokenURI(
        string calldata uri
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _baseTokenURI = uri;
    }

    // old version maintains, set a new function to do so
    //deprecated
    function balanceOf(
        address owner
    ) external view override(IZKMESBT721Upgradeable) returns (uint256) {
        (bool success, ) = _tokenMap.tryGet(owner);
        return success ? 1 : 0;
    }

    /**
    * @dev judge the owner's token if it is exist
     */
    function isBalancePass(
        address owner
    ) external view override(IZKMESBT721Upgradeable) returns (uint256) {
        (bool success, ) = _tokenMap.tryGet(owner);
        return success ? 1 : 0;
    }

    /**
    * @dev get the owner's token id by single
     */

    function tokenIdOf(address from) external view returns (uint256) {
        return _tokenMap.get(from, "The address does not have any zkMeSBT");
    }


    /**
    * @dev get the owner's token ids by batch
     */

    function batchTokenIdsOf(address[] calldata from) external view returns (uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](from.length);
        for (uint i = 0; i < from.length; i++) {
            (bool success,uint256 tokenId) = _tokenMap.tryGet(from[i]);
            if(success){
                tokenIds[i] = tokenId;
            }else{
                tokenIds[i] = 0;
            }
        }
        return tokenIds;
    }

    /**
    * @dev judge sender if it is token's owner
     */

    function ownerOf(
        uint256 tokenId
    ) external view override(IZKMESBT721Upgradeable) returns (address) {
        return _ownerMap.get(tokenId, "Invalid tokenId");
    }

    function _ownerOf(
        uint256 tokenId
    ) public view returns (address) {
        return _ownerMap.get(tokenId, "Invalid tokenId");
    }
    /**
    * @dev get all current sbt count
     */
    function totalSupply() external view override returns (uint256) {
        return _tokenId.current();
    }

    function isOperator(address account) external view returns (bool) {
        return hasRole(OPERATOR_ROLE, account);
    }

    function isAdmin(address account) external view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     *
     */
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return
            bytes(_baseTokenURI).length > 0
                ? string(abi.encodePacked(_baseTokenURI, tokenId.toString()))
                : "";
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    )
    public
    view
    virtual
    override(AccessControlUpgradeable, IERC165Upgradeable)
    returns (bool)
    {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

}
