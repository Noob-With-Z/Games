# UNC Index

> *Note: Some parts of this document may have been poorly translated or written.*

It helped you? Consider leaving a star for this repo and help it reach people who is looking for!

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

# 1. The Beginning — Understanding the Default Roblox Environment

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

# RemoteEvents and RemoteFunctions

## What are RemoteEvents and RemoteFunctions?

`RemoteEvent` and `RemoteFunction` are Roblox `Instance` classes commonly used for communication between the **client and the server**.

They allow code running on the client and server to communicate with each other:

```text
Client <--------> Server
```

You may be wondering:

> "Why are we talking about this? They don't seem particularly useful or interesting."

Well... not quite.

This topic is actually more interesting than you might think.

Understanding how these objects work is important because they are commonly used for client-server communication. Later on, we'll also see how they can be inspected and interacted with using executor APIs.

But that's a topic for later — we're still a little early for that.

For now, let's focus on the differences between `RemoteEvents` and `RemoteFunctions`.

---

## RemoteEvents

A `RemoteEvent` is used for **one-way communication**. It sends information to the other side without waiting for a return value.

### Client → Server

The client can fire a `RemoteEvent` using:

```lua
RemoteEvent:FireServer(Args)
```

On the server, the corresponding event can be handled using `OnServerEvent`.

### Server → Client

The server can communicate with a specific client using:

```lua
RemoteEvent:FireClient(Player, Args)
```

`Player` determines which client should receive the event.

For example, this can be useful when an effect should only happen for one player, such as a client-side cutscene.

The server can also send the event to **every player** using:

```lua
RemoteEvent:FireAllClients(Args)
```

This sends the event to every connected player.

Unlike `RemoteFunctions`, `RemoteEvents` do **not** return a value to the caller. They simply fire the corresponding event and pass the provided arguments to the receiving side.

---

## RemoteFunctions

`RemoteFunctions` are slightly different.

They are used for **request-and-response communication**, meaning the caller can invoke a function and receive a return value.

### Client → Server

The client can invoke a `RemoteFunction` using:

```lua
local result = RemoteFunction:InvokeServer(Args)
```

The server handles this through `OnServerInvoke` and can return a value:

```lua
RemoteFunction.OnServerInvoke = function(Player, Args)
    return "Hello from the server!"
end
```

The returned value is then received by the client:

```lua
local result = RemoteFunction:InvokeServer(Args)

print(result)
-- Hello from the server!
```

### Server → Client

The server can also invoke a `RemoteFunction` on a specific client:

```lua
local result = RemoteFunction:InvokeClient(Player, Args)
```

The client handles this through `OnClientInvoke`:

```lua
RemoteFunction.OnClientInvoke = function(Args)
    return "Hello from the client!"
end
```

The important thing to remember is that **`InvokeClient` requires a `Player` argument**. There is no `RemoteFunction:InvokeClient(Args)` form.

---

## RemoteEvent vs. RemoteFunction

The simplest way to remember the difference is:

|                     | `RemoteEvent`                       | `RemoteFunction`   |
| ------------------- | ----------------------------------- | ------------------ |
| Client → Server     | `FireServer()`                      | `InvokeServer()`   |
| Server → Client     | `FireClient()` / `FireAllClients()` | `InvokeClient()`   |
| Returns a value     | ❌ No                               | ✅ Yes            |
| Communication style | One-way event                       | Request → response |

One important detail about `RemoteFunctions` is that the invocation **waits for the callback to return**. This makes them useful when the caller actually needs a response from the other side.

So, in short:

> **RemoteEvents** are for sending information without expecting a return value.

> **RemoteFunctions** are for requesting something and receiving a response.

Once you understand these two, a lot of Roblox's client-server architecture starts making much more sense.

# ClickDetectors, ProximityPrompts & TouchInterests

## What are they?

Before looking at executor APIs such as `fireclickdetector`, `fireproximityprompt`, and `firetouchinterest`, we should understand the Roblox objects and systems they interact with.

These three mechanisms are commonly used to make objects in an experience interactable:

| Object / System   | Main purpose                                  |
| ----------------- | --------------------------------------------- |
| `ClickDetector`   | Interaction by clicking an object             |
| `ProximityPrompt` | Interaction when the player is near an object |
| Touch interaction | Interaction caused by physical contact        |

Although they can all be used to trigger interactions, they work in different ways.

---

## ClickDetectors

A `ClickDetector` allows a player to interact with a `BasePart` by clicking it.

For example:

```lua
local clickDetector = workspace.Part.ClickDetector

clickDetector.MouseClick:Connect(function(player)
    print(player.Name .. " clicked the part!")
end)
```

The `MouseClick` event provides the `Player` who performed the interaction.

A `ClickDetector` can also detect different mouse interactions, such as:

* `MouseClick`
* `RightMouseClick`
* `MouseHoverEnter`
* `MouseHoverLeave`
* `MouseButton1Down`
* `MouseButton1Up`
* `MouseButton2Down`
* `MouseButton2Up`

### Executor Interaction

Some executor environments provide an API commonly known as:

```lua
fireclickdetector(clickDetector)
```

The purpose of this function is to simulate the interaction associated with a `ClickDetector`.

> **Note:** `fireclickdetector` is not a standard Roblox API. It is an executor-provided function.

---

## ProximityPrompts

A `ProximityPrompt` provides an interaction that can be triggered when a player gets close enough to an object.

For example:

```lua
local prompt = workspace.Part.ProximityPrompt

prompt.Triggered:Connect(function(player)
    print(player.Name .. " triggered the prompt!")
end)
```

A prompt can display information such as:

* An action name
* A keyboard/gamepad input
* A hold duration
* A maximum activation distance

For example, a prompt could display:

```text
[E] Open Door
```

When the player activates it, the `Triggered` event fires.

### Executor Interaction

Executor environments may provide:

```lua
fireproximityprompt(prompt)
```

This function is commonly used to trigger a `ProximityPrompt` programmatically.

> **Note:** `fireproximityprompt` is not part of the standard Roblox API.

---

## Touch Interactions

Touch interactions are different from the previous two.

Instead of explicitly clicking or activating something, a touch interaction occurs when physical parts come into contact.

Roblox provides events such as:

```lua
local part = workspace.Part

part.Touched:Connect(function(otherPart)
    print("Touched by:", otherPart:GetFullName())
end)
```

There is also:

```lua
part.TouchEnded
```

which fires when the touching relationship ends.

A common example would be a kill brick:

```lua
local part = workspace.KillBrick

part.Touched:Connect(function(hit)
    local character = hit.Parent
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.Health = 0
    end
end)
```

### Executor Interaction

Some executor environments expose a function commonly known as:

```lua
firetouchinterest(part1, part2, state)
```

This is intended to simulate or manipulate a touch interaction between two parts.

The exact behavior and supported arguments can vary between executor implementations, so this is one of the APIs where checking the specific environment is important.

---

## Comparing the Three

| Mechanism         | Interaction      | Common Roblox event      | Common executor API   |
| ----------------- | ---------------- | ------------------------ | --------------------- |
| `ClickDetector`   | Mouse click      | `MouseClick`             | `fireclickdetector`   |
| `ProximityPrompt` | Proximity/input  | `Triggered`              | `fireproximityprompt` |
| Touch             | Physical contact | `Touched` / `TouchEnded` | `firetouchinterest`   |

The important distinction is that these executor functions are **not replacements for the Roblox objects themselves**.

They are executor-provided interfaces for interacting with systems that already exist in the Roblox experience.

Understanding the underlying Roblox API first makes the executor APIs much easier to understand.


# 2. The Real Index

## What are we going to learn?

Here's a list of the APIs and concepts we're going to take a look at:

```text
Interaction Simulation
├── fireproximityprompt
├── fireclickdetector
└── firetouchinterest

Function & Metatable Hooking
├── hookmetamethod
│   ├── __namecall
│   └── __index
├── hookfunction
├── getnamecallmethod
└── checkcaller
```

> **Note:** The APIs documented in this section are executor-provided APIs. They are not part of the standard Roblox API, and their behavior may vary between executor implementations.

---

## 2a. Interaction Simulation

This section covers APIs commonly used to programmatically trigger or simulate interactions with Roblox objects and systems.

### `fireproximityprompt`

```lua
fireproximityprompt(ProximityPrompt)
```

**Arguments:**

```text
<ProximityPrompt> The ProximityPrompt to trigger.
```

This API is commonly used to programmatically trigger a `ProximityPrompt`.

**Return value:** Executor-dependent.

---

### `fireclickdetector`

```lua
fireclickdetector(ClickDetector)
```

**Arguments:**

```text
<ClickDetector> The ClickDetector to trigger.
```

This API is commonly used to programmatically trigger a `ClickDetector`.

**Return value:** Executor-dependent.

---

### `firetouchinterest`

```lua
firetouchinterest(TouchPart, TouchTarget, State)
```

**Arguments:**

```text
<TouchPart> The BasePart containing the touch-related functionality.
<TouchTarget> The BasePart to interact with.
<State> 0 to begin the touch and 1 to end the touch.
```

Unlike `fireclickdetector` and `fireproximityprompt`, `firetouchinterest` works with the Roblox touch system rather than an explicit interaction object such as a `ClickDetector` or `ProximityPrompt`.

A common pattern is to begin a touch and then end it:

```lua
firetouchinterest(TouchPart, TouchTarget, 0)
task.wait()
firetouchinterest(TouchPart, TouchTarget, 1)
```

This can also be wrapped in a helper function:

```lua
local function touch(touchPart, touchTarget)
    if touchPart and touchTarget then
        firetouchinterest(touchPart, touchTarget, 0)
        task.wait()
        firetouchinterest(touchPart, touchTarget, 1)
    end
end
```

> **Compatibility note:** `firetouchinterest` is executor-specific, so the exact behavior and supported arguments may differ between environments.

---

## 2b. Function & Metatable Hooking

This section covers APIs used to intercept, replace, or inspect function calls and metamethod operations.

The main APIs we'll look at are:

```text
hookmetamethod
hookfunction
getnamecallmethod
checkcaller
```

We'll also cover the two metamethods that are especially relevant when working with `hookmetamethod`:

```text
__namecall
__index
```

These concepts are more advanced than the interaction APIs above, so it is useful to understand Lua/Luau functions, metatables, and metamethods before diving into them.

### Differences Between `__namecall` and `__index`

If you've ever looked into `hookmetamethod`, you've probably seen these two metamethods mentioned:

* `__namecall`
* `__index`

They are both commonly used when hooking Roblox object behavior, but they serve very different purposes.

Instead of overcomplicating the explanation, let's look at some examples first.

---

### `__namecall`

`__namecall` is associated with method calls using the `:` syntax.

For example:

```lua
game.Players.LocalPlayer:Kick()
```

A hook can intercept the method call and inspect which method was requested:

```lua
local oldNamecall

oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    if not checkcaller() then
        local method = getnamecallmethod()

        if self == LocalPlayer and method == "Kick" then
            return
        end
    end

    return oldNamecall(self, ...)
end)
```

In this example, `getnamecallmethod()` is used to determine which method is being called.

The important part is:

```lua
local method = getnamecallmethod()
```

If the intercepted operation was:

```lua
LocalPlayer:Kick()
```

then the method name would be:

```text
"Kick"
```

The hook can then decide whether to allow the original call to continue.

---

### `__index`

`__index` is related to indexing an object to retrieve a value.

For example:

```lua
local speed = Humanoid.WalkSpeed
```

The `__index` metamethod can be used to intercept this kind of property access.

A simplified example:

```lua
local oldIndex

oldIndex = hookmetamethod(game, "__index", function(self, property)
    if not checkcaller() then
        if self:IsA("Humanoid")
            and self:IsDescendantOf(LocalPlayer.Character)
            and property == "WalkSpeed" then

            return 16
        end

        if self:IsA("Humanoid")
            and self:IsDescendantOf(LocalPlayer.Character)
            and property == "JumpPower" then

            return 50
        end
    end

    return oldIndex(self, property)
end)
```

Here, the hook checks which property is being accessed.

For example:

```lua
local speed = Humanoid.WalkSpeed
```

If the conditions match, the hook can return its own value instead of forwarding the operation to the original `__index`.

---

## So, What's the Difference?

The easiest way to remember it is:

```text
__namecall
    ↓
Method calls
    ↓
object:Method(...)

__index
    ↓
Index/property access
    ↓
object.Property
object["Property"]
```

So, conceptually:

> **`__namecall` is concerned with method calls.**

> **`__index` is concerned with retrieving values through indexing.**

For example:

```lua
LocalPlayer:Kick()
```

is a method call, making `__namecall` relevant.

While:

```lua
Humanoid.WalkSpeed
```

is property access, making `__index` relevant.

---

## What Do They Have in Common?

Both are **metamethods**, meaning they are special methods used by Lua/Luau to customize how certain operations behave.

Both can also be intercepted through `hookmetamethod` in executor environments.

However, they operate at different points:

```text
                 hookmetamethod
                       │
          ┌────────────┴────────────┐
          ↓                         ↓
      __namecall                  __index
          │                         │
     Method calls              Value access
          │                         │
 object:Method()              object.Property
```

The code structure can therefore look very similar:

```lua
local oldMethod

oldMethod = hookmetamethod(game, "__namecall", function(self, ...)
    -- custom logic

    return oldMethod(self, ...)
end)
```

and:

```lua
local oldIndex

oldIndex = hookmetamethod(game, "__index", function(self, property)
    -- custom logic

    return oldIndex(self, property)
end)
```

Notice that both hooks preserve the original behavior by calling the previously stored function when their custom conditions are not met.

---

## A Question to Keep in Mind

Now that you know the basic difference, look back at the examples and ask yourself:

* What changed between the original operation and the hooked operation?
* Which part of the operation is being intercepted?
* What information does each hook receive?
* When should the original behavior still be called?
* What happens if the hook returns a value instead?

Once these questions start making sense, `__namecall` and `__index` become much less mysterious.
## Now... `checkcaller`? What Is That?

You may have noticed that we used `checkcaller()` in the previous examples.

So... what exactly is it?

`checkcaller` is an executor-provided function commonly used to determine whether the currently intercepted call originated from the executor/script environment or from the Roblox environment.

In its simplest form:

```lua
if checkcaller() then
    -- Called from the executor/script side
else
    -- Called from the Roblox side
end
```

This becomes particularly useful when working with hooks.

For example, when a metamethod is hooked, you may not always want your custom logic to affect calls made by your own script. You may only want to react to calls originating from the game itself.

That's where `checkcaller()` can be useful.

```lua
if not checkcaller() then
    -- Handle calls originating outside the executor context
end
```

We'll go into exactly how `checkcaller` behaves, what it returns, and why it is commonly used alongside hooks in a later section.

For now, the important thing to remember is:

> **`checkcaller()` is commonly used to distinguish calls made by the executor/script context from calls originating from the Roblox context.**

> **Note:** `checkcaller` is not part of the standard Roblox API. It is an executor-provided API, and its exact behavior may vary between implementations.

---
