Definitions
-----------

### Playbook

A set of plays for a specified host

- #### Play

  A set of tasks

- #### Task

  A task to perform, this could also be another play or
  playbook.

- #### Roles

  A complete play with associated handlers, variables etc.
  Basically syntax sugar for strutcuring larger plays as
  playbooks.

- #### Handler

  A reaction to a notification. Whenever a task uses
  `notfify`, a handler will be sought after

- #### Vars

  Variables, like in any language. They can exist in
  multiple places though. Better read the documentation.

### Job

Essentially the same as a playbook, except these are meant
to be executed manually when needed. They do not guarantee
idemopotence.

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

Variable precedence
-------------------

_1: Highest, 6: Lowest_

1. Variables defined under `vars_files`.
2. Variables defined in the `vars/main.yml`.
3. Variables passed in on the command line.
4. Variables defined under play/role `vars:` variable.
5. Variables defined in `group_vars/`.
6. Variables defined in `defaults/`.

Logs
----
- varnish
  - we are currently not logging access
  - restarts go to /var/log/messages
  - errors go to /var/log/syslog
- pound
  - /var/log/syslog
  - syslogd: local6
