# 🌟 `stemday2025` Admin Repository

Welcome to the **CCRI CyberKnights STEM Day CTF Project!** 🎉
This repository powers a custom **Parrot Linux Capture The Flag (CTF)** experience for high school students.

👥 **This repository is for CCRI CyberKnights club members only.**
It contains all of the **source files, admin tools, and scripts** used to build and maintain the student-facing version of the CTF.

> 🛑 **High school participants will never see this repository or its contents.**
> They will interact only with the pre-built *student version* provided in their VM.

---

## 🗂️ Project Overview (Admin Repo)

```
Desktop/
├── CCRI_CTF/                     # Main CTF folder (admin/dev version)
│   ├── challenges/               # Source files for all interactive challenges
│   ├── web_version/              # Student-facing web portal (auto-generated)
│   ├── web_version_admin/        # Admin-only tools and templates
│   ├── Launch CCRI CTF Hub.desktop # Shortcut to launch the student hub
│   ├── (various admin scripts)   # Tools for flag generation, testing, and builds
│   ├── README.md                 # This file
│   └── CONTRIBUTING.md           # Club collaboration guide
└── (misc)                        # Additional admin/dev resources
```

In the **student VM**, only this subset will appear:

```
Desktop/
├── CCRI_CTF/                     # Student bundle (generated from this repo)
│   ├── challenges/               # Interactive CTF challenges
│   ├── web_version/              # Student-facing web portal (ready-to-use)
│   ├── Launch CCRI CTF Hub.desktop # Shortcut to launch the student hub
└── (no admin scripts or source files)
```

The student version is designed to be **self-contained and simple**, with no developer or admin resources visible.

---

## 🚀 Preparing the Student VM

To prepare the student environment:

1. On the **admin account**, run the build script:

   ```bash
   cd CCRI_CTF/web_version_admin/create_website
   ./build_web_version.sh
   ```

   This process will:

   * Obfuscate flags for students.
   * Build the student web portal in `CCRI_CTF/web_version/`.

2. While still in the **admin account**, use the provided script to copy the required files to the student’s Desktop folder and set ownership to the student account:

   ```bash
   ./copy_ccri_ctf.sh
   ```

   This script ensures robust copying and correct permissions.

3. Log in to the **student account** and verify permissions:

   * Right-click **Launch CCRI CTF Hub.desktop → Properties → Permissions**
   * ✅ Enable *“Allow this file to run as a program”*
   * ✅ Ensure the student account has ownership and read/write permissions for all copied files and folders.

4. Test the web portal from the student account to confirm all challenges launch properly.

---

## 🛠 Admin Workflow (Quick Reference)

* 🔄 **Rebuild student hub:**

  ```bash
  cd CCRI_CTF/web_version_admin/create_website
  ./build_web_version.sh
  ```

* 📂 **Copy student bundle to Desktop:**

  ```bash
  ./copy_ccri_ctf.sh
  ```

* 🧪 **Test in admin mode** (full tools) and student mode (restricted tools).

* 🚧 **Keep admin-only flags, scripts, and tools out of `web_version/`.**

* ✅ Use relative paths wherever possible for portability.

---

## 🙌 Club Member Guidelines

✔️ Commit only admin/dev content to this repository.
✔️ Don’t push compiled files (`*.pyc`, `__pycache__/`, etc.) or student builds (`web_version/`).
✔️ Test all new challenges and scripts before release.
✔️ See [CONTRIBUTING.md](CONTRIBUTING.md) for Git workflows and team guidelines.

---

## 🎓 Thank You!

This project exists thanks to the CCRI CyberKnights club’s dedication to creating an engaging and educational cybersecurity experience.

