# Fallback Function Vulnerabilities

**FIX:** always use the `receive()` function instead of nothing



<u>Calling Fallback function:</u>

```javascript
contract.sendTransaction({value: 1})
```

