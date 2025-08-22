# Fulminant

A simple, gamified learning app built with Flutter. Earn XP, unlock achievements, and climb the
leaderboard while completing short lessons and quizzes.

---

## What is this?

Fulminant makes learning feel like a game. You progress through bite‑sized content, get instant
feedback, and track your growth over time. It’s designed to be lightweight and friendly on low‑end
devices and varying network conditions.

**Highlights**

* 📚 Courses → modules → lessons → quizzes
* 🎯 XP, levels, and achievements
* 🏆 Live leaderboard
* 🔐 Secure sign‑in (Firebase Authentication)
* ☁️ Realtime progress sync (Cloud Firestore)
* 🌙 Light/Dark theme

---

## Install (Android – easiest)

There’s a ready‑to‑use **APK** in the **Releases** section of this repository.

1. Download the latest `Fulminant.apk` from **Releases**.
2. On your Android device, open the file and tap **Install**.
3. If prompted, allow installs from your browser/file manager (one‑time step).
4. Launch **Fulminant** and sign in to start learning.

> **Permissions:** Internet access only. The app connects to the cloud to sign in and sync your
> progress.

---

## FAQ

**Is my data safe?**  Your account is protected by Firebase Authentication. Learning progress is
stored in Cloud Firestore under your account.

**Does it work offline?**  Some screens cache data, but you’ll need a connection to sign in and sync
progress.

**iOS support?**  The codebase is cross‑platform; current public builds focus on Android.

---

## Contributing

Spotted a bug or have a feature idea? Open an issue or a pull request. Please keep PRs small and
focused.

---

## License

**GNU GPL‑3.0**. See the `LICENSE` file for details.

---

## Maintainer

**Sathika Hettiarachchi**
[sathikahettiarachchi219@gmail.com](mailto:sathikahettiarachchi219@gmail.com)

---

*Built with Flutter and Firebase.*
