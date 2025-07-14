# 🌟 `stemday2025` Contributor Guide (Admin-Only)

Welcome to the **CCRI CyberKnights STEM Day VM Project!** 🎉
This repository powers a custom **Parrot Linux Capture The Flag (CTF)** experience for high school students.

👥 **This repo is for CCRI CyberKnights club members only.**
It contains all the source files, admin tools, and workflows for building and maintaining the **student-facing bundle**.

> 📜 **Note:** Students will receive a **separate public bundle** with only the CTF challenges and launcher. They will never see this admin repository.

*Hint the easiest way to contribute to this project is to run Parrot OS Home or Security so that things are mostly the same to how the STEM Day VM is built, we are still working on support for other distros*
---

## 🚀 Getting Started as a Contributor

1. **Join the CCRI GitHub Organization**

   * Contact **Corey (Tolgar)** with your GitHub username.
   * Corey will invite you to the private **CCRI-Cyberknights** GitHub organization.
   * Accept the invitation in your GitHub notifications or email.

2. **Clone the Repository**

   ```bash
   git clone https://github.com/CCRI-Cyberknights/stemday_2025.git
   cd stemday2025
   ```

3. **Install Required Tools**

   Run this in your admin VM:

   ```bash
   sudo apt update
   sudo apt install -y \
     git python3 python3-pip python3-venv python3-markdown python3-scapy \
     exiftool zbar-tools steghide hashcat unzip nmap tshark qrencode
   ```

4. **Configure Git (First Time Only)**

   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   git config --global credential.helper store
   ```

---

## 🛠 Contributor Workflow

### 🌱 Create a Feature Branch

```bash
git checkout -b feature/my-changes
```

### 📝 Develop and Test

* Add or modify **challenges**, **admin tools**, or **student hub logic**.
* Test your changes in:

  * **Admin mode** (full tools available).
  * **Student mode** (obfuscated hub, no admin scripts).

### 🔄 Build the Student Bundle

To generate the student-facing version:

```bash
cd CCRI_CTF/web_version_admin
./build_web_version.sh
```

This creates an obfuscated student hub in `CCRI_CTF/web_version/`.

### 💾 Commit and Push Your Changes

```bash
git add .
git commit -m "Add new challenge: QR Codes"
git push origin feature/my-changes
```

### 🔀 Open a Pull Request (PR)

1. Go to the repo on GitHub.
2. Click **“Compare & pull request.”**
3. Add a clear description of your changes.
4. Submit for review and merging.

---

## 📂 Key Scripts and Tools

* **`build_web_version.sh`**
  Creates the student-facing portal in `web_version/`. Obfuscates flags and removes admin-only tools.

* **`start_web_hub.sh`**
  Unified launcher for the web portal. Automatically detects **admin mode** (`web_version_admin`) or **student mode** (`web_version`).

* **`stop_web_hub.sh`**
  Gracefully stops the Flask web server and any simulated services.

* **`copy_ccri_ctf.sh`**
  Copies the prepared student bundle to the student account Desktop and sets ownership/permissions.

---

## 🛡️ Contributor Guidelines

✔️ Keep admin-only flags, scripts, and tools **out of `web_version/`**
✔️ Use **relative paths** for all scripts and assets.
✔️ Don’t commit generated `.pyc` files, `__pycache__/`, or student builds.
✔️ Test all scripts in both **admin mode** and **student mode**.
✔️ Follow consistent naming conventions for challenges and helper scripts.

---

## 🎓 About the Student Bundle

Students will receive a **self-contained folder** with only the challenges and student hub launcher.
They **cannot see admin scripts or source files** from this repository.

---

## 🙌 Thank You

Your contributions make the CCRI CyberKnights STEM Day CTF possible! 🚀
