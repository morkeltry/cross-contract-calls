pragma solidity ^0.5.0;

import "./strings.sol";
import "./stringCasting.sol";
// import "./BytesLib.sol";


/* empty contract - the real one is depolyed at an address which will be passed as param to validate */

// contract Poll {
//     function serialiseStakers(string calldata _poll, uint8 validationType) external returns (address[] memory) {
//         // return something which will make it obvious that you have accidentally delegated this context!
//         address[] memory ret = new address[](3);
//         (ret[0], ret[1], ret[2]) = (address(9), address(9), address(9));
//         return ret;
//
//     }
//
//     function serialiseProofs(string calldata _poll, uint8 validationType) external returns (address[] memory) {
//         // return something which will make it obvious that you have accidentally delegated this context!
//         address[] memory ret = new address[](4);
//         (ret[0], ret[1], ret[2], ret[3]) = (address(6), address(6), address(6), address(6));
//         return ret;
//     }
// }


/* Lunchcoin validator contract - mutual agreement */
contract MutualAgreement {
    address owner;  // is set by TokenStorage.

    // allTheData must occupy the same slot as in Poll contract, ie second slot, slot 1.
    mapping (bytes32 => bytes32[]) allTheData;
    // resultsCache must occupy the same slot as in Poll contract, ie fourth slot, slot 3.
    mapping (bytes32 => bool) resultsCache;

    uint256 notes = 130;
    int8 constructed = -1;

    using strings for *;
    using stringcast for string;

    uint8 constant vType=1;
    string constant vDesc = "mutual agreement";
    address pollAddress = 0x9D26a8a5Db7dC10689692caF8d52C912958409CF;

    struct proofCounter {
        bool fakeProof;
        int8 duplicateProofs;
        uint8 fakeProofs;
        bool senderIsPresent;
    }

    function () payable external {
        _fallback();
    }

    // function() external payable {
    //     // NB sol 0.6+ better syntax for calldata arrays : https://solidity.readthedocs.io/en/v0.6.0/types.html#array-slices
    //     bytes memory input = msg.data;
    //
    //     // TODO: This is V.0 accepting a string (really a bytes32) of EXACTLY 32 bytes, eg a doodle poll without the https:// ;)
    //     bytes32 __ownAdress;  // NB assuming 32b rather than 20b for calldata loose packing. Remember to get rid of this line when optimising!
    //     bytes memory usefulData;
    //     bytes32 poll32;
    //     bytes memory __reveal;
    //     // demo result! (we don;t need more than bool really ;)
    //     uint256 valid = 7331;
    //
    //     (__ownAdress, usefulData) = (bytesSplit32(input));
    //     (poll32, __reveal) = (bytesSplit32(usefulData));
    //
    //     // NB other validators will need to additionally retrieve reveal data from msg.data
    //     bytes32[] memory stakers = crossContractCall (encodeFunctionName("serialiseStakers"), bytes32ToString(poll32), valid, vType);
    //     bytes32[] memory proofs = crossContractCall (encodeFunctionName("serialiseProofs"), bytes32ToString(poll32), valid, vType);
    //
    // }

    constructor () public {
        constructed = 1;
    }

    function _fallback() internal {
        bytes memory input = msg.data;


    }
    //
    // function getMaOK() public view returns (uint8) {
    //   return ok;
    // }
    //
    // function setMaOK (uint8 _ok) public {
    //   ok = _ok;
    // }
    //
    // function getMaResult() public view returns (uint8) {
    //   return result;
    // }
    //
    // function setMaResult (uint8 _result) public {
    //   result = _result;
    // }
    //
    // function getMyMap(uint idx) public view returns (uint) {
    //   return myMap[idx];
    // }
    //
    // function setMyMap (uint idx, uint _myMap) public {
    //   myMap[idx] = _myMap;
    // }

    // function getOwner() public view returns (address) {
    //   return owner;
    // }
    //
    // event pollAddressSet();
    // function setPollAddress (address newAddy) public returns (bool) {
    //     pollAddress = newAddy;
    //     emit pollAddressSet();
    //     return true;
    // }
    //
    // function getPollAddress () public view returns (address) {
    //     return pollAddress;
    // }
    //
    // function getStateVars () public view returns (uint256, uint8, string memory, address, int8) {
    //     return (notes, vType, vDesc, pollAddress, constructed);
    // }

    // event RetrievedDataCache(string, uint256, bytes32[]);
    function retrieve (string memory _poll, string memory _fnName, uint8 _vt) public view returns (bytes32[] memory) {
        bytes32 hash = keccak256(abi.encodePacked(_poll, encodeFunctionName(_fnName), _vt));
        // emit RetrievedDataCache("Poll context:", notes, allTheData[hash]);
        return (allTheData[hash]);
    }

    function set (string memory _poll, string memory _fnName, uint8 _vt, bytes32[] memory data) public {
      bytes32 hash = keccak256(abi.encodePacked(_poll, encodeFunctionName(_fnName), _vt));
      // emit RetrievedDataCache("Poll context:", notes, allTheData[hash]);
      allTheData[hash] = data;
    }


    /* simplest possible validator - checks that a majority of poll.stakers(), including sender, are contained in poll.serialiseProofs() */
    function validate(address _pollContract, string memory _poll, bytes32 _reveal) public view returns (bool success) {
        // bytes32[] memory stakersData = crossContractCall( encodeFunctionName("serialiseStakers") , _poll, vType);
        // bytes32[] memory proofsData = crossContractCall( encodeFunctionName("serialiseProofs") , _poll, vType);
        // bytes32[] memory thresholdData =  crossContractCall( encodeFunctionName("threshold") , _poll, vType);

        // address[] memory stakers = splitToAddresses( bytes32ArrayToString(stakersData).toSlice());
        // address[] memory proofs = splitToAddresses( bytes32ArrayToString(proofsData).toSlice());
        // uint8 threshold = uint8(bytes32ToUint(thresholdData[0]));


        // bytes32[] memory stakersData = crossContractCall( encodeFunctionName("serialiseStakers") , _poll, vType);
        // bytes32[] memory proofsData = crossContractCall( encodeFunctionName("serialiseProofs") , _poll, vType);
        // bytes32[] memory thresholdData =  crossContractCall( encodeFunctionName("threshold") , _poll, vType);
        bytes32[] memory rawStakers = retrieve(_poll, "serialiseStakers", vType);
        bytes32[] memory rawProofs = retrieve(_poll, "serialiseProofs", vType);

        address[] memory stakers = splitToAddresses( bytes32ArrayToString(rawStakers));
        address[] memory proofs = splitToAddresses( bytes32ArrayToString(rawProofs));
        uint8 threshold = 3;

        proofCounter memory pc;

        for(uint i = 0; i < proofs.length; i++) {
            pc.duplicateProofs = -1;
            for(uint j = 0; i < stakers.length; i++) {
                if (proofs[i] == stakers[j]) {
                    // Only set senderIsPresent = true the first time that proofs[i] == stakers[j] == msg.sender
                    if (proofs[i] == msg.sender) { pc.senderIsPresent = true; }
                    // set duplicateProofs hopefully to 0, and remove staker from the array
                    pc.duplicateProofs++;
                    stakers[j] = address(0);
                }
            }
            if (pc.duplicateProofs>0) { pc.fakeProofs += uint8(pc.duplicateProofs); }
        }

        // // deal with 0 < threshold < 1
        // if(percentageThreshold>0) {
        //   threshold = percentageThreshold*stakers.length;
        // }
        if (pc.senderIsPresent && proofs.length-pc.fakeProofs >= threshold) {
            return true;
        }
    }

    function serialiseStakers(string calldata _poll, uint8 validationType) external pure returns (address[] memory) {
        // return something which will make it obvious that you have accidentally delegated this context!
        address[] memory ret = new address[](4);
        (ret[0], ret[1], ret[2], ret[3]) = (address(5), address(0), address(5), address(0));
        return ret;
    }

    function serialiseProofs(string calldata _poll, uint8 validationType) external pure returns (address[] memory) {
        // return something which will make it obvious that you have accidentally delegated this context!
        address[] memory ret = new address[](4);
        (ret[0], ret[1], ret[2], ret[3]) = (address(0), address(5), address(0), address(5));
        return ret;
    }


    function proofType() public pure returns (uint8) {
      return vType;
    }

    function encodeFunctionName (string memory name) internal pure returns (bytes4) {
        // TODO: cache for readability!
        // if ("serialiseStakers")
        //     return
        // if ("serialiseStakers")
        //     return
        return bytes4(keccak256(bytes(name)));
    }

    // split a serialised string of addresses (as received from main contract).
    // NB - only works in this validator - other validators will use multiple types within serialised string
    function splitToAddresses(string memory _concatenated) internal pure returns (address[] memory result) {
        strings.slice memory delim = ",".toSlice();
        strings.slice memory source = _concatenated.toSlice();
        address[] memory parts = new address[](source.count(delim));

        for(uint i = 0; i < parts.length; i++) {
           parts[i] = source.split(delim).toString().toAddress();
        }
        return parts;

    }

    function toString(address account) public pure returns(string memory) {
        return toString(abi.encodePacked(account), 5);
    }

    function toString(uint256 value) public pure returns(string memory) {
        return toString(abi.encodePacked(value), 0);
    }

    function toString(bytes32 value) public pure returns(string memory) {
        return toString(abi.encodePacked(value), 0);
    }

    function toString(bytes memory data, uint16 len) public pure returns(string memory) {
        bytes memory alphabet = "0123456789abcdef";
        uint16 strLen = 20;  // It's 20. The length is just fucking 20.  uint16(data.length);
        // Pretty simple if statement - why won't it work ?
        // if (len>0) {
        //     strLen = len;
        // }


        bytes memory str = new bytes(2 + strLen * 2);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < strLen; i++) {
            str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }


    function bytes32ToBytes(bytes32 _bytes32) public pure returns (bytes memory){
        // string memory str = string(_bytes32);
        // TypeError: Explicit type conversion not allowed from "bytes32" to "string storage pointer"
        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return bytesArray;
    }

    // function bytesToBytes32(bytes b, uint offset) private pure returns (bytes32) {
    //     bytes32 out;

    //     for (uint i = 0; i < 32; i++) {
    //         out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
    //     }~/randomCode/truffletings/proxyBox
    //     return out;
    // }


    function bytesToBytes32(bytes memory b) public pure returns (bytes32 bts) {
        bytes32 i;
        //NB size etc= 32b = 0x20b
        assembly { i := mload(add(b, 0x20)) }
        bts = i;
    }

    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory ){
        bytes memory bytesArray = bytes32ToBytes(_bytes32);
        return string(bytesArray);
    }

    function bytes32ArrayToString (bytes32[] memory data) public pure returns (string memory ) {
        bytes memory bytesString = new bytes(data.length * 32);
        uint urlLength;
        uint i=0;
        for (i=0; i<data.length; i++) {
            for (uint j=0; j<32; j++) {
                byte char = byte(bytes32(uint(data[i]) * 2 ** (8 * j)));
                if (char != 0) {
                    bytesString[urlLength] = char;
                    urlLength += 1;
                }
            }
        }
        bytes memory bytesStringTrimmed = new bytes(urlLength);
        for (i=0; i<urlLength; i++) {
            bytesStringTrimmed[i] = bytesString[i];
        }
        return string(bytesStringTrimmed);
    }

    // TODO !!!
    // function bytes32ToUint (bytes32 data) returns (uint) {
    //     return 2;
    // }

    function bytesSplit32(bytes  memory data) public pure returns (bytes32, bytes memory ) {
        uint8 splitAt = 32;                             // all (if variable split, pass in splitAt)
        uint256 taillength = 0;
        if (data.length > splitAt)
            taillength = data.length-splitAt;
        bytes32 temp;
        // bytes32 head;                                   // 32b split
        bytes memory head = new bytes(splitAt);         // variable length split
        bytes memory tail = new bytes(taillength);
        for(uint i=0;i<=data.length-1;i++){
            if (i<splitAt)
                head[i] = bytes(data)[i] ;
            else
                tail[i-splitAt] = bytes(data)[i] ;
        }
        return (bytesToBytes32(head), tail);
    }

    // calls fallback function of pollAddress, passing 4 byte encoded function name to remote contract to select method.
    // NB future better: just get the ABI of the finished Poll conmtract, and use that!
    // NB in sol 0.6 + fallback cannot return anything
    // NB future optimisation : we are not using the functionality of string here, since string must have come from a bytes32
    event CrossContractValidateBegin();
    event CrossContractValidateEnd();
    function crossContractCall (bytes4 fnNameHash, string  memory poll, uint256 valid, uint8 vt) public returns (bytes32[] memory) {
    address pollContract = pollAddress;

        emit CrossContractValidateBegin();
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, pollContract, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
        emit CrossContractValidateEnd();
    }

}
