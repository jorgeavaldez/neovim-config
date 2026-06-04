revise, review, and cleanup your changes.
Avoid trivial one-use helpers or proxy functions. Inline simple constructors, list comprehensions, regexes, and transformations unless the abstraction is reused, has meaningful domain semantics, hides real complexity, improves testability, or materially clarifies the caller. Prefer direct, local code over small indirection layers.
