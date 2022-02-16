import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zebra_scanner/core/constants.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(translate.core.changeLanguage.title),
      children: <Widget>[
        for (AppLocale language in AppLocale.values)
          RadioButton(
            text: translate.core.changeLanguage.languages[language.name]!,
            value: language.name,
          ),
      ],
    );
  }
}

class RadioButton extends StatelessWidget {
  final String text;
  final String value;

  const RadioButton({
    Key? key,
    required this.text,
    required this.value,
  }) : super(key: key);

  changeLanguage(BuildContext context) async {
    Navigator.pop(context);
    LocaleSettings.setLocale(AppLocale.values.byName(value));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(LocalStorageKeys.languageKey, value);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text),
      onTap: () => changeLanguage(context),
      leading: Radio<String>(
        value: value,
        groupValue: LocaleSettings.currentLocale.name,
        onChanged: (_) => changeLanguage(context),
      ),
    );
  }
}
