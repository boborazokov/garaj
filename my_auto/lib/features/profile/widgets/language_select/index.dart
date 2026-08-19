import 'package:flutter/material.dart';
import 'package:my_auto/core/provider/language/index.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:provider/provider.dart';

void selectLanguage(BuildContext context) {
  final localeNotifier = context.read<LocaleNotifier>();

  final List<Map<String, String>> languages = [
    {
      'label': 'English (US)',
      'code': 'en',
      'flag': '🇺🇸',
    },
    {
      'label': 'Русский',
      'code': 'ru',
      'flag': '🇷🇺',
    },
    {
      'label': 'Oʻzbek',
      'code': 'uz',
      'flag': '🇺🇿',
    },
  ];

  String selected = localeNotifier.locale?.toString() ?? 'en';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context).language,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 24),
            ...languages.map(
              (lang) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: Text(
                  lang['flag']!,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  lang['label']!,
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: Radio<String>(
                  value: lang['code']!,
                  groupValue: selected,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selected = value;
                    });

                    _applyLocale(localeNotifier, value);

                    Future.delayed(const Duration(milliseconds: 300), () {
                      Navigator.pop(context);
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    selected = lang['code']!;
                  });

                  _applyLocale(localeNotifier, selected);

                  Future.delayed(const Duration(milliseconds: 300), () {
                    Navigator.pop(context);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _applyLocale(LocaleNotifier notifier, String code) {
  notifier.setLocale(code);
}

String getLanguageFlag(String code) {
  switch (code) {
    case 'en':
      return '🇺🇸';
    case 'ru':
      return '🇷🇺';
    case 'uz':
      return '🇺🇿';

    default:
      return '🌐';
  }
}

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final localeNotifier = Provider.of<LocaleNotifier>(context);

    return DropdownButton<String>(
      value: localeNotifier.locale?.languageCode ?? 'en',
      items: const [
        DropdownMenuItem(value: 'en', child: Text("English")),
        DropdownMenuItem(value: 'ru', child: Text("Русский")),
        DropdownMenuItem(value: 'uz', child: Text("Oʻzbekcha")),
      ],
      onChanged: (value) {
        if (value != null) {
          localeNotifier.setLocale(value);
        }
      },
    );
  }
}
