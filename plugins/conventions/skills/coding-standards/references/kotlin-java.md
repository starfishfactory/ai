# Kotlin/Java Coding Conventions

## Naming

| Element | Convention | Example |
|---------|-----------|---------|
| Class | PascalCase | `UserService`, `OrderController` |
| Function/Method | camelCase | `findUserById`, `processPayment` |
| Constant | SCREAMING_SNAKE | `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT_MS` |
| Package | lowercase dot-separated | `com.example.user.service` |
| Variable | camelCase | `userName`, `orderList` |
| Boolean | is/has/can/should prefix | `isActive`, `hasPermission` |
| Collection | plural noun | `users`, `orderItems` |

## Spring Boot Patterns

### Controller
- Use `@RestController` with `@RequestMapping` base path
- Method-level `@GetMapping`, `@PostMapping`, etc.
- Validate input with `@Valid` on `@RequestBody`
- Return `ResponseEntity<T>` for explicit HTTP status control
- No business logic in controllers — delegate to service layer

### Service
- Interface + implementation pattern for testability
- `@Transactional` at service method level (not class level)
- Prefer constructor injection over field injection
- Use `@Slf4j` (Lombok) or companion object logger

### Repository
- Extend `JpaRepository<Entity, ID>` or `CrudRepository`
- Custom queries with `@Query` annotation
- Use `Optional<T>` return types for nullable results
- Index frequently queried columns

## Error Handling

- Use sealed classes/hierarchies for domain errors
- Map domain errors to HTTP status codes in `@ControllerAdvice`
- Never catch `Exception` broadly — catch specific types
- Log errors with context (request ID, user ID, operation)

## Kotlin Specifics

- Prefer `data class` for DTOs and value objects
- Use `?.let { }` over null checks when applicable
- Prefer `when` over `if-else` chains for multiple conditions
- Use `require()` / `check()` for preconditions
- Use coroutines for async operations (`suspend fun`)

## Prohibited Patterns

- No `var` for mutable state that could be `val`
- No `!!` (non-null assertion) without documented reason
- No `Thread.sleep()` in production code
- No hardcoded magic numbers — use named constants
- No `System.out.println` — use logger
