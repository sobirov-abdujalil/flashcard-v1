# Maxfiylik siyosati — So‘z Atlas

**Ilova:** So‘z Atlas  
**Paket nomi:** `uz.sozatlas.app`  
**Oxirgi yangilanish:** 2026-yil 14-noyabr  
**Versiya:** 1.0.0

> **Eslatma (tarqatuvchi uchun):** ushbu hujjat ilovaning haqiqiy xatti-harakatiga
> asoslangan. Google Play talab qiladi: siyosat **ochiq URL manzilda** joylashgan
> bo‘lishi shart. Nashrdan oldin shu matnni o‘z veb-saytingiz yoki boshqa ochiq
> sahifangizda joylashtiring va Play Console’da o‘sha URL’ni ko‘rsating.
> Hujjatdagi aloqa manzilini ham o‘z rasmiy kontakt ma’lumotingiz bilan
> to‘ldiring.

## 1. Qisqa xulosa

So‘z Atlas hisob ochishni talab qilmaydi, internetga ulanmaydi va shaxsiy
ma’lumotlarni yig‘maydi. Ilova ishlashi uchun zarur bo‘lgan barcha ma’lumotlar
faqat foydalanuvchining qurilmasida saqlanadi.

## 2. Qanday ma’lumotlar saqlanadi

Ilova qurilmadagi mahalliy SQLite ma’lumotlar bazasida quyidagilarni saqlaydi:

- qaysi so‘zlar o‘rganilgani va ular bo‘yicha natijalar (to‘g‘ri/noto‘g‘ri
  javoblar soni);
- takrorlash sanalari va oralashtirilgan takrorlash holati;
- kunlik bajarilgan mashqlar soni, seriya (streak) va kunlik maqsad holati;
- foydalanuvchi tanlagan sozlamalar (mavzu rejimi va kunlik maqsad).

Sozlamalar Android `SharedPreferences` ichida, o‘quv natijalari esa SQLite
faylida saqlanadi. Bu ma’lumotlar hech qayerga yuborilmaydi.

## 3. Internet va uchinchi tomon xizmatlari

Ilova to‘liq offline ishlaydi. Unda:

- akkaunt, autentifikatsiya yoki bulutli sinxronizatsiya yo‘q;
- reklama SDK’lari yo‘q;
- analitika yoki kuzatuv (tracking) SDK’lari yo‘q;
- sun’iy intellekt API’lari yo‘q;
- to‘lov yoki obuna tizimlari yo‘q;
- dasturchi boshqaradigan server yoki boshqa tashqi API’lar yo‘q.

Ilova reliz versiyasida internet ruxsatini (`INTERNET`) so‘ramaydi.

## 4. Ruxsatlar va talaffuz

Talaffuz funksiyasi Android qurilmasining ichki matnni ovozga aylantirish (TTS)
tizimidan foydalanadi. Ovoz qurilmada yaratiladi va tarmoqqa yuborilmaydi.
Qurilmada ingliz tili ovozi o‘rnatilmagan bo‘lsa, talaffuz ishlamasligi mumkin —
bu holat ilovaning boshqa funksiyalariga ta’sir qilmaydi va xato ko‘rinishida
ko‘rsatilmaydi.

Ilova veb-kameraga, mikrofonga, joylashuvga, kontaktlariga, fayllarga yoki
qurilma identifikatorlariga kira olmaydi.

## 5. Ulashish (share)

Foydalanuvchi “Natijani ulashish” tugmasini bosganda ilova Android’ning
tizimli “Ulashish” oynasini ochadi va faqat o‘sha mashq natijalari matnini
(raqamlar bilan) uzatadi. Ushbu matn qaysi ilovaga yuborilishi foydalanuvchi
tanloviga bog‘liq. So‘z Atlas bu amalni majburlamaydi va uni o‘zi
qayd etmaydi.

## 6. Ma’lumotlarni o‘chirish

- **Sozlamalar → “O‘rganish tarixini tozalash”** — barcha o‘quv natijalari,
  seriya va takrorlash jadvali o‘chiriladi; so‘zlar bazasi va sozlamalar
  saqlanadi.
- **Ilovani qurilmadan o‘chirish** — qurilmada saqlangan barcha ma’lumotlar
  ilova bilan birga o‘chiriladi.

## 7. Bolalar maxfiyligi

Ilova hech qanday shaxsiy ma’lumot yig‘maydi, reklama ko‘rsatmaydi va tashqi
havolalarni ochmaydi. Shu sababli undan bolalar ham xavfsiz foydalanishlari
mumkin.

## 8. Ma’lumotlar xavfsizligi

Barcha ma’lumotlar Android’ning ilovaga ajratilgan xususiy sandbox hududida
saqlanadi va boshqa ilovalar tomonidan o‘qib bo‘lmaydi. Ilova Android zaxira
nusxalash (backup) funksiyasidan foydalanmaydi (`allowBackup="false"`), ya’ni
o‘quv natijalari bulutga avtomatik yuborilmaydi.

## 9. Siyosatdagi o‘zgarishlar

Agar ilova kelajakda internetga ulanadigan funksiya qo‘shsa, ushbu siyosat
yangilanadi va yangi versiya chiqarilishida e’lon qilinadi. Joriy versiya
hech qanday tarmoq aloqasidan foydalanmaydi.

## 10. Aloqa

Maxfiylik bo‘yicha savollar uchun Google Play’dagi ilova sahifasida ko‘rsatilgan
dasturchi kontakt ma’lumotlaridan foydalanishingiz mumkin.

---

### English summary (non-binding translation)

So‘z Atlas stores learning progress, review schedule and preferences only on the
user's device (local SQLite + SharedPreferences). It has no account, no backend,
no advertising, no analytics, no AI API and no internet permission in release
builds. Pronunciation uses the device's offline text-to-speech engine. Users can
erase all progress from Settings or by uninstalling the app. The developer does
not collect, transmit or sell any personal data.
