# DaKanji Mobile
<img src="./media/banner.png" style="display:block;margin-left:auto;margin-right:auto;" width="40%"/>
<table>
  <tr>
    <a href='https://play.google.com/store/apps/details?id=com.DaAppLab.DaKanjiRecognizer&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1' width="250"><img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png'  width="20%"/></a>
   <tr/>
   <tr>

   <tr/>
<table/>

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
You can also [setup a development environment](#development) and build the app on your own.

## Usage
In this section the features of the app are explained in more detail.
### Handwritten kanji recognition
The user can draw a character in the UI and the app will predict which character was drawn. This prediction can than be opened in a dictionary of choice. The used dictionary can be set in the settings.
It is also possible to use a translation app of the used device.
A custom website can also be used with an input field in the settings menu.</br>
Currently around 3000 characters are supported. 
All supported characters can be found [here](https://github.com/CaptainDario/DaKanji-Mobile/blob/main/assets/labels_CNN_kanji_only.txt).</br>

### Next steps and ideas
If you have a good idea how to improve this app feel free to [to open an issue](https://github.com/CaptainDario/DaKanji-Mobile/issues).

## Development
This app was developed using dart, the flutter framework and Tensorflow.
Tensorflow was used for the machine learning part.
This project can be found [here](https://github.com/CaptainDario/DaKanji-ML). </br>
For developing new features this repository has to be downloaded and all necessary packages have to be installed with:

```{bash}
flutter pub get
```

Additionally the tflite models need to be copied from the [Machine Learning](https://github.com/CaptainDario/DaKanji-ML) repo.
Go to [the release page](https://github.com/CaptainDario/DaKanji-ML/releases) and download the models.

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

and platform dependent, smaller apks:
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
* icon: 
  * "Buddha, with kudos to 2ch/fl/ and HatNyan" and a font from [Adrian Jordanov](https://www.1001fonts.com/theater-font.html)
