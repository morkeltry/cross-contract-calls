pragma solidity >=0.4.21 <0.6.0;

library stringcast{

    function toLower(string memory str) pure internal returns (string memory) {
		bytes memory bStr = bytes(str);
		bytes memory bLower = new bytes(bStr.length);
		for (uint i = 0; i < bStr.length; i++) {
			if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
				bLower[i] = byte(uint8(bStr[i]) + 32);
			} else {
				bLower[i] = bStr[i];
			}
		}
		return string(bLower);
    }

    function toUpper(string memory str) pure internal returns (string memory) {
		bytes memory bStr = bytes(str);
		bytes memory bUpper = new bytes(bStr.length);
		for (uint i = 0; i < bStr.length; i++) {
			if ((uint8(bStr[i]) >= 97) && (uint8(bStr[i]) <= 122)) {
				bUpper[i] = byte(uint8(bStr[i]) - 32);
			} else {
				bUpper[i] = bStr[i];
			}
		}
		return string(bUpper);
    }

    function toAddress(string memory self) pure internal returns (address){
        bytes memory tmp = bytes(self);

        uint addr = 0;
        uint8 b;
        uint8 b2;

        for (uint i=2; i<2+2*20; i+=2){

            addr *= 256;

            b = uint8(tmp[i]);
            b2 = uint8(tmp[i+1]);

            if ((uint8(b) >= 97)&&(uint8(b) <= 102)) b -= 87;
            else if ((uint8(b) >= 48)&&(uint8(b) <= 57)) b -= 48;
            else if ((uint8(b) >= 65)&&(uint8(b) <= 70)) b -= 55;

            if ((uint8(b2) >= 97)&&(uint8(b2) <= 102)) b2 -= 87;
            else if ((uint8(b2) >= 48)&&(uint8(b2) <= 57)) b2 -= 48;
            else if ((uint8(b2) >= 65)&&(uint8(b2) <= 70)) b2 -= 55;

            addr += (b*16+b2);

        }

        return address(addr);
    }

    function stringToAddress(string memory str) pure internal returns (address){
        bytes memory tmp = bytes(str);

        uint160 addr = 0;
        uint160 b;
        uint160 b2;

        for (uint i=2; i<2+2*20; i+=2){

            addr *= 256;

            b = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i+1]));

            if ((uint8(b) >= 97)&&(uint8(b) <= 102)) b -= 87;
            else if ((uint8(b) >= 48)&&(uint8(b) <= 57)) b -= 48;
            else if ((uint8(b) >= 65)&&(uint8(b) <= 70)) b -= 55;

            if ((b2 >= 97)&&(uint8(b2) <= 102)) b2 -= 87;
            else if ((uint8(b2) >= 48)&&(uint8(b2) <= 57)) b2 -= 48;
            else if ((uint8(b2) >= 65)&&(uint8(b2) <= 70)) b2 -= 55;

            addr += (b*16+b2);

        }

        return address(addr);
    }

    function toUint(string memory self) pure internal returns (uint result) {
        bytes memory b = bytes(self);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }

    //important -> hex string to bytes
    function toBytes(string memory self) pure internal returns (bytes memory)
    {
        bytes memory bArray = new bytes((bytes(self).length-2)/2);

        uint8 b;
        uint8 b1;

        for (uint i=2;i<bytes(self).length;i+=2)
        {
            b = uint8(bytes(self)[i]);
            b1 = uint8(bytes(self)[i+1]);

            //left digit
            if(b>=48 && b<=57)
                b -= 48;
            //A-F
            else if(b>=65 && b<=70)
                b -= 55;
            //a-f
            else if(b>=97 && b<=102)
                b -= 87;


            //right digit
            if (b1>=48 && b1<=57)
                b1 -= 48;
            //A-F
            else if(b1>=65 && b1<=70)
                b1 -= 55;
            //a-f
            else if(b1>=97 && b1<=102)
                b1 -= 87;

            bArray[i/2-1]=byte(16*b+b1);
        }

        return bArray;
    }

}
