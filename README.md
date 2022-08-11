# Reproduction issue with pnpm and forge

Using yarn the contracts compile with `forge build`. With `pnpm` they do not.

Steps to reproduce:

```
cd contracts
pnpm i
forge build # this fails
rm -rf node_modules
yarn
rm -rf out cache & forge cache clean
forge build # this succeeds!
```
