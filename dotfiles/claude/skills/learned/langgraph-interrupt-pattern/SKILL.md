---
name: langgraph-interrupt-pattern
description: Use when implementing LangGraph workflows that need to pause for user
  input or external confirmation before continuing execution
---

# LangGraph Interrupt Pattern

## Overview

Pattern for using LangGraph `interrupt()` to pause graph execution at a node and resume after receiving external input (e.g., user confirmation, selection).

## Prerequisites

- A **checkpointer** must be configured (MemorySaver for dev, AsyncPostgresSaver for production)
- Use a consistent `thread_id` in the config across stream and resume calls

## Pattern

### Pausing execution

```python
from langgraph.types import interrupt

def my_node(state):
    # Do work, then pause for input
    user_input = interrupt({
        "reason": "need_selection",
        "options": ["option_a", "option_b"],
        "context": "Choose which path to take"
    })

    # Execution resumes here after user responds
    match user_input.get("action"):
        case "select":
            selected = user_input["selected"]
            return state.model_copy(update={"selected": selected})
        case "skip":
            return state
```

### Resuming execution

```python
from langgraph.types import Command

# Resume the graph with user's response
async for event in graph.astream_events(
    Command(resume={"action": "select", "selected": chosen_item}),
    config={"configurable": {"thread_id": thread_id}},
    version="v2",
):
    # Process streamed events
    pass
```

### Extracting interrupt data from state

```python
state_snapshot = await graph.aget_state(config)

for task in state_snapshot.tasks:
    for intr in task.interrupts:
        payload = intr.value  # The dict passed to interrupt()
        reason = payload.get("reason")
        options = payload.get("options")
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| No checkpointer configured | `interrupt()` silently fails without a checkpointer |
| Different `thread_id` on resume | Must match the original stream's thread_id |
| Passing full state to `astream_events` on resume | Pass `Command(resume=...)` only, not the state |
| Forgetting to handle the resume value | `interrupt()` returns whatever was passed in `Command(resume=...)` |
