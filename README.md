<div align="center">
  <h1>If I Remember Correctly (IIRC)</h1>
  <strong>For keeping track of important recurring events.</strong>
  <br />
  <sub>Built with ❤︎ by <a href="https://twitter.com/jogboms">jogboms</a></sub>
  <br /><br />

[![Format, Analyze and Test](https://github.com/jogboms/iirc/actions/workflows/main.yml/badge.svg?branch=master)](https://github.com/jogboms/iirc/actions/workflows/main.yml) [![codecov](https://codecov.io/gh/jogboms/iirc/branch/master/graph/badge.svg)](https://codecov.io/gh/jogboms/iirc)

  <a href='https://play.google.com/store/apps/details?id=io.github.jogboms.iirc'><img alt='Get it on Google Play' src='./screenshots/google_play.png' height='36px'/></a>
</div>

---

## Getting Started

After cloning,

### FVM setup

Install `fvm` if not already installed.

```bash
dart pub global activate fvm
```

Install local `flutter` version.

```bash
fvm install
```

### Install, L10n & Riverpod code generation

```bash
fvm flutter pub get 
fvm flutter gen-l10n
fvm flutter pub run build_runner build
```

## Running

There are three (3) available environments:
- `mock`: Demo mode with non-persistent data
- `dev`: Development mode connected to firebase dev instance
- `prod`: Production mode connected to firebase production instance

To run in `mock` mode,

```bash
fvm flutter run --flavor mock --dart-define=env.mode=mock
```

## UI Shots

<div style="text-align: center">
  <table>
    <tr>
      <td style="text-align: center">
        <img src="./screenshots/01_light.png" width="200" />
      </td>
      <td style="text-align: center">
        <img src="./screenshots/02_light.png" width="200" />
      </td>
      <td style="text-align: center">
        <img src="./screenshots/03_light.png" width="200" />
      </td>
      <td style="text-align: center">
        <img src="./screenshots/04_light.png" width="200" />
      </td>
      <td style="text-align: center">
        <img src="./screenshots/05_light.png" width="200" />
      </td>
    </tr>
    <tr>
      <td style="text-align: center">
        <img src="./screenshots/01_dark.png" width="200" />
      </td>
      <td style="text-align: center">
        <img src="./screenshots/02_dark.png" width="200" />
      </td>
      <td style="text-align: center">
        <img src="./screenshots/03_dark.png" width="200" />
      </td>
      <td style="text-align: center">
        <img src="./screenshots/04_dark.png" width="200" />
      </td>
      <td style="text-align: center">
        <img src="./screenshots/05_dark.png" width="200" />
      </td>
    </tr>
  </table>
</div>

## License

MIT License
