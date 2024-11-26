# Contributing

## Proposing new LSPs

This section provides guidelines for how to propose a new LSP standard **before opening a Pull Requests** to the LSP repository.

We recommend any new proposer to review the `LIPs/lip-1.md` document for further details on how to propose new standards, their review process and guidelines,and the content that a LSP proposal should include.

### 1. Gathering feedbacks for a LSP proposal idea

> **Note:** this step is not mandatory but is recommended to improve engagement and feedbacks over a new LSP proposal.

In order to gather feedbacks and suggestions over a new LSP idea, LSP proposers SHOULD create a document **outside of the official LSP repository**. This could be in any form, for instance:

- a discussion on a forum.
- a Word document on a shared drive.
- a Markdown file on a website such as HackMD, Notion, etc...
- a Markdown file as a GitHub gist.

LSP proposers can then use this initial document and share the link to anyone to gather feedbacks and suggestions over it. This includes developers, protocol builders, experts in the field related to the LSP, or community members.

LSP proposers are also welcome to open discussion channels (such as on Telegram) to be able to engage with the community over their proposals, as well as invite anyone (people or projects) that they could judge interested in implementing their proposal.

The goal of this process is to iterate over the initial idea and refine:

- what the specification for the LSP should contain.
- what are the benefits of the LSP and what are the problems that it solves.
- clarify limitations, security and areas of concerns related to the proposed standard.

### 2. Creating an issue in the LIP repository

**Before proposing an LSP on this repository via a PR, ideas MUST be thoroughly discussed through an issue.**

Once the LSP proposer(s) judge their proposal clearer, reviewed and vetted, they can publish it in the repo.

**Initial LSP proposals MUST be first opened and discussed as an issue in the LSP repository.**

Once consensus is reached in the issue discussion, thoroughly review the LIP template and open your PR in this repository. The next section provides guidelines

### 3. Opening a PR for a new LSP proposal

1.  Review [LIP-1](LIPs/lip-1.md).
2.  Fork the repository by clicking "Fork" in the top right.
3.  Add your LIP to your fork of the repository. There is a [template LSP here](lsp-X.md).
4.  Submit a Pull Request to LUKSO's [LSPs repository](https://github.com/lukso-network/LIPs).

Your first PR should be a first draft of the final LSP. It must meet the following formatting criteria:

- Correct metadata in the header, as described in the [LSP template](lsp-x.md).
- Make sure you include a `discussions-to` header with the URL to a discussion forum or open GitHub issue where people can discuss the LSP as a whole.
- If your LSP requires images, the image files should be included in a subdirectory of the `assets` folder for that LIP as follow: `assets/lsp-X` (for lip **X**). When linking to an image in the LIP, use relative links such as `../assets/lsp-X/image.png`.

One or multiple editors will manually review the first PR for a new LSP and assign it a number before merging it.

When you believe your LIP is mature and ready to progress past the draft phase, you should do open a PR changing the state of your LIP to 'Final'. An editor will review your draft and ask if anyone objects to it being finalised. If the editor decides there is no rough consensus - for instance, because contributors point out significant issues with the LIP - they may close the PR and request that you fix the issues in the draft before trying again.
