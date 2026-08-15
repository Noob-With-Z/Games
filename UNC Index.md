# UNC Index

> *Note: Some parts of this document may have been poorly translated or written.*

## What is "UNC"?

**UNC** stands for **Unified Naming Convention**. It is a standard created to make executor-provided APIs more consistent across different environments.

The idea is simple: different executors may provide similar functionality, but their APIs can have different names or implementations. UNC attempts to standardize these names and behaviors so that scripts can be more compatible between environments.

Some examples of APIs commonly associated with the UNC standard include:

* `firetouchinterest`
* `fireclickdetector`
* `fireproximityprompt`
* `getconnections`
* and many others.

> **Important:** These are executor-provided APIs. They are not standard Roblox/Luau functions.

## Why an Index for UNC?

While looking into UNC and executor APIs, I found plenty of information about some functions, but significantly less about others.

So, why not put everything together?

The goal of this index is to collect useful information, explanations, examples, and tips about these APIs in one place. Hopefully, this can make it easier for people to understand what these functions do and how they work.

This document is intended for **educational purposes**. I do not recommend using executors or exploiting Roblox games, as doing so may violate Roblox's Terms of Use and/or the rules of individual experiences.

With that out of the way, let's start with the basics.

---

# The Beginning

Before going deep into executor APIs, we should first understand the environment in which these functions exist.

Roblox uses **Luau**, its scripting language based on Lua. However, the normal Roblox scripting environment does not provide executor-specific APIs such as `fireclickdetector` or `getconnections`.

Executors add their own APIs to the scripting environment. This is why a script using one of these functions may work in an executor but fail in a normal Roblox Studio/LocalScript environment.

Understanding this distinction is important before learning about UNC.

Let's start with something much more fundamental:

# RBXScriptConnections

## What is an RBXScriptConnection?

An **RBXScriptConnection** represents a connection between an event (an `RBXScriptSignal`) and a function.

When you use `:Connect()` on an event, Roblox returns an `RBXScriptConnection` representing that connection.

For example:

### Print When a Humanoid Dies

```lua
local connection = Humanoid.Died:Connect(function()
    print("I Died!")
end)
```

Whenever the `Died` event fires, the connected function is executed.

The returned connection can also be disconnected later:

```lua
connection:Disconnect()
```

After calling `:Disconnect()`, that function will no longer be called by that particular connection.

In simple terms:

```text
RBXScriptSignal
       ↓
   :Connect()
       ↓
RBXScriptConnection
       ↓
   callback()
```

The important distinction is:

* **RBXScriptSignal** — the event/signal you connect to.
* **RBXScriptConnection** — the connection created by `:Connect()`.
* **Callback** — the function that runs when the event fires.

---

## Listening for Property Changes

Another common example is the `Changed` event.

For most `Instance` objects, `Changed` passes the **name of the property that changed** to the connected function.

```lua
local part = workspace.Part

local function onChanged(propertyName)
    local newValue = part[propertyName]

    print(string.format(
        "Property %s changed to %s",
        propertyName,
        tostring(newValue)
    ))
end

part.Changed:Connect(onChanged)
```

For example, if the part's `Transparency` changes, `propertyName` will contain:

```text
"Transparency"
```

You can then use that name to read the current value of the property.

> **Note:** `Changed` does not behave identically for every Roblox object. For example, `ValueBase` objects such as `StringValue` and `NumberValue` pass the new value directly instead of a property name.

This distinction is important when working with Roblox events.

---

And with that, we have the basic idea behind **RBXScriptSignals, RBXScriptConnections, and callbacks**.

Now we can move on to the more interesting part: understanding the executor APIs that UNC attempts to standardize.
