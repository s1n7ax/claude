# /review output

Found 3 issues in this PR.

1. **Swallowed auth error** — `src/auth/login.ts`, around the `verifyToken` call. The catch block ignores the error from `verifyToken`, so the function continues even when the token is invalid. The caller will see a successful login with an unverified token.

2. **Plaintext password comparison** — `src/auth/login.ts`, the `password === user.password` check compares plaintext passwords. Should use a constant-time comparison against a hashed password.

3. **Dead variable** — `src/auth/login.ts`, `isValid` is assigned but never read. Either gate the return on it or remove it.
