# TRIO Market City: AI Workforce World

Browser-based TRIO workforce simulation with a web UI shell and a Godot-powered 3D city.

## Project Structure

- `index.html`, `main.js`, `styles.css`: main browser shell and gameplay UI
- `godot/`: Godot source project
- `godot/build/web/`: exported Godot web build
- `godot-build/`: wrapper page that embeds the exported Godot app
- `assets/`: supporting static assets for the shell

## Local Preview

From the project root, serve the folder with any static file server and open `index.html`.

Example:

```bash
python3 -m http.server 4321
```

Then open `http://127.0.0.1:4321/`.

## Deployment

This repo is set up to deploy directly from the `main` branch on GitHub Pages using the repository root.

After the first push:

1. Open the repository settings on GitHub.
2. Go to `Pages`.
3. Confirm the source is `Deploy from a branch`.
4. Set the branch to `main` and the folder to `/ (root)`.
5. Save and wait for GitHub Pages to publish.

## Notes

- The committed `godot/build/web/` export is what GitHub Pages serves.
- If the Godot scene changes, rebuild the web export before committing.
