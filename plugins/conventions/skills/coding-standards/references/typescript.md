# TypeScript Coding Conventions

## Naming

| Element | Convention | Example |
|---------|-----------|---------|
| Interface | PascalCase (no I prefix) | `UserService`, `PaymentGateway` |
| Type | PascalCase | `OrderStatus`, `ApiResponse<T>` |
| Function | camelCase | `fetchUsers`, `calculateTotal` |
| Constant | SCREAMING_SNAKE | `MAX_RETRIES`, `API_BASE_URL` |
| Variable | camelCase | `userName`, `isLoading` |
| Enum | PascalCase (members too) | `OrderStatus.Pending` |
| File | kebab-case | `user-service.ts`, `order-controller.ts` |
| React Component | PascalCase file | `UserProfile.tsx` |

## TypeScript Patterns

### Types
- Prefer `interface` for object shapes, `type` for unions/intersections
- Use `unknown` over `any` — narrow with type guards
- Use discriminated unions for state machines
- Export types alongside their implementations
- Use `as const` for literal types

### Async
- Use `async/await` over raw Promises
- Always handle errors with try/catch or `.catch()`
- Use `Promise.all()` for parallel operations
- Set timeouts on external calls (AbortController)

### Functions
- Prefer arrow functions for callbacks and inline functions
- Use regular functions for top-level declarations (hoisting)
- Maximum 3 parameters — use options object for more
- Return early for guard clauses

## React Patterns

- Functional components with hooks only (no class components)
- Custom hooks for reusable logic (`useAuth`, `useFetch`)
- Memoize expensive computations with `useMemo`
- Memoize callbacks passed to children with `useCallback`
- Colocate state — lift only when shared

## Error Handling

- Define typed error classes extending `Error`
- Use `Result<T, E>` pattern for functions that can fail
- Never swallow errors silently (empty catch blocks)
- Use error boundaries for React component trees

## Prohibited Patterns

- No `any` type without documented reason (use `unknown`)
- No `// @ts-ignore` or `// @ts-expect-error` without explanation
- No `== null` — use `=== null || === undefined` or optional chaining
- No barrel exports (`index.ts` re-exports) that create circular deps
- No `console.log` in production code — use structured logging
