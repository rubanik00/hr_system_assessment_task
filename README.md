# Candidate Hiring Process Smart Contract

## Overview

This Solidity smart contract is designed to manage the hiring process of candidates applying for developer positions. The contract tracks the progress of candidates through various stages of the interview process, ensuring that only authorized individuals can update the status of specific interview stages. Once all stages are completed successfully, the candidate's status is updated to "verified".

### The Assignment

A company is seeking job candidates for developer positions. The hiring process involves several steps (e.g., technical interview, design/architecture interview, coding interview, HR interview), and each step is approved by the person responsible for that phase. If a candidate is approved for all the steps, their status will be changed to "verified" for the job.

### The main functionality of this smart contract:

- **Step-by-step status update:** Only the person responsible for each step can update its status (e.g., technical interviewer, design interviewer, etc.).
- **One-time action per step:** Once the state of a step (passed/not passed) is defined, it cannot be changed.
- **Final verification:** The candidate's primary status will be updated to "verified" only if all the steps are approved.
- **Access control:** The data regarding each candidate's steps and primary status is only accessible to the manager (the contract deployer) and HR.

### Key focus areas:

- **Correctness of implementation**
- **Gas and storage efficiency**
- **Test coverage and quality**
- **Code readability and documentation**
- **Technical design and architecture**
- **Error handling and edge case management**

## Contract Features

- **Role-based access control:** Each interviewer can only update the step they are responsible for, and no one else.
- **Immutability of step updates:** Once a decision is made for an interview step (passed/failed), it cannot be modified.
- **Final candidate verification:** If all interview steps are marked as passed, the candidate's status is updated to "verified".
- **Event emission:** The contract emits events when interview statuses are updated and when a candidate is verified.

## Events

- `InterviewUpdated`: Emitted when a specific interview step (technical, design, coding, HR) is updated.
- `CandidateVerified`: Emitted when a candidate passes all the interviews and is marked as verified.

## Prerequisites

- **Foundry:** Used for development and testing.
- **AccessControl:** Provided by OpenZeppelin for role management.

## Usage

### Build the Contract

To build the smart contract using Foundry:

```bash
$ forge build
```

### Testing

To run tests for the smart contract:

```bash
$ forge test
```

### Formatting

To format the smart contract code:

```bash
$ forge fmt
```

### Gas Snapshots

To measure gas usage:

```bash
$ forge snapshot
```

### Local Ethereum Node

To start a local Ethereum node for testing:

```bash
$ anvil
```

### Deployment

To deploy the smart contract, run the following command:

```bash
$ forge script script/HiringProcess.s.sol:HiringProcessScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast Commands

You can use `cast` for various interactions with the smart contract:

```bash
$ cast <subcommand>
```

### Help

For additional help and documentation:

```bash
$ forge --help
$ anvil --help
$ cast --help
```

## Documentation

For more information about Foundry, check out the official documentation:

[Foundry Documentation](https://book.getfoundry.sh/)

## License

This project is licensed under the GNUv3.0 License. See the [LICENSE](LICENSE) file for details.
