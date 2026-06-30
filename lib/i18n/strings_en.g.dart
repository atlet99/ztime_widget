///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  );

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// en: 'ZTime'
	String get appTitle => 'ZTime';

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'System'
	String get langSystem => 'System';

	/// en: 'Russian'
	String get langRu => 'Russian';

	/// en: 'English'
	String get langEn => 'English';

	/// en: 'Widget Background Style'
	String get widgetBgStyle => 'Widget Background Style';

	/// en: 'Choose a glass texture for the widget background'
	String get chooseGlassTexture => 'Choose a glass texture for the widget background';

	/// en: 'Cold Glass'
	String get coldGlass => 'Cold Glass';

	/// en: 'Icy Blue'
	String get icyBlue => 'Icy Blue';

	/// en: 'Warm Milk'
	String get warmMilk => 'Warm Milk';

	/// en: 'Add Widget'
	String get addWidget => 'Add Widget';

	/// en: 'Place the clock widget on your home screen'
	String get addWidgetDesc => 'Place the clock widget on your home screen';

	/// en: 'Battery Optimization'
	String get batteryOptimization => 'Battery Optimization';

	/// en: 'For the widget to work correctly on Huawei Nova 5T, disable battery optimization for ZTime.'
	String get batteryOptDesc => 'For the widget to work correctly on Huawei Nova 5T, disable battery optimization for ZTime.';

	/// en: 'For the widget to update reliably, consider disabling battery optimization for ZTime.'
	String get batteryOptDescGeneric => 'For the widget to update reliably, consider disabling battery optimization for ZTime.';

	/// en: 'Open Battery Settings'
	String get openBatterySettings => 'Open Battery Settings';

	/// en: 'Current time: $time'
	String timeCurrent({required Object time}) => 'Current time: ${time}';

	/// en: 'About'
	String get about => 'About';

	/// en: 'ZTime Widget — custom clock widget for Android.'
	String get aboutDesc => 'ZTime Widget — custom clock widget for Android.';

	/// en: 'Version $version'
	String version({required Object version}) => 'Version ${version}';

	/// en: 'View on GitHub'
	String get viewOnGithub => 'View on GitHub';
}
