Guidelines for tasks
--------------------
- Must be idempotent (can run multiple times, without causing side effects)
- Always specify a `state` (`present`, `absent`)
- Tag properly (read tag guidelines)
- Fill out all fields of the comment template and keep it updated (config
  params arent necessary if too many).
- All services should have an `enabled` state and they should be stopped and
  disabled if not set to `true`.
- If possible use `creates` or `removes` for each `shell` and `command` action.
- Make action names as descriptive as possible. If possible specify
  files modified or variables used.

Guidelines for jobs
-------------------
- Structured as playbooks.
- Doesn't have to be idempotent.
- Prompting is nice!
