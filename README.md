AffineCipher
============

The AffineCipher is a generalization of the Caesar (shift) cipher. The Ceasar cipher uses a single key, with limited keyspace. The encrypted message 'e' is given by 'e = k + s mod m', where 'k' is the key, 's' is the input message, and 'm' is the size of the keyspace (= size of input space). The Affine Cipher is similar, except is uses another key 'a' such that 'e = k + s a mod m'. The reverse operation, decryption, only works when 'a' has an inverse modulo 'm'. While Affine has an improvement in the overall size of the keyspace, brute force attacks and frequency attacks are still very easy. Here I will modify my encrypt and decrypt functions for the CaesarCipher to implement the AffineCipher.
