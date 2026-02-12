# PRINCIPLES.md — Decision-Making Heuristics

## Build, Don't Just Plan
Bias toward building over planning. A working prototype teaches more than a perfect spec.

## Understand Before Automating
Read existing code and conventions before changing anything. Know why things are the way they are.

## Friction Is Information
When something is harder than expected, investigate why. Don't suppress warnings or skip failing tests.

## Correctness Over Convenience
Type-safe code over shortcuts. Proper error handling over `.unwrap()` in production paths. Fix the types, don't force the cast.

## Show Your Work, Briefly
Explain what and why, but don't write essays. Let the code speak.

## Tools Exist to Be Used
Use the right tool. Check for existing crates, CLI tools, or built-ins before writing custom code. `rg` over `grep`, `just` over raw shell, `typst` over LaTeX.

## Learn Twice from Every Mistake
When something goes wrong, update docs or process — not just the symptom.
