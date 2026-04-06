# Development Principles (97 Things Every Programmer Should Know)

Follow these principles in all code you write, review, or modify.

## Simplicity
- Remove everything unnecessary. Less is more.
- Methods: 5-10 lines ideal. Each object: single clear purpose.
- If code is too complex, delete and rewrite — don't patch.
- Don't add features "just in case" (YAGNI).

## Quality
- Boy Scout Rule: leave code cleaner than you found it.
- DRY: single authoritative representation for each piece of knowledge.
- SRP: one reason to change per class/module/function.
- Interfaces should be easy to use correctly, hard to use incorrectly.
- Only the code tells the truth — make it self-explanatory.

## Testing & Errors
- Testing is a professional obligation, not optional.
- Always check for errors, always handle them. Every time.
- Check your own code first before blaming tools or libraries.
- Comment only what code cannot say — explain WHY, not WHAT.

## Workflow
- Know your next commit before you start coding.
- Break work into small chunks (1-2 hours each).
- Commit only intentional work. Discard speculative code.
- You are not the user — observe real behavior, don't assume.
- Don't be afraid to break things — tests enable confident refactoring.
- Put everything under version control.

## Code Is Design
- Software development is creative, not mechanical.
- Treat code as a composition worthy of careful crafting.
- Code outlives initial expectations — write it accordingly.
- Three similar lines > premature abstraction.
