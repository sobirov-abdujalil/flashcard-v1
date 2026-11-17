import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/gradient_background.dart';
import '../../shared/widgets/progress_ring.dart';

/// Honest, in-app privacy policy that reflects the real behaviour of the app:
/// no accounts, no backend, no advertising, no analytics, no tracking.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String _updated = '2026-yil 14-noyabr';

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final List<(String, String)> sections = <(String, String)>[
      (
        'Qisqa xulosa',
        'So‘z Atlas hisob ochishni talab qilmaydi, internetga ulanmaydi va '
            'shaxsiy ma’lumotlarni yig‘maydi. Barcha ma’lumotlar faqat sizning '
            'qurilmangizda saqlanadi.',
      ),
      (
        'Qanday ma’lumotlar saqlanadi',
        'Ilova qurilmangizdagi mahalliy ma’lumotlar bazasida quyidagilarni '
            'saqlaydi: o‘rganilgan so‘zlar bo‘yicha natijalar, takrorlash '
            'sanalari, kunlik mashqlar soni, seriya (streak) va o‘zingiz '
            'tanlagan sozlamalar (mavzu va kunlik maqsad). Bu ma’lumotlar '
            'hech qayerga yuborilmaydi.',
      ),
      (
        'Internet va uchinchi tomon xizmatlari',
        'Ilova to‘liq offline ishlaydi. Unda reklama, analitika, kuzatuv, '
            'bulutli saqlash, sun’iy intellekt xizmatlari yoki tashqi serverlar '
            'yo‘q. Ilova internet ruxsatini so‘ramaydi.',
      ),
      (
        'Ruxsatlar va talaffuz',
        'Talaffuz funksiyasi Android qurilmasining ichki matnni ovozga '
            'aylantirish (TTS) tizimidan foydalanadi. Ovoz qurilmada '
            'yaratiladi. Agar qurilmada ingliz tili ovozi o‘rnatilmagan bo‘lsa, '
            'talaffuz mavjud bo‘lmasligi mumkin — bu holat ilovaning boshqa '
            'funksiyalariga ta’sir qilmaydi.',
      ),
      (
        'Ma’lumotlarni o‘chirish',
        'Sozlamalar bo‘limidagi “O‘rganish tarixini tozalash” tugmasi barcha '
            'natijalar, seriya va takrorlash jadvalini o‘chiradi. Ilovani '
            'qurilmadan o‘chirsangiz, barcha mahalliy ma’lumotlar ham '
            'o‘chiriladi.',
      ),
      (
        'Bolalar maxfiyligi',
        'Ilova hech qanday shaxsiy ma’lumotni yig‘magani uchun bolalar '
            'tomonidan ham xavfsiz foydalanilishi mumkin. Reklama va tashqi '
            'havolalar yo‘q.',
      ),
      (
        'O‘zgarishlar',
        'Agar ilova kelajakda internetga ulanadigan funksiya qo‘shsa, bu '
            'siyosat yangilanadi va ilova yangilanishida ko‘rsatiladi. '
            'Hozirgi versiya hech qanday tarmoq aloqasidan foydalanmaydi.',
      ),
      (
        'Aloqa',
        'Savollar bo‘yicha Google Play’dagi ilova sahifasida ko‘rsatilgan '
            'dasturchi kontaktidan foydalanishingiz mumkin.',
      ),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: GradientBackground(
        showConstellation: true,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: <Widget>[
                    GlassIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Orqaga',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Maxfiylik siyosati',
                        style: context.textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  physics: const BouncingScrollPhysics(),
                  children: <Widget>[
                    Text(
                      'So‘z Atlas · oxirgi yangilanish: $_updated',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (final (String title, String body) in sections) ...[
                      Text(
                        title,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        body,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: colors.successContainer,
                        border: Border.all(
                          color: colors.accentMint.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.verified_user_outlined,
                            size: 20,
                            color: colors.accentMint,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'So‘z Atlas sizning o‘quv ma’lumotlaringizni '
                              'faqat qurilmangizda saqlaydi.',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
