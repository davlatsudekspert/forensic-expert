# Pro (Free/Pro) qatlami, 0.4.0 (2026-10-24, egasi qarori): Pro sahifasi, qulf
# kartalari, birinchi taklif, Admin «Pro berish», xatolar statistikasi.
# Matn qoidalari: adabiy o‘zbek; Apple 3.1.2 jumlalari (narx, muddat, avto-uzayish,
# bekor qilish, Shartlar/Maxfiylik) Pro sahifasida. Narx kodga yozilmaydi.
# Idempotent: faqat shu fayldagi kalitlarni yozadi.
# CLAUDE.md tartibida: l10n_group_wording.py dan keyin, l10n_ux_audit.py dan oldin:
#   cd apps/mobile && python3 tool/l10n_pro_plans.py && flutter gen-l10n
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph or {})


k('proUnlock', 'Button on a Pro lock card: opens the Pro page.',
  'Unlock with Pro',
  'Открыть с Pro',
  'Pro bilan ochish')
k('proTitle', 'Pro page title.',
  'Pro plan',
  'Тариф Pro',
  'Pro rejasi')
k('proPlanStudent', 'Plan name: student.',
  'Student Pro',
  'Pro для студента',
  'Talaba Pro')
k('proPlanTeacher', 'Plan name: teacher.',
  'Teacher Pro',
  'Pro для преподавателя',
  'Ustoz Pro')
k('proPlanExpert', 'Plan name: expert (professional mode).',
  'Expert Pro',
  'Pro для специалиста',
  'Mutaxassis Pro')
k('proProfileRow', 'Profile row title: current plan.',
  'Plan',
  'Тариф',
  'Reja')
k('proFreeAlways', 'Pro page and lock pages: safety/sources are always free.',
  'Safety information, sources and provenance are always free.',
  'Сведения о безопасности, источники и происхождение данных всегда бесплатны.',
  'Xavfsizlik ma’lumotlari, manbalar va ma’lumotning kelib chiqishi (provenance) doim bepul.')
k('proBenefitFullQuizBank', 'Lock card benefit.',
  'Full question bank: 4,370 questions in 211 topics',
  'Полный банк вопросов: 4370 вопросов по 211 темам',
  'To‘liq test banki: 211 mavzu bo‘yicha 4370 savol')
k('proBenefitExamMode', 'Lock card benefit.',
  'Exam mode with a review of every answer',
  'Режим экзамена с разбором каждого ответа',
  'Imtihon rejimi: har bir javob tahlili bilan')
k('proBenefitAllFlashcards', 'Lock card benefit.',
  'Flashcards for all subjects',
  'Карточки по всем дисциплинам',
  'Barcha fanlar bo‘yicha kartochkalar')
k('proBenefitErrorAnalytics', 'Lock card benefit.',
  'Error analysis and statistics',
  'Разбор ошибок и статистика',
  'Xatolar tahlili va statistika')
k('proBenefitOfflineDownload', 'Lock card benefit.',
  'Download materials for offline study',
  'Загрузка материалов для офлайн-учёбы',
  'Materiallarni oflayn o‘qish uchun yuklab olish')
k('proBenefitAllLessons', 'Lock card benefit.',
  'All 211 lecture presentations',
  'Все 211 лекционных презентаций',
  'Barcha 211 ta ma’ruza prezentatsiyasi')
k('proBenefitUnlimitedGroupTests', 'Lock card benefit.',
  'Unlimited groups and group tests of more than 10 questions',
  'Неограниченное число групп и тесты длиннее 10 вопросов',
  'Cheksiz guruhlar va 10 tadan ko‘p savolli guruh testlari')
k('proBenefitResultsCsv', 'Lock card benefit.',
  'Export results to CSV',
  'Экспорт результатов в CSV',
  'Natijalarni CSV ga yuklab olish')
k('proBenefitHardestDiscussion', 'Lock card benefit.',
  'Discussion of the hardest questions',
  'Разбор самых трудных вопросов',
  'Eng qiyin savollar muhokamasi')
k('proBenefitLiveTestLarge', 'Lock card benefit.',
  'Live tests for large audiences',
  'Живые тесты для больших аудиторий',
  'Katta auditoriya uchun jonli testlar')
k('proBenefitInstrumentsCourseFull', 'Lock card benefit.',
  'The full «Working with instruments» course',
  'Полный курс «Работа на приборах»',
  '«Apparatlar bilan ishlash» kursi to‘liq')
k('proBenefitProCalculators', 'Lock card benefit.',
  'Professional calculators: PMI, concentration, LOD/LOQ and more',
  'Профессиональные калькуляторы: PMI, концентрация, LOD/LOQ и другие',
  'Professional kalkulyatorlar: PMI, konsentratsiya, LOD/LOQ va boshqalar')
k('proBenefitCaseNotebook', 'Lock card benefit.',
  'Expert casebook with sourced blocks for your conclusions',
  'Рабочая тетрадь эксперта с блоками с источниками для заключений',
  'Ekspert ish daftari: xulosa uchun manbali bloklar')
k('proBenefitCourtPrep', 'Lock card benefit.',
  'Court testimony preparation: simulator, drills and statistics',
  'Подготовка к допросу в суде: симулятор, тренировка и статистика',
  'Sudda so‘roqqa tayyorgarlik: simulyator, mashq va statistika')
k('proBenefitAiExtended', 'Lock card benefit.',
  'A higher daily AI limit',
  'Расширенный суточный лимит ИИ',
  'AI uchun kengaytirilgan kunlik limit')
k('proCtxAllLessons', 'Offer at the end of a free lecture lesson.',
  'All 211 lecture presentations and their tests open with Teacher Pro.',
  'Все 211 презентаций лекций и тесты к ним открываются с Pro для преподавателя.',
  'Barcha 211 ta ma’ruza prezentatsiyasi va ularning testlari Ustoz Pro bilan ochiladi.')
k('proCtxInstrumentsRest', 'Offer at the end of the free instruments lesson.',
  'All lessons of this course and their tests open with Expert Pro.',
  'Все уроки этого курса и тесты к ним открываются с Pro для специалиста.',
  'Bu kursning barcha darslari va ularning testlari Mutaxassis Pro bilan ochiladi.')
k('studyNoGuaranteeNote', 'Small note under the test start: no guarantee about real exam questions.',
  'Practice questions are prepared for study from open sources. They are not a guarantee that the same questions will appear in an official exam.',
  'Вопросы подготовлены для обучения по открытым источникам. Они не гарантируют, что такие же вопросы попадутся на официальном экзамене.',
  'Savollar o‘quv maqsadida, ochiq manbalar asosida tuzilgan. Rasmiy imtihonda aynan shu savollar tushishiga kafolat berilmaydi.')
k('proCtxGroupLimit', 'Shown when a free teacher tries to create a second group.',
  'The free plan includes one group. Create more groups with Teacher Pro.',
  'В бесплатном тарифе одна группа. Больше групп — с Pro для преподавателя.',
  'Bepul rejada bitta guruh bor. Ko‘proq guruh Ustoz Pro bilan yaratiladi.')
k('proStateFree', 'Pro page status: free plan.',
  'Free plan',
  'Бесплатный тариф',
  'Bepul reja')
k('proStateFreeBody', 'Pro page status body for the free plan.',
  'Reference, sources and safety information are always free. Pro adds extra tools for your mode.',
  'Справочник, источники и сведения о безопасности всегда бесплатны. Pro добавляет инструменты вашего режима.',
  'Ma’lumotnoma, manbalar va xavfsizlik ma’lumotlari doim bepul. Pro rejimingizga mos qo‘shimcha imkoniyatlar beradi.')
k('proStateTrial', 'Pro page status: trial active. {plan} is the plan name.',
  '{plan}: free trial',
  '{plan}: бесплатный пробный период',
  '{plan}: bepul sinov davri',
  {'plan': 'String'})
k('proStateActive', 'Pro page status: plan active. {plan} is the plan name.',
  '{plan} is active',
  '{plan} активен',
  '{plan} faol',
  {'plan': 'String'})
k('proStateUntil', 'Pro page: end date. {date} is a formatted date.',
  'Until {date}',
  'До {date}',
  '{date} gacha',
  {'date': 'String'})
k('proStateNoEnd', 'Pro page: plan without an end date.',
  'No end date',
  'Без срока окончания',
  'Muddati cheklanmagan')
k('proAutoRenewOn', 'Pro page: subscription renews automatically.',
  'Auto-renews',
  'Продлевается автоматически',
  'Avtomatik uzayadi')
k('proAutoRenewOff', 'Pro page: subscription does not renew.',
  'Does not renew',
  'Не продлевается',
  'Uzaytirilmaydi')
k('proSourceStore', 'Plan source: store subscription.',
  'Store subscription',
  'Подписка в магазине',
  'Do‘kon obunasi')
k('proSourceAdmin', 'Plan source: granted by an administrator.',
  'Granted by administrator',
  'Выдано администратором',
  'Administrator bergan')
k('proSourceTrial', 'Plan source: free trial.',
  'Free trial',
  'Бесплатный пробный период',
  'Bepul sinov')
k('proOwnModeNote', 'Pro page: a plan unlocks only its own mode.',
  'A plan unlocks features of its own mode only. Switching the mode does not unlock another plan’s features.',
  'Тариф открывает функции только своего режима. Смена режима не открывает функции другого тарифа.',
  'Har bir reja faqat o‘z rejimidagi imkoniyatlarni ochadi. Rejimni almashtirish boshqa rejaning imkoniyatlarini ochmaydi.')
k('proTeacherRoleNote', 'Pro page (teacher plan): server role is still required.',
  'The Teacher panel still requires the teacher role on the server; Pro does not grant the role.',
  'Панель преподавателя по-прежнему требует роль преподавателя на сервере; Pro роль не выдаёт.',
  'Ustoz paneli hamon serverdagi ustoz rolini talab qiladi; Pro rol bermaydi.')
k('proIncludesStudent1', 'Pro page: what the student plan includes, item 1.',
  'Full question bank: 4,370 questions in 211 topics',
  'Полный банк вопросов: 4370 вопросов по 211 темам',
  'To‘liq test banki: 211 mavzu bo‘yicha 4370 savol')
k('proIncludesStudent2', 'Pro page: what the student plan includes, item 2.',
  'Exam mode with a review of every answer',
  'Режим экзамена с разбором каждого ответа',
  'Imtihon rejimi: har bir javob tahlili bilan')
k('proIncludesStudent3', 'Pro page: what the student plan includes, item 3.',
  'Flashcards for all subjects',
  'Карточки по всем дисциплинам',
  'Barcha fanlar bo‘yicha kartochkalar')
k('proIncludesStudent4', 'Pro page: what the student plan includes, item 4.',
  'Error analysis and statistics',
  'Разбор ошибок и статистика',
  'Xatolar tahlili va statistika')
k('proIncludesTeacher1', 'Pro page: what the teacher plan includes, item 1.',
  'All 211 lecture presentations (projector mode)',
  'Все 211 лекционных презентаций (режим проектора)',
  'Barcha 211 ta ma’ruza prezentatsiyasi (proyektor rejimi)')
k('proIncludesTeacher2', 'Pro page: what the teacher plan includes, item 2.',
  'Unlimited groups and tests of more than 10 questions',
  'Неограниченное число групп и тесты длиннее 10 вопросов',
  'Cheksiz guruhlar va 10 tadan ko‘p savolli testlar')
k('proIncludesTeacher3', 'Pro page: what the teacher plan includes, item 3.',
  'Results export to CSV',
  'Экспорт результатов в CSV',
  'Natijalarni CSV ga yuklab olish')
k('proIncludesTeacher4', 'Pro page: what the teacher plan includes, item 4.',
  'Discussion of the hardest questions',
  'Разбор самых трудных вопросов',
  'Eng qiyin savollar muhokamasi')
k('proIncludesExpert1', 'Pro page: what the expert plan includes, item 1.',
  'The full «Working with instruments» course: Kristallyuks/ethanol, UV-1900/COHb, GC-MS',
  'Полный курс «Работа на приборах»: Кристаллюкс/этанол, UV-1900/COHb, GC-MS',
  '«Apparatlar bilan ishlash» kursi to‘liq: Kristallyuks/etanol, UV-1900/COHb, GC-MS')
k('proIncludesExpert2', 'Pro page: what the expert plan includes, item 2.',
  'Professional calculators: PMI, concentration, LOD/LOQ and more',
  'Профессиональные калькуляторы: PMI, концентрация, LOD/LOQ и другие',
  'Professional kalkulyatorlar: PMI, konsentratsiya, LOD/LOQ va boshqalar')
k('proIncludesExpert3', 'Pro page: what the expert plan includes, item 3.',
  'Expert casebook and court testimony preparation',
  'Рабочая тетрадь эксперта и подготовка к допросу в суде',
  'Ekspert ish daftari va sudda so‘roqqa tayyorgarlik')
k('proIncludesExpert4', 'Pro page: what the expert plan includes, item 4.',
  'A higher daily AI limit',
  'Расширенный суточный лимит ИИ',
  'AI uchun kengaytirilgan kunlik limit')
k('proGuestTitle', 'Pro page for a signed-out user.',
  'Sign in to use Pro',
  'Войдите, чтобы пользоваться Pro',
  'Pro uchun hisobga kiring')
k('proGuestBody', 'Pro page for a signed-out user.',
  'A plan is tied to your account and works on all your devices. The reference and safety information stay free without an account.',
  'Тариф привязан к аккаунту и работает на всех ваших устройствах. Справочник и сведения о безопасности остаются бесплатными без аккаунта.',
  'Reja hisobingizga bog‘lanadi va barcha qurilmalaringizda ishlaydi. Ma’lumotnoma va xavfsizlik ma’lumotlari hisobsiz ham bepul.')
k('proGuestSignIn', 'Button: sign in with an email code.',
  'Sign in with an email code',
  'Войти по коду из письма',
  'Email kod bilan kirish')
k('proChoose', 'Pro page section: choose a subscription.',
  'Choose a subscription',
  'Выберите подписку',
  'Obunani tanlang')
k('proAlreadyActive', 'Pro page: this plan is already active.',
  'This plan is already active on your account.',
  'Этот тариф уже активен в вашем аккаунте.',
  'Bu reja hisobingizda allaqachon faol.')
k('proStoreUnavailable', 'Pro page: store not available; price is shown in the store.',
  'The store is not available right now (for example on an emulator or without a store account). The price is shown in the store when you subscribe.',
  'Магазин сейчас недоступен (например, на эмуляторе или без аккаунта магазина). Цена показывается в магазине при оформлении подписки.',
  'Do‘kon hozir mavjud emas (masalan, emulyatorda yoki do‘kon hisobisiz). Narx obuna rasmiylashtirilganda do‘konda ko‘rsatiladi.')
k('proStoreNoProducts', 'Pro page: the store returned no products.',
  'The store did not return this plan’s subscriptions yet. Try again later; the price is shown in the store.',
  'Магазин пока не вернул подписки этого тарифа. Повторите позже; цена показывается в магазине.',
  'Do‘kon bu rejaning obunalarini hali qaytarmadi. Keyinroq urinib ko‘ring; narx do‘konda ko‘rsatiladi.')
k('proMonthly', 'Subscription period.',
  'Monthly',
  'На месяц',
  'Oylik')
k('proYearly', 'Subscription period.',
  'Yearly',
  'На год',
  'Yillik')
k('proBuy', 'Button: buy the subscription.',
  'Buy',
  'Купить',
  'Sotib olish')
k('proTrialButton', 'Button: start the free trial.',
  'Try free for 30 days',
  'Попробовать бесплатно 30 дней',
  '30 kun bepul sinab ko‘rish')
k('proTrialNote', 'Pro page: trial rules.',
  'The free trial is available once per device and once per account. It ends on its own and nothing is charged.',
  'Пробный период доступен один раз на устройство и один раз на аккаунт. Он заканчивается сам, деньги не списываются.',
  'Bepul sinov bir qurilmada va bir hisobda faqat bir marta beriladi. U o‘zi tugaydi, pul yechilmaydi.')
k('proRestore', 'Button: restore purchases.',
  'Restore purchases',
  'Восстановить покупки',
  'Xaridlarni tiklash')
k('proFlowWorking', 'Pro page: working.',
  'Please wait…',
  'Подождите…',
  'Iltimos, kuting…')
k('proFlowSuccess', 'Pro page: success.',
  'Done. Your plan is active.',
  'Готово. Ваш тариф активен.',
  'Tayyor. Rejangiz faol.')
k('proFlowPending', 'Pro page: purchase pending approval.',
  'The purchase is waiting for approval. The plan turns on after it is confirmed.',
  'Покупка ожидает подтверждения. Тариф включится после подтверждения.',
  'Xarid tasdiqlanishini kutmoqda. Tasdiqlangach reja yoqiladi.')
k('proFlowCanceled', 'Pro page: purchase cancelled.',
  'The purchase was cancelled. Nothing was charged.',
  'Покупка отменена. Ничего не списано.',
  'Xarid bekor qilindi. Pul yechilmadi.')
k('proFlowStoreNotConfigured', 'Pro page: server-side store verification is not connected.',
  'Store purchase verification is not connected on the server yet. Your purchase is kept and will be checked once it is connected.',
  'Проверка покупок магазина на сервере ещё не подключена. Покупка сохранена и будет проверена после подключения.',
  'Do‘kon xaridlarini serverda tekshirish hali ulanmagan. Xaridingiz saqlanadi va ulangach tekshiriladi.')
k('proFlowInvalid', 'Pro page: purchase could not be verified.',
  'The purchase could not be verified. If you were charged, contact support.',
  'Покупку не удалось проверить. Если деньги списаны, напишите в поддержку.',
  'Xaridni tasdiqlab bo‘lmadi. Pul yechilgan bo‘lsa, qo‘llab-quvvatlashga yozing.')
k('proFlowOffline', 'Pro page: no connection.',
  'No connection. The purchase will be checked when the internet is back.',
  'Нет соединения. Покупка будет проверена, когда появится интернет.',
  'Aloqa yo‘q. Internet qaytgach xarid tekshiriladi.')
k('proFlowError', 'Pro page: generic error.',
  'Something went wrong. Please try again.',
  'Что-то пошло не так. Повторите попытку.',
  'Xatolik yuz berdi. Qayta urinib ko‘ring.')
k('proFlowRestoreNothing', 'Pro page: nothing to restore.',
  'No purchases to restore were found for this store account.',
  'Покупок для восстановления в этом аккаунте магазина не найдено.',
  'Bu do‘kon hisobida tiklanadigan xaridlar topilmadi.')
k('proTrialUsedDevice', 'Pro page: trial already used on this device.',
  'The free trial has already been used on this device.',
  'Пробный период уже использован на этом устройстве.',
  'Bu qurilmada bepul sinov allaqachon ishlatilgan.')
k('proTrialUsedAccount', 'Pro page: trial already used on this account.',
  'The free trial has already been used on this account.',
  'Пробный период уже использован в этом аккаунте.',
  'Bu hisobda bepul sinov allaqachon ishlatilgan.')
k('proTrialHasPlan', 'Pro page: user already has a plan.',
  'You already have an active plan, so the trial is not needed.',
  'У вас уже есть активный тариф, пробный период не нужен.',
  'Sizda faol reja bor, sinov kerak emas.')
k('proTrialUnavailable', 'Pro page: trial cannot be offered on this device.',
  'The trial cannot be offered on this device.',
  'На этом устройстве пробный период недоступен.',
  'Bu qurilmada sinovni taklif qilib bo‘lmaydi.')
k('proTermsTitle', 'Pro page section: subscription terms.',
  'Subscription terms',
  'Условия подписки',
  'Obuna shartlari')
k('proTermsBody', 'Pro page: Apple 3.1.2 subscription disclosure (period, price in store, auto-renewal, cancellation).',
  'Subscriptions are monthly or yearly and renew automatically. The price and billing period are shown in the store before you confirm. Payment is charged to your Apple ID or Google Play account at confirmation. The subscription renews unless it is cancelled at least 24 hours before the end of the current period, and your account is charged for the next period within 24 hours before the end. You can manage or cancel it at any time in your store account settings; cancelling takes effect at the end of the paid period. A free trial or introductory offer shown by the store ends automatically.',
  'Подписки оформляются на месяц или на год и продлеваются автоматически. Цена и период оплаты показываются в магазине до подтверждения. Оплата списывается с вашего Apple ID или аккаунта Google Play при подтверждении. Подписка продлевается, если не отменить её минимум за 24 часа до конца текущего периода; плата за следующий период списывается в течение 24 часов до его окончания. Управлять подпиской и отменять её можно в любое время в настройках аккаунта магазина; отмена действует с конца оплаченного периода. Пробный период или вводное предложение, показанные магазином, заканчиваются автоматически.',
  'Obunalar oylik yoki yillik bo‘lib, avtomatik uzayadi. Narx va to‘lov davri tasdiqlashdan oldin do‘konda ko‘rsatiladi. To‘lov tasdiqlanganda Apple ID yoki Google Play hisobingizdan yechiladi. Joriy davr tugashidan kamida 24 soat oldin bekor qilinmasa, obuna uzayadi va keyingi davr uchun to‘lov davr tugashidan oldingi 24 soat ichida yechiladi. Obunani istalgan vaqt do‘kon hisobingiz sozlamalarida boshqarish yoki bekor qilish mumkin; bekor qilish to‘langan davr oxirida kuchga kiradi. Do‘kon ko‘rsatgan bepul sinov yoki boshlang‘ich taklif o‘zi tugaydi.')
k('proCancelHowIos', 'Pro page: how to cancel on iPhone.',
  'To cancel on iPhone: Settings → your name → Subscriptions → FORENSIC EXPERT → Cancel Subscription.',
  'Чтобы отменить на iPhone: Настройки → ваше имя → Подписки → FORENSIC EXPERT → Отменить подписку.',
  'iPhone’da bekor qilish: Sozlamalar → ismingiz → Obunalar → FORENSIC EXPERT → Obunani bekor qilish.')
k('proCancelHowAndroid', 'Pro page: how to cancel on Android.',
  'To cancel on Android: Google Play → profile icon → Payments & subscriptions → Subscriptions → FORENSIC EXPERT → Cancel subscription.',
  'Чтобы отменить на Android: Google Play → значок профиля → Платежи и подписки → Подписки → FORENSIC EXPERT → Отменить подписку.',
  'Android’da bekor qilish: Google Play → profil belgisi → To‘lovlar va obunalar → Obunalar → FORENSIC EXPERT → Obunani bekor qilish.')
k('proManage', 'Button: open the store subscription settings.',
  'Manage or cancel subscription',
  'Управление подпиской и отмена',
  'Obunani boshqarish yoki bekor qilish')
k('proManageFailed', 'Snackbar: the store page could not be opened.',
  'Could not open the store page. Open your store account settings manually.',
  'Не удалось открыть страницу магазина. Откройте настройки аккаунта магазина вручную.',
  'Do‘kon sahifasini ochib bo‘lmadi. Do‘kon hisobi sozlamalarini o‘zingiz oching.')
k('proTermsLink', 'Link: Terms of Use.',
  'Terms of Use',
  'Условия использования',
  'Foydalanish shartlari')
k('proPrivacyLink', 'Link: Privacy Policy.',
  'Privacy Policy',
  'Политика конфиденциальности',
  'Maxfiylik siyosati')
k('proOfferStudentTitle', 'Home: one-time soft offer for student mode.',
  'Study without limits',
  'Учитесь без ограничений',
  'Cheklovsiz o‘qing')
k('proOfferStudentBody', 'Home: one-time soft offer for student mode.',
  'Student Pro opens the full question bank, exam mode, all flashcards and error analysis. A free trial, if available, is shown on the Pro page.',
  'Pro для студента открывает полный банк вопросов, режим экзамена, все карточки и разбор ошибок. Пробный период, если он доступен, показан на странице Pro.',
  'Talaba Pro to‘liq test banki, imtihon rejimi, barcha kartochkalar va xatolar tahlilini ochadi. Bepul sinov imkoniyati bo‘lsa, Pro sahifasida ko‘rsatiladi.')
k('proOfferTeacherTitle', 'Home: one-time soft offer for teacher mode.',
  'Teach with more tools',
  'Больше возможностей для преподавания',
  'Dars berishda ko‘proq imkoniyat')
k('proOfferTeacherBody', 'Home: one-time soft offer for teacher mode.',
  'Teacher Pro opens all 211 presentations, unlimited groups, longer tests, CSV export and discussion of the hardest questions. A free trial, if available, is shown on the Pro page.',
  'Pro для преподавателя открывает все 211 презентаций, неограниченные группы, более длинные тесты, экспорт в CSV и разбор трудных вопросов. Пробный период, если он доступен, показан на странице Pro.',
  'Ustoz Pro barcha 211 ta prezentatsiya, cheksiz guruhlar, uzunroq testlar, CSV va qiyin savollar muhokamasini ochadi. Bepul sinov imkoniyati bo‘lsa, Pro sahifasida ko‘rsatiladi.')
k('proOfferExpertTitle', 'Home: one-time soft offer for professional mode.',
  'Tools for your casework',
  'Инструменты для вашей работы',
  'Ish uchun asboblar')
k('proOfferExpertBody', 'Home: one-time soft offer for professional mode.',
  'Expert Pro opens the full instruments course, professional calculators, the casebook, court testimony preparation and a higher AI limit. A free trial, if available, is shown on the Pro page.',
  'Pro для специалиста открывает полный курс по приборам, профессиональные калькуляторы, рабочую тетрадь, подготовку к допросу в суде и расширенный лимит ИИ. Пробный период, если он доступен, показан на странице Pro.',
  'Mutaxassis Pro apparatlar kursini to‘liq, professional kalkulyatorlar, ish daftari, sudda so‘roqqa tayyorgarlik va kengaytirilgan AI limitini ochadi. Bepul sinov imkoniyati bo‘lsa, Pro sahifasida ko‘rsatiladi.')
k('proOfferOpen', 'Button on the soft offer.',
  'Learn more',
  'Подробнее',
  'Batafsil')
k('proOfferDismiss', 'Tooltip: close the soft offer.',
  'Dismiss',
  'Закрыть',
  'Yopish')
k('studyStatsTitle', 'Study hub: error statistics card (Student Pro).',
  'Error statistics',
  'Статистика ошибок',
  'Xatolar statistikasi')
k('studyStatsEmpty', 'Study hub: no reviewed cards yet.',
  'Review some cards first — statistics will appear here.',
  'Сначала повторите несколько карточек — здесь появится статистика.',
  'Avval bir nechta kartochkani takrorlang — statistika shu yerda paydo bo‘ladi.')
k('studyStatsSummary', 'Study hub: summary counts.',
  'Reviewed: {reviewed} · difficult: {weak} · mastered: {learned}',
  'Повторено: {reviewed} · трудные: {weak} · усвоено: {learned}',
  'Takrorlangan: {reviewed} · qiyin: {weak} · o‘zlashtirilgan: {learned}',
  {'reviewed': 'int', 'weak': 'int', 'learned': 'int'})
k('studyStatsWeakDeck', 'Study hub: a deck with difficult cards. {deck} deck name, {count} number.',
  '{deck}: {count} difficult',
  '{deck}: трудных — {count}',
  '{deck}: qiyin kartochka — {count} ta',
  {'deck': 'String', 'count': 'int'})
k('admProTitle', 'Admin: grant Pro screen title.',
  'Grant Pro',
  'Выдача Pro',
  'Pro berish')
k('admProHint', 'Admin: grant Pro tile hint.',
  'Plan for an email, duration, list, revoke',
  'Тариф для email, срок, список, отзыв',
  'Email uchun reja, muddat, ro‘yxat, olib tashlash')
k('admProNote', 'Admin: grant Pro note.',
  'A plan granted here is recorded in the audit log with the source “administrator”. A store subscription takes precedence.',
  'Выданный здесь тариф записывается в журнал аудита с источником «администратор». Подписка магазина имеет приоритет.',
  'Bu yerda berilgan reja audit jurnaliga «administrator» manbasi bilan yoziladi. Do‘kon obunasi ustun turadi.')
k('admProGrantTitle', 'Admin: section title.',
  'Grant a plan',
  'Выдать тариф',
  'Reja berish')
k('admProEmail', 'Admin: email field.',
  'User email',
  'Email пользователя',
  'Foydalanuvchi emaili')
k('admProPlan', 'Admin: plan choice label.',
  'Plan',
  'Тариф',
  'Reja')
k('admProUntil', 'Admin: duration choice label.',
  'Duration',
  'Срок',
  'Muddat')
k('admProDays30', 'Admin: duration.',
  '30 days',
  '30 дней',
  '30 kun')
k('admProDays90', 'Admin: duration.',
  '90 days',
  '90 дней',
  '90 kun')
k('admProYear', 'Admin: duration.',
  '1 year',
  '1 год',
  '1 yil')
k('admProNoLimit', 'Admin: no end date.',
  'No limit',
  'Без срока',
  'Muddatsiz')
k('admProGrant', 'Admin: grant button.',
  'Grant',
  'Выдать',
  'Berish')
k('admProRevoke', 'Admin: revoke button/tooltip.',
  'Revoke',
  'Отозвать',
  'Olib tashlash')
k('admProGranted', 'Admin: result.',
  'The plan has been granted.',
  'Тариф выдан.',
  'Reja berildi.')
k('admProRevoked', 'Admin: result.',
  'The plan has been revoked.',
  'Тариф отозван.',
  'Reja olib tashlandi.')
k('admProNotFound', 'Admin: result.',
  'No user with this email.',
  'Пользователь с таким email не найден.',
  'Bu email bilan foydalanuvchi topilmadi.')
k('admProInvalid', 'Admin: result.',
  'Enter a valid email address.',
  'Введите корректный email.',
  'To‘g‘ri email manzil kiriting.')
k('admProError', 'Admin: error.',
  'Could not complete the request. Try again.',
  'Не удалось выполнить запрос. Повторите.',
  'So‘rovni bajarib bo‘lmadi. Qayta urinib ko‘ring.')
k('admProListTitle', 'Admin: list title.',
  'Granted plans',
  'Выданные тарифы',
  'Berilgan rejalar')
k('admProSearch', 'Admin: search hint.',
  'Search by email',
  'Поиск по email',
  'Email bo‘yicha qidirish')
k('admProEmpty', 'Admin: empty list.',
  'No plans yet.',
  'Тарифов пока нет.',
  'Hozircha rejalar yo‘q.')

for idx, code in enumerate(["en", "ru", "uz"]):
    p = f"{D}/app_{code}.arb"
    text = open(p, encoding="utf-8").read()
    data = json.loads(text)
    for key, (desc, en, ru, uz, ph) in K.items():
        val = (en, ru, uz)[idx]
        entries = [(key, val)]
        if code == "en":
            meta = {"description": desc}
            if ph:
                meta["placeholders"] = {n: {"type": t} for n, t in ph.items()}
            entries.append(("@" + key, meta))
        for kk, vv in entries:
            line = f"  {json.dumps(kk, ensure_ascii=False)}: {json.dumps(vv, ensure_ascii=False)}"
            if kk in data:
                text = re.sub(r"(?ms)^  " + re.escape(json.dumps(kk, ensure_ascii=False)) + r": .*?(,?)\n(?=  \"|\}$)",
                              lambda m: line + m.group(1) + "\n", text, count=1)
            else:
                body = text.rstrip()
                assert body.endswith("}")
                text = body[:-1].rstrip() + ",\n" + line + "\n}\n"
        data = json.loads(text)
    json.loads(text)
    open(p, "w", encoding="utf-8").write(text)
print(len(K), "keys")
