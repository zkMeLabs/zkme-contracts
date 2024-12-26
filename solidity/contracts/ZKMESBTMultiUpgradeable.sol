// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./KycData/KYCDataLib.sol";
import "./KycData/IKYCDataReadable.sol";
import "./interfaces/IERC721MultiMetadataUpgradeable.sol";
import "./interfaces/IZKMESBT721Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/interfaces/IERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./interfaces/IZKMESBTMultiUpgradeable.sol";

/**
 * An experiment in zkMe Soul Bound Tokens (ZKMESBT's)
 * it is for expansion of the original one, now it is implemented on polygon to support
 * not only kyc data but also other's credit score etc.
 *if the category is kyc, this contract will call the kyc one to mint, else it will mint by itself.
 */
contract ZKMESBTMultiUpgradeable is
Initializable,
AccessControlUpgradeable,
IKYCDataReadable,
IERC721MetadataUpgradeable
{
    using StringsUpgradeable for uint256;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.UintToAddressMap;

    EnumerableMapUpgradeable.UintToAddressMap private _ownerMap;


    mapping(address => mapping(uint256 => uint256)) private _tokenMultiMap;

    uint256 private _tokenId;

    string public name;
    string public symbol;
    string private _baseTokenURI;
    address private _sbt_contract;
    uint256 public constant KYC_MINT = 1;

    mapping(uint => KYCDataLib.UserMultiData) private _kycMap;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function initialize(
        string memory name_,
        string memory symbol_,
        address admin_,
        address sbt_contract_
    ) public reinitializer(1) {
        name = name_;
        symbol = symbol_;

        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
        _grantRole(OPERATOR_ROLE, admin_);
        _tokenId = uint256(1000000000);

        require(sbt_contract_ != address(0),"sbt_contract_ can not be 0");
        _sbt_contract = sbt_contract_;
    }

    function attest(
        address to,
        uint256 category
    ) public onlyRole(OPERATOR_ROLE)  returns (uint256) {
//        if(category == uint256(0)){
//            IZKMESBT721Upgradeable.attest(to);
//        }
        return _attest(to,category);
    }

    function _attest(
        address to,
        uint256 category
    ) public onlyRole(OPERATOR_ROLE) returns (uint256) {
        require(to != address(0), "Empty address is not allowed");
        require(
            _tokenMultiMap[to][category] == uint256(0),
            "The account does not have the zkMeSBT"
        );

        _tokenId+= 1;
        uint256 tokenId = _tokenId;

        bool ownerMapSet = _ownerMap.set(tokenId, to);
        require(ownerMapSet, "_ownerMap.set error");

        _tokenMultiMap[to][category] = tokenId;

        emit Attest(to, tokenId);
        emit Transfer(address(0), to, tokenId);

        return tokenId;
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
        uint256 category = _kycMap[tokenId].category;
        if(category == KYC_MINT){
            try IZKMESBT721Upgradeable(_sbt_contract).revoke(from,tokenId){
            }catch{
                return;
            }
        }else{
            require(
                _tokenMultiMap[from][category] != uint256(0),
                "The account does not have the zkMeSBT"
            );

            _tokenMultiMap[from][category] = uint256(0);
            bool ownerRemove = _ownerMap.remove(tokenId);
            require(ownerRemove, "_ownerMap.remove error");
        }

        emit Revoke(from, tokenId);
        emit Transfer(from, address(0), tokenId);
    }

    // we do not delete and remove data right here, since we need store data for 5 years and delete them manually
    function burn(uint256 tokenId) external { //调用外部
        address sender = _msgSender();
        require(_ownerOf(tokenId)==sender, "The account must be owner itself");
        uint256 category = _kycMap[tokenId].category;
        if(category == KYC_MINT){
            try IZKMESBT721Upgradeable(_sbt_contract).revoke(sender,tokenId){
            }catch{
                return;
            }
            return;
        }

//        require(
//            _tokenMap.contains(sender),
//            "The account does not have the zkMeSBT"
//        );

        require(
            _tokenMultiMap[sender][category] != uint256(0),
            "The account does not have the zkMeSBT"
        );

        _tokenMultiMap[sender][category] = uint256(0);
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
        KYCDataLib.UserMultiData memory multiData =  _kycMap[tokenId];
        KYCDataLib.UserData  memory userData = KYCDataLib.UserData(multiData.key,multiData.validity,multiData.data,multiData.questions);
        return userData;
    }

/**
    * @dev attest of ZkMe contract
     *   get user's sbt data by different contract
     */
    function getSbtData(
        uint256 tokenId
    ) public view returns (KYCDataLib.UserMultiData memory) {
        if(!_ownerMap.contains(tokenId)){
            KYCDataLib.UserData memory userData = IKYCDataReadable(_sbt_contract).getKycData(tokenId);
            KYCDataLib.UserMultiData memory multiData = KYCDataLib.UserMultiData(userData.key, KYC_MINT, userData.validity, userData.data, userData.questions);
            return multiData;
        }
        require(_ownerMap.contains(tokenId), "The zkMeSBT does not exist");
        KYCDataLib.UserMultiData memory multiData =  _kycMap[tokenId];
        return multiData;
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
        if(!_ownerMap.contains(tokenId)){
            try IZKMESBT721Upgradeable(_sbt_contract).setKycData(tokenId,key,validity,data,questions){
            }catch{
            }
            return;
        }
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
        uint256 category = _kycMap[tokenId].category;
        _setKycData(tokenId,category, key, validity, data, questions);
    }

    function _setKycData(
        uint256 tokenId,
        uint256 category,
        string calldata key,
        uint256 validity,
        string calldata data,
        string[] calldata questions
    ) internal {
        _kycMap[tokenId] = KYCDataLib.UserMultiData(key, category, validity, data, questions);
    }



    /**
      * @dev attest of ZkMe contract
     *   combined attest and set data for batch user
     * in order to improve the speed of mint
     * and it distributes mint process by category
     */
    function mintSbt(KYCDataLib.MultiMintData[] calldata mintDataArray) public{
        require(hasRole(OPERATOR_ROLE, _msgSender()), "no auth user for caller");
        require(mintDataArray.length <= 5, "mintDataArray size is larger than 5");
        unchecked{
            for (uint i = 0; i < mintDataArray.length; i++){
                if((mintDataArray[i].category == KYC_MINT)){
                    KYCDataLib.MintData memory   mintData = KYCDataLib.MintData(mintDataArray[i].to, mintDataArray[i].key, mintDataArray[i].validity, mintDataArray[i].data, mintDataArray[i].questions);
                    KYCDataLib.MintData[] memory mintSbtArray = new KYCDataLib.MintData[](1);
                    mintSbtArray[0] = mintData;
                    try IZKMESBT721Upgradeable(_sbt_contract).mintSbt(mintSbtArray){
                    }catch(bytes memory err){
                        emit ErrorHandle(err);
                        continue;
                    }
                }else{
                    uint256 tokenId = _attestMint(mintDataArray[i].to, mintDataArray[i].category);
                    if(_tokenMultiMap[mintDataArray[i].to][mintDataArray[i].category] == uint256(0)){
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
                    _setKycData(tokenId, mintDataArray[i].category ,mintDataArray[i].key ,mintDataArray[i].validity, mintDataArray[i].data, mintDataArray[i].questions);
                }
            }
        }
    }





    function _attestMint(
        address to,
        uint256 category
    ) internal returns (uint256) {
        require(
            _tokenMultiMap[to][category] == uint256(0),
            "The account does not have the zkMeSBT"
        );

        _tokenId += 1;
        uint256 tokenId = _tokenId;


        bool ownerMapSet = _ownerMap.set(tokenId, to);
        require(ownerMapSet, "_ownerMap.set error");

        _tokenMultiMap[to][category] = tokenId;

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
    ) external view override(IZKMESBTMultiUpgradeable ) returns (uint256) {
        return  0;
    }
    // old version maintains, set a new function to do so
    //deprecated
    function isBalancePass(
        address owner,
        uint256 category
    ) external view override(IZKMESBTMultiUpgradeable)  returns (uint256) {
        if(category == KYC_MINT){
            return IZKMESBT721Upgradeable(_sbt_contract).isBalancePass(owner);
        }
        return _tokenMultiMap[owner][category] != uint256(0) ? 1: 0;
    }

    function tokenIdOf(address from,uint256 category) external view override(IZKMESBTMultiUpgradeable ) returns (uint256) {
        if(category == KYC_MINT && _tokenMultiMap[from][category] == uint256(0)){
            uint256 tokenId = IZKMESBT721Upgradeable(_sbt_contract).tokenIdOf(from);
            require(tokenId != uint256(0), "sbtContract tokenId illegal");
            return tokenId;
        }
        require(_tokenMultiMap[from][category] != uint256(0),"The address does not have any zkMeSBT");
        return _tokenMultiMap[from][category];
    }

    function batchTokenIdsOf(KYCDataLib.getTokenIdStruct[] calldata getTokenIdList) external view returns (uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](getTokenIdList.length);
        for (uint i = 0; i < getTokenIdList.length; i++) {
            if(getTokenIdList[i].category == KYC_MINT && _tokenMultiMap[getTokenIdList[i].addr][getTokenIdList[i].category] == uint256(0)){
                uint256 tokenId = uint256(0);
                try IZKMESBT721Upgradeable(_sbt_contract).tokenIdOf(getTokenIdList[i].addr) returns(uint256 _token){
                    tokenId = _token;
                }
                catch{}
                tokenIds[i] = tokenId;
            }else{
                tokenIds[i] =  _tokenMultiMap[getTokenIdList[i].addr][getTokenIdList[i].category];
            }
        }
        return tokenIds;
    }

    function ownerOf(
        uint256 tokenId
    ) external view  returns (address) {
        return _ownerMap.get(tokenId, "Invalid tokenId");
    }

    function _ownerOf(
        uint256 tokenId
    ) public view returns (address) {
        return _ownerMap.get(tokenId, "Invalid tokenId");
    }

    function totalSupply() external view returns (uint256) {
        return _tokenId;
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
