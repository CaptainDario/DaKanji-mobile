
# Da Kanji - changelog

## v 1.2.0 - アニメ
new Features:
- *extremely* fast startup
- [deep linking 'dakanji://dakanji/'](https://github.com/CaptainDario/DaKanji-Mobile#deep-linking)
- animated:
  - double tap on prediction / kanji box
  - character added/deleted to/from kanji box
  - opening a prediction in a web dictionary
  - deleting stroke(s) from canvas
  - drawer
- splash screen

Changes:
- better drawing
- kanji box now shows the last added characters
- use webview instead of default browser
- drawer now indicates current location
- color when pressing on kanji box

-------------------------------------------------------------------------

## v 1.1.0 - 熟語
New Features:
- multi character search
- open prediction in akebi (app)
- open prediction in aedict (app)
- Settings: invert long press/short press behavior
- Settings: delete drawing after double tap
- What's new message

Changes:
- beautiful new icon
- updated themes
- renamed to DaKanji
- Refactoring
- Provide apk on GitHub
- added close button to app download dialogues

Fixes:
- "character copied" message on some devices not showing up 
- UI layout on certain aspect ratios
- show tutorial **only** if there are new features
- blurry buttons in light mode

-------------------------------------------------------------------------

## v 1.0.4
Fixes:
- a localized link to the play store

## v 1.0.3
Fixes:
- opening web dictionaries not working on most devices

## v 1.0.2
Fixes:
- minor fixes to make app release ready

## v 1.0.1
changes:

- use improved AI from DaKanjiRecognizer v1.1
- better image processing before feeding images to CNN

## v 1.0.0 - 初め

features:
- recognize ~3000 kanji characters