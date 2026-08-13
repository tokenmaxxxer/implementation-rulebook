---
axis: design-pattern-selection
rule_count_floor: 6
tier: sparse
---

# Design-pattern selection

Decision rules for when a GoF-style pattern earns its indirection, and
when the plain procedural/direct form is the correct choice instead.

## Rules

1. When a class has exactly one reason to change today and no second
   concrete caller is asking for a second reason, keep it as one class —
   do not pre-split into a Strategy/Factory pair "for future
   extensibility." Split only once a second concrete variant exists.
   source: Robert C. Martin, "The Principles of OOD" (SRP: "a class
   should have only one reason to change"),
   https://en.wikipedia.org/wiki/Single-responsibility_principle

2. When you are tempted to add a pattern (Strategy, Visitor, Abstract
   Factory, Decorator) to satisfy a hypothetical future requirement that
   no current caller needs, do not add it — implement the concrete case
   directly. Add the pattern only when a second concrete variant
   actually lands.
   source: YAGNI principle, summarized at
   https://medium.com/@hlfdev/kiss-dry-solid-yagni-a-simple-guide-to-some-principles-of-software-engineering-and-clean-code-05e60233c79f

3. When beginners or reviewers reach for a pattern "because it's the
   textbook answer" rather than because the code's own shape demands it,
   reject the pattern — dogmatic pattern-first design produces code that
   is "unreadable, fragile, and overly abstracted" relative to a direct
   solution.
   source: https://www.intertech.com/design-patterns-genius-or-overengineered/

4. When two call sites diverge only in a single data value (not
   behavior), use a parameter or a lookup table, not a Strategy pattern
   — Strategy is for divergent *algorithms*, not divergent *constants*.
   Applying it to constant-only divergence is exactly the "applying the
   wrong pattern" failure mode named as a source of disaster.
   source: https://www.red-gate.com/simple-talk/blogs/why-following-design-patterns-is-a-bad-idea/

5. REMOVAL — when a Factory/Builder/Abstract-Factory layer exists but
   only ever constructs one concrete product across the whole codebase,
   delete the factory and call the constructor directly; an unused
   abstraction seam is a subtractive fix, not something to leave "in
   case." People systematically underweight this kind of removal because
   subtractive changes require more deliberate search effort than
   additive ones — the correction is to check indirection layers for a
   single-implementer condition explicitly, not to wait for it to be
   noticed incidentally.
   source: Adams, Converse, Hales & Klotz, "People systematically
   overlook subtractive changes," Nature 592 (2021) 258-261,
   https://www.nature.com/articles/s41586-021-03380-y

6. REMOVAL — when a Visitor or Observer pattern's indirection exists
   purely to decouple two objects that in practice only ever have one
   pairing (one visitor class, one subject), collapse the pair back into
   direct method calls; keep the pattern only once a second
   visitor/observer actually exists at the call site.
   source: same overengineering-vs-fit tradeoff documented at
   https://luminousmen.com/post/design-patterns-suck/

## Counter-example tests

- Rule 1 counter-example: a payment module with `StripeCharge` today and
  a signed contract to add `AdyenCharge` next sprint — here a Strategy
  split IS justified because the second concrete variant is not
  hypothetical, it is scheduled. Rule 1 requires "no second concrete
  caller," so this case correctly falls outside the rule rather than
  contradicting it.
- Rule 5 counter-example: a `PaymentGatewayFactory` with one concrete
  product today but an explicit plugin-loading contract (third parties
  ship new gateways without touching this repo) is NOT a removal
  candidate — the abstraction seam is serving an external contract, not
  internal habit, so rule 5's "only ever constructs one concrete
  product" condition does not by itself trigger removal when an external
  extension contract already exists.
