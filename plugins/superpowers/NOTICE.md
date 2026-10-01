# Notice

This directory holds a vendored copy of the Superpowers plugin.

- **Origin:** [obra/superpowers](https://github.com/obra/superpowers) by Jesse Vincent, MIT.
- **Upstream of this copy:** [BlastBlastBlast/more_superpowers](https://github.com/BlastBlastBlast/more_superpowers).
- **Vendored version:** 6.3.0
- **Source commit:** 6f092bd33347982ec2dab58e82a52e4a32ed4423
- **Modified:** yes. The copy carries changes that are not in `obra/superpowers`, and omits non-essential content.

**Omitted:** The `docs/` directory and `RELEASE-NOTES.md` from the upstream project. These are the upstream project's own change records and planning documentation, which the plugin does not load at runtime. Release notes for the full upstream project are available at [obra/superpowers](https://github.com/obra/superpowers).

`LICENSE` is the upstream MIT licence, unchanged. The plugin keeps the name `superpowers`,
because every skill reference in this setup reads `superpowers:<skill>`.

To refresh this copy, pull `more_superpowers` and copy it here again (excluding `.git`,
`docs/`, and `RELEASE-NOTES.md`).
