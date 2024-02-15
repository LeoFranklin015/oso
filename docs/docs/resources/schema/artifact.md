---
title: Artifact
sidebar_position: 4
---

An artifact is a link or reference to work created by open source projects in the OSS Directory.

Our Version 3 schema currently supports three types of artifacts: GitHub organizations and repositories, NPM packages, and blockchain addresses. The `github`, `npm`, and `blockchain` fields in the [project schema](./project) are used to store arrays of artifacts associated with a particular project.

## Artifact Identification

Each artifact is identified by either a `url` field representing a valid URL in the correct namespace or an `address` representing a public key address on a blockchain.

For example, a GitHub organization artifact would be identified by a `url` field that is a valid GitHub organization URL (eg, `https://github.com/opensource-observer`). A blockchain address artifact would be identified by an `address` field that is a valid blockchain address (eg, `0x1234567890123456789012345678901234567890`).

:::warning
An artifact may only exist once and may only be assigned to a single project. For example, if a GitHub organization is already associated with a project, it cannot be added to another project. Similarly, if a blockchain address is already associated with a project, it cannot be added to another project.
:::

## URL Schema

The URL schema is used to validate artifacts that contain public code contributions. Currently, the only supported URL-based artifacts are GitHub organizations and repositories and NPM packages.

Artifacts that use this schema are validated to ensure that the `url` field is a valid URL in the correct namespace. For GitHub artifacts, the URL must begin with `https://github.com/`. For NPM artifacts, the URL must begin with `https://www.npmjs.com/package/`. Remember, a URL can only be assigned to a single project. New artifacts will also be validated to ensure that they do not already exist in the directory.

You can view the schema for the URL field [here](https://github.com/opensource-observer/oss-directory/blob/main/src/resources/schema/url.json).

```json
{
  "$id": "url.json",
  "title": "URL",
  "type": "object",
  "description": "A generic URL",
  "properties": {
    "url": {
      "type": "string",
      "format": "uri"
    }
  },
  "required": ["url"]
}
```

## Blockchain Address Schema

The blockchain address schema is used to validate blockchain addresses for projects.

The `address` field is the public blockchain address. On Ethereum and other networks compatible with the Ethereum Virtual Machine (EVM), public addresses all share the same format: they begin with 0x, and are followed by 40 alphanumeric characters (numerals and letters), adding up to 42 characters in total. Addresses are not case sensitive. Addresses will be validated to ensure they meet both network-specific and general address requirements.

Remember, a blockchain address can only be assigned to a single project. New artifacts will also be validated to ensure that they do not already exist in the directory.

:::warning
If you are referencing a Safe multi-sig address, remember to remove the chain identifer from the beginning of the address (eg, remove the 'oeth:' prefix from the beginning of an Optimism Safe).
:::

### Supported EVM Networks

The `networks` field is an array used to identify the blockchain network(s) that the address is associated with. Currently supported options are:

- `mainnet`: Ethereum mainnet
- `optimism`: Optimism mainnet
- `arbitrum`: Arbitrum One mainnet

We do not support testnets for any of these networks and do not intend to.

After an EVM blockchain address is validated and added to the directory, it will be stored as a unique address-network pair in the OSO database.

### Tagging Addresses

The `tags` field is an array used to classify the address. Currently supported options are `eoa`, `safe`, `creator`, `deployer`, `factory`, `proxy`, `contract`, and `wallet`. In most cases, an address will have more than one tag.

- `eoa`, `contract`, `safe`: These tags are used to classify the address as an Externally Owned Account (EOA), a smart contract, or a Safe multi-sig wallet. We try to differentiate between smart contracts and Safe multi-sig wallets; with the former we seek to track event data and with the latter we seek to track funding data.
- `wallet`: This tag is used to classify the address as a wallet that should be monitored for funding events. This tag is only associated with addresses that are also tagged as `eoa` or `safe`.
- `creator`, `deployer`: These tags are interchangeable and used to classify an EOA address that is primarily used to for deploying smart contracts. We track these addresses to identify new smart contracts that are deployed by projects. We do not monitor them for funding events.
- `factory`: This tag is used to classify a smart contract address that is used to deploy other smart contracts. We capture event data from all contracts deployed by a factory contract.
- `proxy`: This tag is used to classify a proxy contract address. We currently do not handle proxy contracts differently from other smart contracts, therefore it is an optional tag.

### Examples

#### EOA used for contract deployment

```json
{
  "address": "0x1234567890123456789012345678901234567890",
  "tags": ["eoa", "deployer"],
  "networks": ["mainnet", "optimism"],
  "name": "My Deployer EOA"
}
```

#### EOA used for custodying funds

```json
{
  "address": "0x1234567890123456789012345678901234567890",
  "tags": ["eoa", "wallet"],
  "networks": ["mainnet", "optimism", "arbitrum"],
  "name": "My Wallet EOA"
}
```

#### Safe used for custodying funds

```json
{
  "address": "0x1234567890123456789012345678901234567890",
  "tags": ["safe", "wallet"],
  "networks": ["mainnet"],
  "name": "My Safe Wallet"
}
```

#### Factory smart contract

```json
{
  "address": "0x1234567890123456789012345678901234567890",
  "tags": ["contract", "factory"],
  "networks": ["mainnet"],
  "name": "My Factory Contract"
}
```

### Full Schema

You can always access the most recent version of the schema [here](https://github.com/opensource-observer/oss-directory/blob/main/src/resources/schema/blockchain-address.json).

```json
{
  "$id": "blockchain-address.json",
  "title": "Blockchain address",
  "type": "object",
  "description": "An address on a blockchain",
  "properties": {
    "address": {
      "type": "string"
    },
    "tags": {
      "type": "array",
      "minItems": 1,
      "items": {
        "enum": [
          "eoa",
          "safe",
          "creator",
          "deployer",
          "factory",
          "proxy",
          "contract",
          "wallet"
        ],
        "$comment": "Tags that classify the address. Options include: \n- 'eoa': Externally Owned Account \n- 'safe': Gnosis Safe or other multi-sig wallet \n- 'deployer' (or 'creator'): An address that should be monitored for contract deployment events \n- 'factory': A contract that deploys other contracts \n- 'proxy': Proxy contract \n- 'contract': A smart contract address \n- 'wallet': An address that should be monitored for funding events"
      }
    },
    "networks": {
      "type": "array",
      "minItems": 1,
      "items": {
        "enum": ["mainnet", "optimism", "arbitrum"]
      }
    },
    "name": {
      "type": "string"
    }
  },
  "required": ["address", "tags", "networks"]
}
```

## Contributing

Artifacts are updated and added to the OSS Directory by members of the Data Collective. To learn more about contributing to the OSS Directory, start [here](../../contribute/intro). If you are interested in joining the Data Collective, you can apply [here](https://www.kariba.network/).