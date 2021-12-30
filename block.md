# Block & Blockhash Functions

<u>Blockhash</u>: Returns hash of the given block

<u>Block.number</u>: Returns current block



**<u>Vulnerability</u>**: You can only get the hash of the block that has been PREVIOUSLY mined. You can't ever get the blockhash of the current block because it hasn't been mined yet.

