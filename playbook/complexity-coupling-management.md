---
axis: complexity-coupling-management
rule_count_floor: 6
tier: sparse
---

# Complexity / coupling management

Decision rules for keeping module interdependence low and cohesion high,
with a numeric threshold to trigger refactor, plus removal rules for
shedding coupling that already exists.

## Rules

1. When a class's Coupling Between Objects (CBO) count — unique classes
   it touches via parameters, locals, return types, calls, field types,
   base classes, or interfaces — reaches 9, treat it as the trigger
   point to split the class or introduce a narrower interface; CBO = 9
   is the documented single-member threshold at which excessive coupling
   is flagged.
   source: Chidamber & Kemerer suite as surfaced via Visual Studio code
   metrics docs, https://learn.microsoft.com/en-us/visualstudio/code-quality/code-metrics-class-coupling?view=vs-2022

2. When a method's public API forces a caller to chain through an
   internal object's internal object (`a.getB().getC().doThing()`),
   restructure to a delegating method on `a` instead — this is the Law
   of Demeter violation to fix, and it exists specifically to bound
   how far coupling knowledge is allowed to travel between modules.
   source: Ian Holland, Demeter Project (1987), summarized at
   https://en.wikipedia.org/wiki/Law_of_Demeter and https://deviq.com/laws/law-of-demeter/

3. When two methods within one class operate on disjoint subsets of that
   class's instance fields (high Lack-of-Cohesion-in-Methods, LCOM),
   split the class along the field-usage boundary — a class whose
   methods don't share state is two classes sharing one file, not one
   cohesive unit.
   source: Chidamber & Kemerer LCOM metric, summarized at
   https://www.geeksforgeeks.org/software-engineering/software-engineering-coupling-and-cohesion/

4. When a new feature can be satisfied by widening an existing module's
   public contract vs. adding a new cross-module dependency edge, prefer
   widening the existing contract — each new dependency edge is a
   permanent coupling cost, and lower coupling is what makes a module
   independently reusable and testable.
   source: https://www.techtarget.com/searchapparchitecture/tip/The-basics-of-software-coupling-metrics-and-concepts

5. REMOVAL — when a dependency-injection interface has exactly one
   implementation across the entire codebase AND no test double
   currently substitutes a second implementation through it, delete the
   interface and depend on the concrete type directly; an interface that
   never varies is coupling-shaped ceremony, not coupling reduction. Flag
   this explicitly during review rather than relying on it to be noticed
   — subtractive fixes are the systematically overlooked category.
   source: Adams, Converse, Hales & Klotz, Nature 592 (2021) 258-261,
   https://www.nature.com/articles/s41586-021-03380-y

6. REMOVAL — when a shared "utils"/"common" module has grown so that
   unrelated callers each depend on it for one unrelated function, split
   it back apart by consumer group rather than adding a new function to
   it; a low-cohesion shared module is itself a coupling hazard (every
   caller of the module is transitively coupled to every other caller's
   changes) and the fix is to shrink/delete the shared module, not grow
   it further.
   source: cohesion/coupling tradeoff per https://www.sciencedirect.com/org/science/article/pii/S1546221823007154

## Counter-example tests

- Rule 1 counter-example: a central `EventBus` class legitimately touches
  many event-type classes because dispatching *is* its one job — high
  CBO here is not a coupling defect because the class's single
  responsibility is to be the coupling point; the trigger is CBO
  combined with the class ALSO having low cohesion (rule 3), not CBO
  alone.
- Rule 5 counter-example: a `PaymentProcessor` interface with one
  production implementation but a test-only fake substituted in the
  unit-test suite is NOT a removal candidate — "no test double
  substitutes a second implementation" is part of rule 5's condition,
  and a test fake is exactly that second implementation.
