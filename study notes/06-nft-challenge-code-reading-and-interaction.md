# 06 --- NFT Challenge Code Reading and Interaction

## Milestone

I worked through a Cyfrin Foundry course NFT challenge, inspected the
Solidity contract and its interface, inferred what inputs it expected,
and successfully used the interface to obtain the challenge NFT on
Sepolia.

The main lesson was connecting Solidity source code to an actual
contract interaction.

## 1. Reading the challenge requirements

The challenge's `solveChallenge` function accepted multiple inputs:

-   A number that had to match a required value (`123` in this
    exercise).
-   A string for my Twitter handle.
-   Another string used as a personal description or challenge-specific
    detail.

The function signature tells me **what inputs the function accepts**. It
does not, by itself, tell me whether those inputs are valid or what the
contract does with them. To understand that, I must read the function
body.

## 2. How the conditional check works

The challenge used an `if` condition to compare the submitted number
with the required number. Conceptually, the logic was:

``` solidity
if (submittedNumber != requiredNumber) {
    revert();
}
```

This is illustrative pseudocode, not a copy of the challenge's exact
source.

The condition checks whether the submitted value satisfies the
challenge's rule. If an incorrect answer causes a revert, the
transaction fails and its state changes are rolled back.

A variable such as `submittedNumber` is simply a name for the input
value. A variable such as `requiredNumber` represents the value the
contract expects. The comparison enforces the rule.

## 3. Validation is different from accepting and using inputs

I noticed that the conditional statement explained the numeric check,
but not what happened to the other inputs. That is the right distinction
to investigate.

When reading a challenge function, trace each parameter separately:

1.  **Declared in the function signature:** What values can the caller
    provide, and what are their types?
2.  **Validated:** Does the code compare the input, check a condition,
    or revert if a rule is not met?
3.  **Stored:** Is the value written to a state variable or mapping?
4.  **Used or forwarded:** Is it passed to another function or contract?
5.  **Emitted or displayed:** Is it included in an event or later used
    in NFT metadata?

The Twitter handle and description strings do not become persistent
state merely because they are function parameters. Their effect depends
on what the function does with them. A string might be stored in a
mapping, passed to an NFT minting function, or used to build metadata.

## 4. From challenge function to NFT

The course's NFT system separates the individual challenge from the
central NFT/reward contract.

``` text
Me
 |
 | call solveChallenge(...) with the required inputs
 v
Challenge contract
 |
 +-- checks whether the answer satisfies the challenge
 +-- uses the supplied strings as defined by its code
 +-- calls the central NFT contract to request the reward
       |
       v
    NFT contract
       |
       +-- checks that the caller is a registered challenge
       +-- checks whether this user already solved this challenge
       +-- mints the NFT if the checks pass
```

The exact steps depend on the challenge implementation. The key
architectural point is that the challenge contract contains the
challenge-specific logic, while the central NFT contract handles the
shared reward mechanism.

This also explains the importance of `msg.sender` in a
contract-to-contract call: inside the challenge contract, it normally
identifies the user who called the challenge; inside the NFT contract,
it identifies the challenge contract that called the NFT contract.

## 5. Read the code before using the interface

The explorer interface let me submit the function inputs without writing
a separate script. The interface was useful, but understanding the
Solidity code first helped me know what to submit and why.

A good workflow for future challenges:

1.  Find the challenge's `solveChallenge` function.
2.  Read its parameter names and types.
3.  Trace every condition that can allow the transaction to continue or
    cause it to revert.
4.  Trace each input to see whether it is stored, forwarded, emitted, or
    used in metadata.
5.  Identify any calls to the central NFT/reward contract.
6.  Use the interface or a script to submit the intended values.
7.  Verify the transaction and NFT result on the explorer.
8.  Explain in my own words why the call succeeded.

A successful transaction is useful evidence, but I should still be able
to explain which checks passed and which contract performed each action.

## 6. What I learned

-   A function signature tells me what inputs a function accepts; the
    function body defines its behavior.
-   An `if` statement can enforce a challenge condition. A `revert`
    prevents an invalid call from completing successfully.
-   Checking an answer and using the other inputs are separate parts of
    a function's behavior.
-   Function parameters are not automatically stored in contract state.
-   A challenge contract and the central NFT contract have different
    responsibilities.
-   A blockchain explorer interface can call deployed contract
    functions, but it does not replace understanding the code.
-   I successfully used the interface to obtain the challenge NFT,
    connecting source-code interpretation to a real on-chain
    interaction.

## 7. Questions to ask in the next challenge

-   What exact condition must be satisfied?
-   What happens if the condition fails?
-   What happens to each function parameter after validation?
-   Which contract makes the NFT minting call?
-   What does `msg.sender` refer to at each step?
-   What transaction or on-chain state change proves that the challenge
    succeeded?

------------------------------------------------------------------------

**Study principle:** Do not stop at identifying the right inputs. Trace
how the contract validates and uses each one, then verify the resulting
on-chain behavior.
