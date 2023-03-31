Normal traditional financial accounts have tons of safe guards that improve usability, security, and experience. If someone steals your debit card, you can never lose your whole balance because of daily spending limits that are enforced by your bank. In a decentralized world, we have no centralized bank to defend us and must build more robust account security features into smart contract wallets like safe. Users do not want to make approvals every time they make a transaction, that flow messes with the UX too much for apps as well.

## Solution:

**Enforce daily spending limits, which require no additional daily token approvals, through custom smart contracts connected to a Safe multisig.**

## How it works:

1. Every user gets a 2/2 Safe
2. One of the signers is the user EOA, and the other is the SpendingLimit contract which enforces completely customizable spending limits, per user, per token, per any custom amount of time
3. When signing Safe transactions, the SpendingLimit signer will sign anything that is allowed according to the limits set by the user
4. When a tx is signed amount spent on the chosen time frame is updated

## Further improvements

1. Have default spending limits for daily, weekly, monthly etc, so users do not even require a transaction to set their Safe's limits.
2. FE improvements where users can set dollar values instead of token amounts for spending limits
3. More granular options like daily, weekly, monthly limits, instead of number just number of seconds
4. work in conjecture with more limits around 2FA and others.
5. further security improvements around what the SpendingLimit contract should be willing to sign. For example, it could only sign things if the user's EOA has signed it first.
6. Use a "Guard" on the safe directly. Ran out of time on this one, but planning to add it next week.

## Deployment addresses

Will be added shortly
