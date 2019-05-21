# LIPs
LUKSO Improvement Proposals (LIPs) describe standards for the LUKSO platform, including core protocol specifications, client APIs, and contract standards.

A browsable version of all current and draft LIPs can be found on [the official LIP site](https://github.com/ethereum/LIPs/tree/master/LIPs).

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
