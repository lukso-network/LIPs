# LIPs

LUKSO Improvement Proposals (LIPs) and LUKSO standard proposal (LSPs) describe standards for the LUKSO platform, including core protocol specifications, client APIs, and smart contract standards.

A browsable version of all current and draft LIPs can be found on [the official LIP folder](https://github.com/lukso-network/LIPs/tree/master/LIPs).

# Contributing

 1. Review [LIP-1](LIPs/lip-1.md).
 2. Fork the repository by clicking "Fork" in the top right.
 3. Add your LIP to your fork of the repository. There is a [template LIP here](lip-X.md).
 4. Submit a Pull Request to LUKSO's [LIPs repository](https://github.com/lukso-network/LIPs).

Your first PR should be a first draft of the final LIP. It must meet the formatting criteria enforced by the build (largely, correct metadata in the header). An editor will manually review the first PR for a new LIP and assign it a number before merging it. Make sure you include a `discussions-to` header with the URL to a discussion forum or open GitHub issue where people can discuss the LIP as a whole.

If your LIP requires images, the image files should be included in a subdirectory of the `assets` folder for that LIP as follow: `assets/lip-X` (for lip **X**). When linking to an image in the LIP, use relative links such as `../assets/lip-X/image.png`.

When you believe your LIP is mature and ready to progress past the draft phase, you should do open a PR changing the state of your LIP to 'Final'. An editor will review your draft and ask if anyone objects to its being finalised. If the editor decides there is no rough consensus - for instance, because contributors point out significant issues with the LIP - they may close the PR and request that you fix the issues in the draft before trying again.

# LIP Status Terms

* **Draft** - an LIP that is undergoing rapid iteration and changes.
* **Last Call** - an LIP that is done with its initial iteration and ready for review by a wide audience.
* **Accepted** - a core LIP that has been in Last Call for at least 2 weeks and any technical changes that were requested have been addressed by the author. The process for Core Devs to decide whether to encode an LIP into their clients as part of a hard fork is not part of the LIP process. If such a decision is made, the LIP wil move to final.
* **Final (non-Core)** - an LIP that has been in Last Call for at least 2 weeks and any technical changes that were requested have been addressed by the author.
* **Final (Core)** - an LIP that the Core Devs have decided to implement and release in a future hard fork or has already been released in a hard fork. 
* **Deferred** - an LIP that is not being considered for immediate adoption. May be reconsidered in the future for a subsequent hard fork.

# Preferred Citation Format

The canonical URL for a LIP that has achieved draft status at any point is at https://github.com/lukso-network/LIPs/tree/master/LIPs.

# Terminology

The key words below are to be used to describe the specifications of a LIP or LSP standard. This terms are based are to be interpreted as described in [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119).

| Terminology  | Defintion  | Synonym |
|---|---|---|
| **MUST**  | the definition is an **absolute requirement** of the specification.  | REQUIRED  |
| **MUST NOT**  | the definition is an **absolute prohibition** of the specification.  | FORBIDDEN, PROHIBITED  |
| **SHOULD**  | it is recommended to use and follow the specification, but there may exist valid reasons in particular circumstances where the specification can be ignored. <br> In such cases, the full implications should be understood and carefully weighted before choosing an alternative.  | RECOMMENDED  |
| **SHOULD NOT**  | it is not recommended to use the definition specified, but there may exist valid reasons in particular circumstances when the particular behaviour is acceptable or even useful. <br> Before implementing any behaviour described as SHOULD NOT, the full implications should be understood and the case weighted carefully.  | NOT RECOMMENDED  |
| **COULD**  | the specification is truly optional. One implementation may choose to include this particular specification because the it feels that it enhances the feature, while an other implementation may decide to omit it considers it unnecessary. <br> An implementation that does not include this optional specification MUST be prepared to interoperate with another implementation which does includes this option, though perhaps with reduced functionality. <br> In the same manner, an implementation which does include a particular option MUST be prepared to interoperate with another implementation which does not include the option (except, of course, for the feature the option provides.) | MAY, OPTIONAL  |

Note that one standard can be based on another standard and override a specification from the sub-standard. In this case, the terminology used can be overriden.
 
For instance, consider a LSP B based on LSP A.

- LSP A can define a specific behaviour X as optional (COULD).
- But LSP B can override this specification and mark behaviour X as a requirement (MUST).
