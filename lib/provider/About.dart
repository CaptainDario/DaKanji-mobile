
import 'package:da_kanji_mobile/provider/PlatformDependentVariables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:da_kanji_mobile/globals.dart';
import 'package:get_it/get_it.dart';



class About with ChangeNotifier{

  String _about;

  bool _initialzied;


  About (){

    _initialzied = false;

    init();
  }
  
  String get about{
    if(!_initialzied)
      throw(Exception(
        "You are trying to use the object before initializing it.\n"
        "Try calling init() first."
      ));
    return _about;
  }


  /// Initializes this [About] object by reading the about.md and replacing all
  /// placeholders with values.
  void init () async {

    _about = await rootBundle.loadString("assets/about.md");

    _about = _about.replaceAll("GITHUB_DESKTOP_REPO", GITHUB_DESKTOP_REPO);
    _about = _about.replaceAll("GITHUB_MOBILE_REPO", GITHUB_MOBILE_REPO);
    _about = _about.replaceAll("GITHUB_ML_REPO", GITHUB_ML_REPO);
    _about = _about.replaceAll("GITHUB_ISSUES", GITHUB_ISSUES);
    _about = _about.replaceAll("PRIVACY_POLICE", PRIVACY_POLICE);

    _about = _about.replaceAll("RATE_ON_MOBILE_STORE", 
      GetIt.I<PlatformDependentVariables>().appStoreLink);
    _about = _about.replaceAll("DAAPPLAB_STORE_PAGE", 
      GetIt.I<PlatformDependentVariables>().daapplabStorePage);

    _about = _about.replaceAll("VERSION", "$VERSION#$BUILD_NR");

    _initialzied = true;
  }
}