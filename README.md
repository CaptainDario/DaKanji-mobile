# DaKanji Mobile
[![Discord](https://img.shields.io/discord/852915748300783636.svg?label=&logo=discord&logoColor=ffffff&color=7389D8&labelColor=6A7EC2)](https://discord.gg/cYTcpFStbs)

<table style="table-layout: fixed ; width: 100% ;">
  <tr>
    <td>
      <img src="https://raw.githubusercontent.com/CaptainDario/DaKanji-Mobile/main/media/banner.png" style="display:block;margin-left:auto;margin-right:auto;"/>
      </a>
    </td>
    <td\>
    <td\>
    <td\>
    <td\>
  </tr>
    <td>
      <a href='https://play.google.com/store/apps/details?id=com.DaAppLab.DaKanjiRecognizer&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png'/>
      </a>
    </td>
    <td>
      <a href='//www.microsoft.com/store/apps/9n08051t2xtv?cid=storebadge&ocid=badge'><img src='https://developer.microsoft.com/store/badges/images/English_get-it-from-MS.png' alt='English badge' width="75%"/></a>
    </td>
    <td>
    </td>
    <td>
    </td>
    <td>
    </td>
  </tr>
</table>

## What is this
This is the mobile version of DaKanji.
The desktop version is available [here](https://github.com/CaptainDario/DaKanji-Desktop). </br>
This app tries to help students and people which use the Japanese language.
It can recognize Japanese 'kanji' characters which the user draws by hand.
Those predictions can than be automatically opened in dictionaries.
For more details about the features take a look at the [usage section](#usage).
</br>
<img src="./media/preview.gif" style="display:block;margin-left:auto;margin-right:auto;" width="20%"/>
</br>

## Getting started
**Currently only android is supported** </br>
The easiest way is to download the app for android from the PlayStore.
You can also download the latest release from the [releases page](https://github.com/CaptainDario/DaKanji-Mobile/releases) or [setup a development environment](#development) and build the app on your own.

## Usage
In this section the features of the app are explained in more detail.
### Handwritten kanji recognition
The user can draw a character in the UI and the app will predict which character was drawn. This prediction can than be opened in a dictionary of choice. A dictionary can be chosen in the settings.
It is also possible to use a translation app or custom URL can be defined in the settings menu.</br>
Currently around 3000 characters are supported. 
All supported characters can be found [here](https://github.com/CaptainDario/DaKanji-Mobile/blob/main/assets/labels_CNN_kanji_only.txt).</br>

### Next steps and ideas
If you think you have a good idea how to improve this app feel free [to open an issue](https://github.com/CaptainDario/DaKanji-Mobile/issues).

## Development

### building the app
To build the app as app bundle just invoke
```
flutter build appbundle
```

To obfuscate, save the symbol files and build the app.
```{bash}
flutter build appbundle --obfuscate --split-debug-info=obfuscate_debug_info
```

To build an fat apk:
```
flutter build apk --obfuscate --split-debug-info=obfuscate_debug_info
```

and platform dependent, smaller apk's:
```
flutter build apk --split-per-abi --obfuscate --split-debug-info=obfuscate_debug_info
```

#### Updating the icons
For updating the icons the [flutter_launcher_icons package](https://pub.dev/packages/flutter_launcher_icons/versions/0.8.1) was used.
To update all icons, replace `media/icon.png` and run:
```
flutter pub run flutter_launcher_icons:main
```

## Credits
* design and UI: Massive shout out to [Ellina](https://github.com/nurellina)! Without your help the app would not look and feel half as good as it does now.
* icon/banner: 
  * Thanks "Buddha, with kudos to 2ch/fl/ and HatNyan" for helping with the icon design and making the banner. Also thank you [Adrian Jordanov](https://www.1001fonts.com/theater-font.html) for the banner font.
* Modified Packages: [bitmap](https://github.com/renancaraujo/bitmap), [snappable](https://github.com/MarcinusX/snappable) 
