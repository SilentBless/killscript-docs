---
title: Audio
description: Sound loading, local playback, and voice-chat state.
---

:::note[Current build]
This page describes the API behavior in the current game version.
:::

<span class="api-context api-context--client">Client only</span> The audio API is unavailable in a Reflex module's `server.lua`.

## How audio is processed

`GetSound()` loads an audio clip from the current module's resources. `PlaySound2D()` passes it to the local non-spatial player, while `PlaySound()` creates spatial playback at a world position; the server and other players do not receive that call.

`VoiceChat` controls the local voice-room client's state, while `VoiceLinePlayer` only exposes data from a game voice line that is already playing. A separate built-in HUD module renders its subtitle.

## Where the result is heard or shown

| Call or object | Result |
|---|---|
| `Sounds:GetSound()` | Only loads the resource. It does not play anything yet. |
| `Sounds:PlaySound()` | Locally plays spatial audio from the specified world position. Loudness depends on the distance from the camera. |
| `Sounds:PlaySound2D()` | Locally plays non-spatial audio at equal loudness in both channels. |
| `VoiceChat:SetMuted()` / `ToggleMuted()` | Only changes whether the local player hears the selected agent. It does not show a separate on-screen confirmation. |
| `VoiceLinePlayer.Subtitle` | Only returns the current text. The built-in `HudSubtitles` module renders standard subtitles in the lower part of the screen. |

The standard subtitle window is horizontally centered at roughly 75% of the screen height. Players can move it in the HUD editor; if `HudSubtitles` is disabled or replaced, the property still works but the standard text is not shown.

## Quick example

Place `Alert.wav` in the module's `sounds` directory:

```lua
local sound = Sounds:GetSound("Alert.wav")

if sound ~= nil then
    Sounds:PlaySound2D(sound, 0.7, 1)
end
```

## Sound

A loaded sound resource passed to `Sounds` methods.

## Sounds

Global API for loading and playing sounds.

### GetSound

```lua
Sounds:GetSound(soundName: string): Sound
```

Looks for a file in the current module's `sounds` directory. Include the extension but not the directory path. Supported formats are `.wav`, `.mp3`, and `.ogg`. Returns `nil` for a missing file.

| Parameter | Type | Optional | Description |
|---|---|:---:|---|
| `soundName` | string |  | File name, such as `Alert.wav`. |

**Returns:** [Sound](../audio/#sound) or nil

### PlaySound

```lua
Sounds:PlaySound(
    sound: Sound,
    position: Vector3,
    volume: number = 1,
    minDistance: number = 5,
    maxDistance: number = 500,
    pitch: number = 1
)
```

Plays a spatial sound at the specified world position. The call returns `nil`.

| Parameter | Type | Optional | Description |
|---|---|:---:|---|
| `sound` | [Sound](../audio/#sound) |  | Loaded sound resource. |
| `position` | [Vector3](../vector3/) |  | Source position in world coordinates. |
| `volume` | number | ✅ | Sound volume. |
| `minDistance` | number | ✅ | Distance within which the sound stays at full volume. |
| `maxDistance` | number | ✅ | Distance by which the sound fades out. |
| `pitch` | number | ✅ | Playback pitch and speed. |

### PlaySound2D

```lua
Sounds:PlaySound2D(sound: Sound, volume: number = 1, pitch: number = 1)
```

Plays a sound without spatial positioning. The call returns `nil`.

| Parameter | Type | Optional | Description |
|---|---|:---:|---|
| `sound` | [Sound](../audio/#sound) |  | Loaded sound resource. |
| `volume` | number | ✅ | Volume from `0` to `1`. |
| `pitch` | number | ✅ | Playback pitch and speed. |

## VoiceChat

Voice-chat state for a specified agent.

### IsAvailable

```lua
VoiceChat:IsAvailable(agent: Agent): bool
```

Returns true if the agent is available in the current voice room. Returns false while the voice connection is unavailable.

### IsMuted

```lua
VoiceChat:IsMuted(agent: Agent): bool
```

Returns the agent's local mute state.

### IsSpeaking

```lua
VoiceChat:IsSpeaking(agent: Agent): bool
```

Returns true while the agent is speaking in an available voice room.

### SetMuted

```lua
VoiceChat:SetMuted(agent: Agent, muted: bool): bool
```

Locally mutes or unmutes the agent. Returns true when EOS accepts the state-change request. Returns false if the agent is unavailable, the voice room is disconnected, or the request cannot be submitted.

### ToggleMuted

```lua
VoiceChat:ToggleMuted(agent: Agent): bool
```

Reads the current local state, toggles it, and returns the request result. Returns false on failure.

:::tip
Check `VoiceChat:IsAvailable(agent)` before changing the state. Muting is local: it only controls whether you hear that player.
:::

For all methods, `agent` is an [Agent](../agent/#agent).

## VoiceLinePlayer

State of the built-in voice-line player.

### Properties

| Property | Type | Access | Description |
|---|---|---|---|
| `IsPlaying` | bool | `get` | true while a voice line is playing. |
| `Subtitle` | string | `get` | Subtitle text for the current voice line. |
