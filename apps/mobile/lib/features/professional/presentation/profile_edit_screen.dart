import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/professional.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/jurisdiction/country_directory.dart';
import '../../../domain/professional/professional_models.dart';
import '../professional_strings.dart';
import 'professional_widgets.dart';
import 'verification_screens.dart';

/// Talaba yoki professional profil formasi (joriy foydalanish rejimiga
/// ko‘ra). Ma’lumot faqat qurilmada saqlanadi. Professional profilni
/// to‘ldirish professional maqom bermaydi.
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _name = TextEditingController();
  final _institution = TextEditingController();
  final _faculty = TextEditingController();
  final _city = TextEditingController();
  final _organization = TextEditingController();
  final _position = TextEditingController();
  final _education = TextEditingController();
  final _years = TextEditingController();
  final _email = TextEditingController();
  final _license = TextEditingController();
  final _bio = TextEditingController();
  final _languages = TextEditingController();
  final _interests = TextEditingController();

  late UserMode _mode;
  String? _country;
  StudentRole _studentRole = StudentRole.student;
  ProfessionalRole _proRole = ProfessionalRole.forensicExpert;
  StudyLevel? _studyLevel;
  Specialty _primary = Specialty.forensicToxicology;
  final Set<Specialty> _additional = {};
  final Set<Specialty> _studentInterests = {};
  bool _showOrganization = false;
  Map<ProfileField, ProfileFieldError> _errors = const {};

  /// Professional profil — 3 bosqich (0..2).
  int _step = 0;
  static const _steps = 3;

  static const _stepFields = [
    {ProfileField.fullName, ProfileField.country},
    {
      ProfileField.organization,
      ProfileField.position,
      ProfileField.education,
      ProfileField.yearsExperience,
      ProfileField.workEmail,
    },
    {ProfileField.bio},
  ];

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsControllerProvider);
    _mode = settings.userMode ?? UserMode.student;
    final p = ref.read(localProfileProvider);
    final s = p.student;
    final pro = p.professional;
    if (_mode == UserMode.student) {
      _studentRole =
          StudentRole.values.asNameMap()[settings.declaredRole] ??
          s?.role ??
          StudentRole.student;
      if (s != null) {
        _name.text = s.fullName;
        _country = s.country.isEmpty ? null : s.country;
        _institution.text = s.institution ?? '';
        _faculty.text = s.faculty ?? '';
        _studyLevel = s.studyLevel;
        _studentInterests.addAll(s.interests);
      }
    } else {
      _proRole =
          ProfessionalRole.values.asNameMap()[settings.declaredRole] ??
          pro?.role ??
          ProfessionalRole.forensicExpert;
      if (pro != null) {
        _name.text = pro.fullName;
        _country = pro.country.isEmpty ? null : pro.country;
        _city.text = pro.city ?? '';
        _organization.text = pro.organization;
        _position.text = pro.position;
        _education.text = pro.education;
        _primary = pro.primarySpecialty;
        _additional.addAll(pro.additionalSpecialties);
        _years.text = pro.yearsExperience?.toString() ?? '';
        _email.text = pro.workEmail ?? '';
        _license.text = pro.licenseNumber ?? '';
        _bio.text = pro.bio ?? '';
        _languages.text = pro.languages.join(', ');
        _interests.text = pro.interests ?? '';
        _showOrganization = pro.showOrganizationPublicly;
      }
    }
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _institution,
      _faculty,
      _city,
      _organization,
      _position,
      _education,
      _years,
      _email,
      _license,
      _bio,
      _languages,
      _interests,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _opt(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  ProfessionalProfile _proProfile() => ProfessionalProfile(
    fullName: _name.text.trim(),
    country: _country ?? '',
    organization: _organization.text.trim(),
    position: _position.text.trim(),
    primarySpecialty: _primary,
    education: _education.text.trim(),
    role: _proRole,
    city: _opt(_city),
    additionalSpecialties: _additional.where((s) => s != _primary).toList(),
    yearsExperience: int.tryParse(_years.text.trim()),
    workEmail: _opt(_email),
    licenseNumber: _opt(_license),
    bio: _opt(_bio),
    languages: [
      for (final x in _languages.text.split(','))
        if (x.trim().isNotEmpty) x.trim(),
    ],
    interests: _opt(_interests),
    showOrganizationPublicly: _showOrganization,
  );

  Map<ProfileField, ProfileFieldError> _proErrors(ProfessionalProfile p) => {
    ...ProfileValidation.professional(p),
    if (_years.text.trim().isNotEmpty &&
        int.tryParse(_years.text.trim()) == null)
      ProfileField.yearsExperience: ProfileFieldError.invalid,
  };

  /// Keyingi bosqich: faqat joriy bosqich maydonlari tekshiriladi; qoralama
  /// qurilmada saqlanadi (ma’lumot yo‘qolmaydi).
  Future<void> _next() async {
    final p = _proProfile();
    final e = {
      for (final x in _proErrors(p).entries)
        if (_stepFields[_step].contains(x.key)) x.key: x.value,
    };
    setState(() => _errors = e);
    if (e.isNotEmpty) return;
    await ref.read(localProfileProvider.notifier).saveProfessional(p);
    if (mounted) setState(() => _step++);
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final controller = ref.read(localProfileProvider.notifier);
    if (_mode == UserMode.student) {
      final p = StudentProfile(
        fullName: _name.text.trim(),
        country: _country ?? '',
        role: _studentRole,
        institution: _opt(_institution),
        faculty: _opt(_faculty),
        studyLevel: _studyLevel,
        interests: _studentInterests.toList(),
      );
      final e = ProfileValidation.student(p);
      setState(() => _errors = e);
      if (e.isNotEmpty) return;
      await controller.saveStudent(p);
    } else {
      final p = _proProfile();
      final e = _proErrors(p);
      setState(() => _errors = e);
      if (e.isNotEmpty) {
        // Xato bor birinchi bosqichga qaytish.
        for (var i = 0; i < _steps; i++) {
          if (_stepFields[i].any(e.containsKey)) {
            setState(() => _step = i);
            break;
          }
        }
        return;
      }
      await controller.saveProfessional(p);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.profileSaved)));
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    String? err(ProfileField f) => switch (_errors[f]) {
      final e? => l.profileFieldErrorLabel(e),
      null => null,
    };

    Widget field(
      String key,
      TextEditingController ctrl,
      String label, {
      ProfileField? f,
      bool required = false,
      String? helper,
      TextInputType? keyboard,
      int maxLines = 1,
      int? maxLength,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.sm),
      child: TextField(
        key: Key('profileEdit.$key'),
        controller: ctrl,
        keyboardType: keyboard,
        maxLines: maxLines,
        maxLength: maxLength,
        textInputAction: maxLines == 1
            ? TextInputAction.next
            : TextInputAction.newline,
        decoration: InputDecoration(
          labelText: required ? requiredLabel(label) : label,
          helperText: helper,
          helperMaxLines: 3,
          errorText: f == null ? null : err(f),
          border: const OutlineInputBorder(),
        ),
      ),
    );

    final isStudent = _mode == UserMode.student;
    final pendingDocs = ref.watch(pendingCredentialsProvider).length;
    return Scaffold(
      appBar: AppBar(
        title: Text(isStudent ? l.profileStudentTitle : l.profileProTitle),
      ),
      body: SafeArea(
        child: ListView(
          key: const Key('profileEdit.list'),
          padding: const EdgeInsets.symmetric(vertical: FeSpace.md),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FeNote(
                    icon: Icons.phone_android_outlined,
                    text: l.profileLocalOnlyNote,
                  ),
                  if (!isStudent) ...[
                    const SizedBox(height: FeSpace.xs),
                    FeNote(
                      key: const Key('profileEdit.notVerifiedNote'),
                      icon: Icons.verified_user_outlined,
                      text: l.modeProfessionalNotVerified,
                    ),
                  ],
                  if (!isStudent) ...[
                    const SizedBox(height: FeSpace.md),
                    _StepProgress(step: _step, total: _steps),
                  ],
                  if (isStudent || _step == 0) ...[
                    FeSectionHeader(l.profileSectionIdentity),
                    field(
                      'fullName',
                      _name,
                      l.fieldFullName,
                      f: ProfileField.fullName,
                      required: true,
                    ),
                    _CountryField(
                      value: _country,
                      lang: lang,
                      error: err(ProfileField.country),
                      onChanged: (code) => setState(() => _country = code),
                    ),
                    const SizedBox(height: FeSpace.sm),
                  ],
                  if (isStudent) ...[
                    _EnumDropdown<StudentRole>(
                      keyName: 'studentRole',
                      label: l.modeRoleTitle,
                      value: _studentRole,
                      values: StudentRole.values,
                      labelOf: l.studentRoleLabel,
                      onChanged: (v) => setState(() => _studentRole = v!),
                    ),
                    field('institution', _institution, l.fieldInstitution),
                    field('faculty', _faculty, l.fieldFaculty),
                    _EnumDropdown<StudyLevel>(
                      keyName: 'studyLevel',
                      label: l.fieldStudyLevel,
                      value: _studyLevel,
                      values: StudyLevel.values,
                      labelOf: l.studyLevelLabel,
                      onChanged: (v) => setState(() => _studyLevel = v),
                      optional: true,
                    ),
                    FeSectionHeader(l.fieldInterests),
                    _SpecialtyChips(
                      selected: _studentInterests,
                      onToggle: (s) => setState(
                        () => _studentInterests.contains(s)
                            ? _studentInterests.remove(s)
                            : _studentInterests.add(s),
                      ),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    FeNote(
                      icon: Icons.info_outline,
                      text: l.profileStudentCannotReview,
                    ),
                  ] else if (_step == 0) ...[
                    field('city', _city, l.fieldCity),
                    field('languages', _languages, l.fieldLanguages),
                    _EnumDropdown<ProfessionalRole>(
                      keyName: 'proRole',
                      label: l.modeRoleTitle,
                      value: _proRole,
                      values: ProfessionalRole.values,
                      labelOf: l.professionalRoleLabel,
                      onChanged: (v) => setState(() => _proRole = v!),
                    ),
                  ] else if (_step == 1) ...[
                    FeSectionHeader(l.profileSectionWork),
                    field(
                      'organization',
                      _organization,
                      l.fieldOrganization,
                      f: ProfileField.organization,
                      required: true,
                    ),
                    field(
                      'position',
                      _position,
                      l.fieldPosition,
                      f: ProfileField.position,
                      required: true,
                    ),
                    _EnumDropdown<Specialty>(
                      keyName: 'primarySpecialty',
                      label: requiredLabel(l.fieldPrimarySpecialty),
                      value: _primary,
                      values: Specialty.values,
                      labelOf: l.specialtyLabel,
                      onChanged: (v) => setState(() => _primary = v!),
                    ),
                    Text(l.fieldAdditionalSpecialties, style: t.titleSmall),
                    const SizedBox(height: FeSpace.xs),
                    _SpecialtyChips(
                      selected: _additional,
                      exclude: _primary,
                      onToggle: (s) => setState(
                        () => _additional.contains(s)
                            ? _additional.remove(s)
                            : _additional.add(s),
                      ),
                    ),
                    const SizedBox(height: FeSpace.md),
                    field(
                      'years',
                      _years,
                      l.fieldYearsExperience,
                      f: ProfileField.yearsExperience,
                      keyboard: TextInputType.number,
                    ),
                    field(
                      'education',
                      _education,
                      l.fieldEducation,
                      f: ProfileField.education,
                      required: true,
                    ),
                    field(
                      'workEmail',
                      _email,
                      l.fieldWorkEmail,
                      f: ProfileField.workEmail,
                      keyboard: TextInputType.emailAddress,
                      helper: l.fieldPrivateHelper,
                    ),
                    field(
                      'license',
                      _license,
                      l.fieldLicense,
                      helper: l.fieldLicenseHelper,
                    ),
                  ] else ...[
                    FeSectionHeader(l.profileSectionProfessional),
                    field(
                      'bio',
                      _bio,
                      l.fieldBio,
                      f: ProfileField.bio,
                      maxLines: 4,
                      maxLength: ProfileValidation.maxBio,
                    ),
                    field('interests', _interests, l.fieldProInterests),
                    SwitchListTile(
                      key: const Key('profileEdit.showOrganization'),
                      contentPadding: EdgeInsets.zero,
                      value: _showOrganization,
                      onChanged: (v) => setState(() => _showOrganization = v),
                      title: Text(l.fieldShowOrganization),
                      subtitle: Text(
                        l.fieldShowOrganizationHelper,
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ),
                    Card(
                      key: const Key('profileEdit.documents'),
                      child: ListTile(
                        leading: const Icon(Icons.upload_file_outlined),
                        title: Text(l.credUploadTitle),
                        subtitle: Text(
                          pendingDocs == 0
                              ? l.credOptional
                              : l.credSelectedCount(pendingDocs),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(Routes.verificationDocuments),
                      ),
                    ),
                  ],
                  if (_errors.isNotEmpty) ...[
                    const SizedBox(height: FeSpace.sm),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        l.formHasErrors,
                        key: const Key('profileEdit.errors'),
                        style: t.bodyMedium?.copyWith(color: c.danger),
                      ),
                    ),
                  ],
                  const SizedBox(height: FeSpace.md),
                  if (isStudent || _step == _steps - 1)
                    FilledButton(
                      key: const Key('profileEdit.save'),
                      onPressed: _save,
                      child: Text(l.actionSave),
                    )
                  else
                    FilledButton(
                      key: const Key('profileEdit.next'),
                      onPressed: _next,
                      child: Text(l.actionNext),
                    ),
                  if (!isStudent && _step > 0) ...[
                    const SizedBox(height: FeSpace.xs),
                    OutlinedButton(
                      key: const Key('profileEdit.back'),
                      onPressed: () => setState(() {
                        _errors = const {};
                        _step--;
                      }),
                      child: Text(l.actionBack),
                    ),
                  ],
                  const SizedBox(height: FeSpace.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// «1 / 3» va progress chizig‘i.
class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final titles = [
      l.profileStepPersonal,
      l.profileStepWork,
      l.profileStepProfessional,
    ];
    return Semantics(
      label: l.profileStepOf(step + 1, total),
      child: Column(
        key: const Key('profileEdit.step'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Text(
                  [step + 1, total].join(' / '),
                  style: FeThemeBuilder.numeric(
                    t.labelLarge!.copyWith(color: c.accent),
                  ),
                ),
              ),
              const SizedBox(width: FeSpace.sm),
              Expanded(
                child: Text(
                  titles[step],
                  style: t.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: FeSpace.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(FeRadius.sm),
            child: LinearProgressIndicator(
              value: (step + 1) / total,
              minHeight: 6,
              backgroundColor: c.surfaceSunken,
              color: c.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnumDropdown<T extends Enum> extends StatelessWidget {
  const _EnumDropdown({
    required this.keyName,
    required this.label,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
    this.optional = false,
  });

  final String keyName;
  final String label;
  final T? value;
  final List<T> values;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;
  final bool optional;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: FeSpace.sm),
    child: DropdownButtonFormField<T>(
      key: Key('profileEdit.$keyName'),
      initialValue: value,
      isExpanded: true,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final v in values)
          DropdownMenuItem(
            value: v,
            child: Text(labelOf(v), overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    ),
  );
}

class _SpecialtyChips extends StatelessWidget {
  const _SpecialtyChips({
    required this.selected,
    required this.onToggle,
    this.exclude,
  });

  final Set<Specialty> selected;
  final Specialty? exclude;
  final ValueChanged<Specialty> onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Wrap(
      spacing: FeSpace.xs,
      runSpacing: FeSpace.xs,
      children: [
        for (final s in Specialty.values)
          if (s != exclude)
            FilterChip(
              key: Key('specialty.${s.name}'),
              label: Text(l.specialtyLabel(s)),
              selected: selected.contains(s),
              onSelected: (_) => onToggle(s),
            ),
      ],
    );
  }
}

/// Davlat tanlash (qidiruvli ro‘yxat).
class _CountryField extends StatelessWidget {
  const _CountryField({
    required this.value,
    required this.lang,
    required this.onChanged,
    this.error,
  });

  final String? value;
  final String lang;
  final String? error;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final name = value == null
        ? null
        : CountryDirectory.byCode(value!)?.name(lang) ?? value;
    return Semantics(
      button: true,
      label: [l.fieldCountry, ?name].join(' '),
      child: InkWell(
        key: const Key('profileEdit.country'),
        borderRadius: BorderRadius.circular(FeRadius.sm),
        onTap: () async {
          final code = await showModalBottomSheet<String>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => _CountrySheet(lang: lang),
          );
          if (code != null) onChanged(code);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: requiredLabel(l.fieldCountry),
            errorText: error,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          child: Text(name ?? l.fieldCountryChoose),
        ),
      ),
    );
  }
}

class _CountrySheet extends StatefulWidget {
  const _CountrySheet({required this.lang});

  final String lang;

  @override
  State<_CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<_CountrySheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final q = _q.trim().toLowerCase();
    final list = [
      for (final c in CountryDirectory.all)
        if (q.isEmpty ||
            c.name(widget.lang).toLowerCase().contains(q) ||
            c.en.toLowerCase().contains(q))
          c,
    ]..sort((a, b) => a.name(widget.lang).compareTo(b.name(widget.lang)));
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(FeSpace.md),
            child: TextField(
              key: const Key('country.search'),
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l.fieldCountrySearch,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _q = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) => ListTile(
                key: Key('country.${list[i].code}'),
                title: Text(list[i].name(widget.lang)),
                onTap: () => Navigator.pop(context, list[i].code),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
