# /review output

Found 4 issues in this PR.

1. **Unvalidated discount** — `api/handlers/orders.py`, the `discount` value comes straight from the request body and is subtracted from `total` without any validation. A negative or huge discount could create free or negative-priced orders.

2. **Email send not in try/except** — `api/handlers/orders.py`, `send_confirmation_email(order)` runs after the DB commit but isn't wrapped in error handling. If the email service is down, the request fails after the order is already persisted, which is a misleading 500 to the client.

3. **Pre-existing N+1 in `Order.to_dict()`** — `api/handlers/orders.py`. The `to_dict` method (not modified in this PR) does an unbatched query per line item. Not introduced here, but worth flagging since this code path is now hotter.

4. **Architectural: handler does too much** — request parsing, business logic (discount math), persistence, and side effects (email) all live in the handler. Consider extracting an `OrderService` layer.
