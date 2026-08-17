# Glider for Hacker News (personal fork)

This is [saviomenifer](https://github.com/SavioMenifer)'s personal fork of [Mosc/Glider](https://github.com/Mosc/Glider), pinned to the pre-v2 (Material 2) design rather than following upstream's v2 redesign. It's maintained for personal use, side-loaded rather than distributed via the Play Store or F-Droid.

Glider is an opinionated Hacker News client. Ad-free, open-source, no-nonsense.

- Browse stories, comments and user profiles
- Catch up on and search stories from any period
- Log in using an existing or new Hacker News account
- Vote on and favorite stories and comments
- Write replies and submit new stories (experimental)
- Collapse comment trees
- No ads, no telemetry
- Extensive theming
- Sensible defaults

<p>
  <img width="164px" src="./fastlane/metadata/android/en-US/images/phoneScreenshots/1.png">
  <img width="164px" src="./fastlane/metadata/android/en-US/images/phoneScreenshots/2.png">
  <img width="164px" src="./fastlane/metadata/android/en-US/images/phoneScreenshots/3.png">
  <img width="164px" src="./fastlane/metadata/android/en-US/images/phoneScreenshots/4.png">
  <img width="164px" src="./fastlane/metadata/android/en-US/images/phoneScreenshots/5.png">
</p>

## Development

Glider is built with the latest stable version of Flutter. Code that can be generated is not included in the repository. Generate it by running `build_runner`:

```sh
flutter pub run build_runner build -d
```
