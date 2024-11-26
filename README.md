# LIPs

LUKSO Improvement Proposals (LIPs) and LUKSO standard proposal (LSPs) describe standards for the LUKSO platform, including core protocol specifications, client APIs, and smart contract standards.

A browsable version of all current and draft LIPs can be found on [the official LIP folder](https://github.com/lukso-network/LIPs/tree/master/LIPs).

# Contributing

Anyone is welcomed to make a PR to an existing LSP for fixes related to grammar or improvements related to the descriptions of an LSP specification.

For new LSP proposals, please refer to [**`CONTRIBUTING.md` > Proposing new LSPs**](./CONTRIBUTING.md#proposing-new-lsps).

Please note that this repository is for documenting standards and not for help implementing them. These types of inquiries should be directed to the **dev-chat** on the LUKSO Discord. For specific questions and concerns regarding EIPs, it's best to comment on the relevant discussion thread of the LSP denoted by the `discussions-to` tag in the LSP's preamble.

# LIP Status Terms

- **Draft** - an LIP that is undergoing rapid iteration and changes.
- **Review** - An LIP Author marks an LIP as ready for and requesting Peer Review.
- **Last Call** - an LIP that is done with its initial iteration and ready for review by a wide audience.
- **Accepted** - a core LIP that has been in Last Call for at least 2 weeks and any technical changes that were requested have been addressed by the author. The process for Core Devs to decide whether to encode an LIP into their clients as part of a hard fork is not part of the LIP process. If such a decision is made, the LIP wil move to final.
- **Final (non-Core)** - an LIP that has been in Last Call for at least 2 weeks and any technical changes that were requested have been addressed by the author.
- **Final (Core)** - an LIP that the Core Devs have decided to implement and release in a future hard fork or has already been released in a hard fork.
- **Deferred** - an LIP that is not being considered for immediate adoption. May be reconsidered in the future for a subsequent hard fork.

# Preferred Citation Format

The canonical URL for a LIP that has achieved draft status at any point is at https://github.com/lukso-network/LIPs/tree/master/LIPs.

# Terminology

The key words below are to be used to describe the specifications of a LIP or LSP standard. This terms are based are to be interpreted as described in [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119).

| Terminology    | Definition                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | Synonym               |
| -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------- |
| **MUST**       | the definition is an **absolute requirement** of the specification.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | REQUIRED              |
| **MUST NOT**   | the definition is an **absolute prohibition** of the specification.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | FORBIDDEN, PROHIBITED |
| **SHOULD**     | it is recommended to use and follow the specification, but there may exist valid reasons in particular circumstances where the specification can be ignored. <br> In such cases, the full implications should be understood and carefully weighted before choosing an alternative.                                                                                                                                                                                                                                                                                                                                                                                                                 | RECOMMENDED           |
| **SHOULD NOT** | it is not recommended to use the definition specified, but there may exist valid reasons in particular circumstances when the particular behaviour is acceptable or even useful. <br> Before implementing any behaviour described as SHOULD NOT, the full implications should be understood and the case weighted carefully.                                                                                                                                                                                                                                                                                                                                                                       | NOT RECOMMENDED       |
| **COULD**      | the specification is truly optional. One implementation may choose to include this particular specification because it feels that it enhances the feature, while another implementation may decide to omit it considering unnecessary. <br> An implementation that does not include this optional specification MUST be prepared to interoperate with another implementation which does include this option, though perhaps with reduced functionality. <br> In the same manner, an implementation which does include a particular option MUST be prepared to interoperate with another implementation which does not include the option (except, of course, for the feature the option provides.) | MAY, OPTIONAL         |
