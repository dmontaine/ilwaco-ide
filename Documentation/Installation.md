# Installing Ilwaco IDE

Ilwaco ships in three forms. They all install the same IDE — the difference is only how your system
prefers to receive it, and whether you are allowed to install software on the machine.

Everything Ilwaco needs to compile FreeBASIC is **already inside the download**, including the
compiler and linker. You do not have to install FreeBASIC, a compiler, or any `-dev` packages.

---

## Which download do I want?

| Your situation | Download | Needs an admin password? |
| --- | --- | --- |
| Debian, Ubuntu or Linux Mint, and you can install software | `ilwaco-ide_1.3.8_amd64.deb` | Yes |
| Fedora, RHEL or openSUSE, and you can install software | `ilwaco-ide-1.3.8-1.x86_64.rpm` | Yes |
| **A school or work laptop where you are not an administrator**, or any other Linux | `Ilwaco-IDE-1.3.8-x86_64.tar.gz` | **No** |

If you are unsure, take the **`.tar.gz`**. It works everywhere and never asks for a password.

### Will it run on my machine?

You need a 64-bit x86 PC, a graphical desktop with GTK 3 (every mainstream desktop has it), and a
system from roughly 2021 onward. Concretely, these all work:

Debian 12+ · Ubuntu 22.04+ · Linux Mint 21+ · Fedora 35+ · RHEL/Rocky/Alma 9+ · openSUSE Leap 15.5+

Older systems — Ubuntu 20.04, Debian 11, RHEL 8 — are **too old** and Ilwaco will not start on them.

---

## Method 1 — `.tar.gz` (no admin password)

1. Download `Ilwaco-IDE-1.3.8-x86_64.tar.gz`.
2. **Right-click it and choose "Extract Here"** (on some desktops: "Extract to…" or "Open With
   Archive Manager → Extract"). A file called `Ilwaco-IDE-1.3.8-x86_64.AppImage` appears next to it.
3. **Double-click that `.AppImage`.** Ilwaco starts.

**You do not need to make anything executable**: the file comes out of the archive ready to run,
which is exactly why it is packed in a `.tar.gz` rather than offered on its own.

> **If you double-click the `.tar.gz` instead**, an archive *viewer* opens and lists the AppImage
> inside it. **Clicking the AppImage in that window does nothing** — a viewer shows you what is in an
> archive, it does not run it. Use its **Extract** button (or close it and right-click → *Extract
> Here*), then double-click the AppImage that appears in the folder. This trips people up; it is not
> a sign anything is wrong.

After the first launch, Ilwaco adds itself to your applications menu, so from then on you can start it
the same way as any other program. Keep the `.AppImage` file where you put it — the menu entry points
at it, and moving it means launching it once from its new home to fix the entry.

Prefer the terminal?

```bash
tar -xzf Ilwaco-IDE-1.3.8-x86_64.tar.gz && ./Ilwaco-IDE-1.3.8-x86_64.AppImage
```

---

## Method 2 — `.deb` (Debian, Ubuntu, Mint)

Double-click `ilwaco-ide_1.3.8_amd64.deb`, click **Install** in the window that opens, and enter your
password when asked. Ilwaco then appears in your applications menu.

If your desktop does not offer to install it, or you prefer the terminal:

```bash
sudo apt install ./ilwaco-ide_1.3.8_amd64.deb
```

Use `apt install ./file.deb` rather than `dpkg -i` — the leading `./` matters, and `apt` will pull in
anything missing, while `dpkg` would just report the problem and stop.

---

## Method 3 — `.rpm` (Fedora, RHEL, openSUSE)

Double-click `ilwaco-ide-1.3.8-1.x86_64.rpm` and click **Install**, or use the terminal:

```bash
sudo dnf install ./ilwaco-ide-1.3.8-1.x86_64.rpm
```

On openSUSE:

```bash
sudo zypper install ./ilwaco-ide-1.3.8-1.x86_64.rpm
```

---

## Where your work lives

However you installed it, the first time Ilwaco starts it creates a folder in your home directory:

```
~/ilwaco-ide/
    projects/        your work — new projects are created here by default
    Examples/        54 ready-to-run example projects, yours to edit
    Settings/        your preferences, themes and window layout
    Documentation/   this and the other guides
    Templates/       the skeletons New Project builds from
```

**This folder belongs to you.** Everything you create or change lives here, and nothing else does.
The `.deb` and `.rpm` put the unchanging parts of Ilwaco in `/opt/ilwaco-ide`, which is owned by the
system and which you never need to look at.

Each person who uses the computer gets their own `~/ilwaco-ide`, created automatically the first time
they start Ilwaco. There is nothing to configure.

---

## Upgrading — your work is never touched

Installing a newer Ilwaco over an older one **cannot** alter anything in `~/ilwaco-ide`. Your
projects, your edited examples and your settings all survive, and you keep any preferences you
changed. Only the program itself is replaced.

This is guaranteed three ways over, not just intended:

- the `.deb` and `.rpm` contain **no files under any home directory at all**, so the package manager
  has nothing there it *could* overwrite;
- their install scripts only refresh the system's menu and icon caches;
- when Ilwaco starts, it fills in `~/ilwaco-ide` only where something is **missing** — an existing
  folder is left exactly as it is.

Tested by planting a project and a custom setting, then reinstalling over the top: the project files
came back byte-for-byte identical and the custom setting was still there.

To upgrade, just install the new version the same way you installed the first one. For the
`.tar.gz`, extract the new AppImage and delete the old one.

---

## Uninstalling

| Installed with | Remove it with |
| --- | --- |
| `.deb` | `sudo apt remove ilwaco-ide` |
| `.rpm` | `sudo dnf remove ilwaco-ide` (or `sudo zypper remove ilwaco-ide`) |
| `.tar.gz` | delete the `.AppImage` file |

**Your `~/ilwaco-ide` folder is deliberately left behind**, because it contains your projects.
Delete it yourself if you really want everything gone.

---

## If something goes wrong

**Double-clicking the AppImage does nothing.** The file lost its executable flag — this should not
happen when you extract from the `.tar.gz`, but if it does, right-click it → **Properties** →
**Permissions** → tick **Allow executing file as program**. Or in a terminal:
`chmod +x Ilwaco-IDE-1.3.8-x86_64.AppImage`.

**"Cannot mount AppImage, please check your FUSE setup".** Your system is missing the small helper
AppImages use. Either install it — `sudo apt install fuse3` (or `sudo dnf install fuse3`) — or skip it
entirely by running:

```bash
APPIMAGE_EXTRACT_AND_RUN=1 ./Ilwaco-IDE-1.3.8-x86_64.AppImage
```

**The package manager refuses to install, mentioning `libc6` or a version number.** Your system is
older than Ilwaco supports — see "Will it run on my machine?" above. Use a newer system; there is no
way around this one.

**"Ilwaco IDE needs a graphical desktop, but no display was found".** Ilwaco is a graphical program
and cannot run on a machine with no desktop, or over a plain SSH connection. Start it from the
computer's own screen, or reconnect with `ssh -X` so the display is forwarded.

**Ilwaco starts but a program you build will not run in a terminal window.** See
[IlwacoIDEManual.md](IlwacoIDEManual.md).

---

## For maintainers

How these three artefacts are built, and why the split is the way it is, is in `Documentation/
Packaging.md` **in the source repository** (it is not shipped with the application). The short
version: `Packaging/BuildInstaller.sh --all` stages a release tree and produces all three.
