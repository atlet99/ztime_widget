///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsRu extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsRu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver);

	/// Metadata for the translations of <ru>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final TranslationsRu _root = this; // ignore: unused_field

	@override 
	TranslationsRu $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsRu(meta: meta ?? this.$meta);

	// Translations
	@override String get appTitle => 'ZTime';
	@override String get settings => 'Настройки';
	@override String get language => 'Язык';
	@override String get langSystem => 'Системный';
	@override String get langRu => 'Русский';
	@override String get langEn => 'Английский';
	@override String get widgetBgStyle => 'Стиль фона виджета';
	@override String get chooseGlassTexture => 'Выберите текстуру стекла для фона виджета';
	@override String get coldGlass => 'Холодное стекло';
	@override String get icyBlue => 'Ледяной голубой';
	@override String get warmMilk => 'Тёплое молоко';
	@override String get batteryOptimization => 'Оптимизация батареи';
	@override String get batteryOptDesc => 'Для корректной работы виджета на Huawei Nova 5T необходимо отключить оптимизацию батареи для ZTime.';
	@override String get openBatterySettings => 'Открыть настройки батареи';
	@override String timeCurrent({required Object time}) => 'Текущее время: ${time}';
}
