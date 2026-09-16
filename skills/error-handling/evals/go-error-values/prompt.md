---
runs: 3
tags: [error-handling]
max_turns: 6
allowed_tools: [Skill]
---

Improve the error handling in this Go file. Reply with the finished code only.

```go
func (s *Store) GetOrder(ctx context.Context, id string) (*Order, error) {
	if id == "" {
		return nil, errors.New("id is required")
	}
	row, err := s.db.QueryRowContext(ctx, getOrderSQL, id).Scan(...)
	if err == sql.ErrNoRows {
		return nil, errors.New("order not found")
	}
	if err != nil {
		return nil, errors.New("query failed")
	}
	return row, nil
}
```
