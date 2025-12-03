# ONX Lightbar

A dynamic emergency vehicle lightbar system that automatically attaches and detaches lightbars.

## Quick Start

For most users, this resource works right out of the box - simply install and go! The lightbar system will automatically detect emergency vehicles and handle everything for you.

**Framework Integration**: If you're using a custom framework that handles vehicle spawning differently (like ESX, QB-Core with modifications, etc.), you may need to make some adjustments to ensure compatibility.

## Configuration

### Basic Settings

All main settings can be found in `shared/config.lua`:

| Setting                     | What it does                                                       | Default |
| --------------------------- | ------------------------------------------------------------------ | ------- |
| `disablePoliceScannerAudio` | Turns off emergency radio chatter in police vehicles               | `false` |
| `disableGhostSirens`        | Stops distant siren sounds from other emergency vehicles           | `true`  |
| `enableSirenCollision`      | Makes the lightbar physical (can be bumped into)                   | `true`  |
| `checkIntervalSpeed`        | How often the system checks for lightbar changes (in milliseconds) | `250`   |
| `debug`                     | Shows technical information in console (F8) for troubleshooting    | `false` |

## Advanced Setup (Framework Integration)

If you're using a custom framework or experiencing issues with vehicle spawning/deletion, you may need to modify these files:

### Client-Side Integration (`client/public.lua`)

**Vehicle Spawning**:

- Update the `spawnVehicle` function with your framework's vehicle spawning method
- The function receives `modelHash`, `coords`, and `heading` parameters
- Must return the vehicle's entity handle when successful, or `0` if spawning fails
- For server-side spawning, make sure to wait for the server response before returning

**Vehicle Deletion**:

- Update the `deleteVehicle` function to work with your framework's deletion method
- Receives the vehicle `handle` as a parameter

### Server-Side Integration (`server/public.lua`)

**Vehicle Deletion**:

- Similar to the client version but handles server-side vehicle deletion
- Update this if your framework requires server-side deletion logic
- Receives the vehicle `handle` as a parameter

## Troubleshooting

**Common Issues**:

- **Lightbars not appearing**: Check if your framework overrides vehicle spawning
- **Performance issues**: Increase the `checkIntervalSpeed` value in config
- **Collision problems**: Try disabling `enableSirenCollision`
- **Audio issues**: Toggle `disablePoliceScannerAudio` or `disableGhostSirens`

**Getting Help**:

- Enable `debug` mode in the config to see detailed console output
- Restart the resource
- Check the F8 console for any error messages
- Ensure you're using the latest version of the resource

## Important Notes

- **Keep Updated**: We regularly release fixes and optimizations, so updating is recommended
- **Custom Requests**: We don't provide custom modifications or feature requests
- **Compatibility**: Works with most frameworks out of the box, but custom setups may require minor modifications
