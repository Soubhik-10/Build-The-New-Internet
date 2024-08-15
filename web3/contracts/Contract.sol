// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract CommitmentScheme {
    uint256 private  p;
    uint256 private q;
    uint256 private g;
    uint256 private h;

    constructor() {
        p = generatePrime(); // Example prime
        q = p * 2 + 1;
        g = randomMod(q);
        uint256 s = randomMod(q);
        h = modExp(g, s, q);
    }

    function generatePrime() internal pure returns (uint256) {
        return 11; //we will use a big prime then erase it after publishing by making sure that 2p+1 is also prime
    }

    function randomMod(uint256 max) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % max;
    }

    function modExp(uint256 base, uint256 exp, uint256 mod) internal pure returns (uint256) {
        uint256 result = 1;
        base = base % mod;
        while (exp > 0) {
            if (exp % 2 == 1) {
                result = (result * base) % mod;
            }
            exp = exp >> 1;
            base = (base * base) % mod;
        }
        return result;
    }

    function commit(
        uint256 g,
        uint256 x,
        uint256 h,
        uint256 r,
        uint256 q
    ) public pure returns (uint256) {
        uint256 gx = modExp(g, x, q);
        uint256 hr = modExp(h, r, q);
        return (gx * hr) % q;
    }

   

    function verify(
        uint256 c,
        uint256 g,
        uint256 h,
        uint256 x,
        uint256 q,
        uint256 rs
    ) public pure returns (bool) {
        uint256 sum = 0;
        
            sum = (sum + rs) % q;
        
        uint256 gx = modExp(g, x, q);
        uint256 hr = modExp(h, sum, q);
        return c == (gx * hr) % q;
    }

    function exampleCommitment(
        uint256 msg1,
        uint256 msg2
    ) public view returns ( bool, bool) {
        uint256 r1 = randomMod(q);
        uint256 r2 = randomMod(q);
        uint256 c1 = commit(g, msg1, h, r1, q);//we will use voting party address in place of  msg and pass the commitment
        uint256 c2 = commit(g, msg2, h, r2, q);
      
       
        
        bool result1 = verify(c1, g, h, 1, q, r1);//decrypt it and count vote
        bool result2 = verify(c2, g, h, 2, q, r2);
     

        return (result1, result2);
    }
}