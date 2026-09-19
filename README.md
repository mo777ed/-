# المقداع — تطبيق تحويل البضاعة بين الفروع

تطبيق Flutter عربي (RTL) يعمل محليًا بدون سيرفر: تسجيل موظف بالاسم والجوال، إنشاء تحويل بضاعة بين فرعين، مسح الباركود بالكاميرا، فاتورة رسمية، ثم **PDF / طباعة / مشاركة / Word**.

الشعار مضاف في الفاتورة (التطبيق + PDF + Word)، ويظهر أسفل كل صفحات التطبيق نص صغير: **م / محمد الجلال**.

## 1) التشغيل (أول مرة)

المتطلبات: Flutter (النسخة المستقرة الحديثة) + Android Studio أو Xcode.

```bash
cd almegdaa

# إنشاء مجلدات المنصات (android / ios) — لا يمس ملفات lib ولا pubspec
flutter create --org com.almegdaa --project-name almegdaa --platforms=android,ios .

flutter pub get
```

### أ) صلاحية الكاميرا — أندرويد
افتح `android/app/src/main/AndroidManifest.xml` وأضف قبل وسم `<application`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-feature android:name="android.hardware.camera" android:required="false"/>
```
وغيّر اسم التطبيق: `android:label="المقداع"`.

إذا ظهر خطأ minSdk أثناء البناء، ضع `minSdk = 24` في `android/app/build.gradle` (أو `build.gradle.kts`).

### ب) صلاحية الكاميرا — iOS
في `ios/Runner/Info.plist` أضف داخل `<dict>`:

```xml
<key>NSCameraUsageDescription</key>
<string>نحتاج الكاميرا لمسح باركود الأصناف</string>
```
وفي `ios/Podfile` تأكد أن السطر الأول: `platform :ios, '15.5'`

### ج) أيقونة التطبيق (اختياري)
```bash
dart run flutter_launcher_icons
```

### د) التشغيل
```bash
flutter run
# بناء APK للتوزيع:
flutter build apk --release
```

## 2) هيكل المشروع

```
lib/
  main.dart / app.dart          نقطة البداية + MaterialApp (عربي RTL) + الشريط السفلي
  core/
    constants/                  app_constants.dart (الاسم، النص السفلي) + branches.dart (الفروع الافتراضية)
    theme/                      الألوان والخطوط
    utils/                      تنسيق التواريخ، الأرقام العربية، رسائل النجاح/الخطأ
  models/                       Employee, Branch, Transfer, TransferItem
  database/                     app_database.dart (SQLite)
  repositories/                 الوصول لقاعدة البيانات (الفروع، التحويلات)
  providers/                    منطق التطبيق (الموظف، الفروع، التحويلات)
  services/                     pdf_service, docx_service, zip_writer, print_service, file_export_service
  screens/                      التسجيل، الرئيسية، إنشاء تحويل، الماسح، الفاتورة، القائمة، الإعدادات، الفروع
  widgets/                      جدول الأصناف، ورقة الفاتورة، الشريط السفلي، ...
assets/  images (الشعار)  fonts (Tajawal للواجهة، Amiri لملف PDF)
```

## 3) لماذا SQLite (sqflite)؟

- البيانات علائقية: تحويل واحد ← أصناف كثيرة، والحذف المتسلسل والاستعلامات (عدد الأصناف) أسهل وأوضح في SQL.
- مكتبة ناضجة ومستقرة وتعمل على أندرويد وiOS.
- بيانات الموظف (اسم + جوال) تُحفظ في `shared_preferences` لأنها قيمتان فقط.
- الفروع تُحفظ في جدول `branches` ويُملأ مرة واحدة من `lib/core/constants/branches.dart`.

## 4) التخصيص السريع

| المطلوب | أين |
|---|---|
| تغيير الفروع | من التطبيق: الرئيسية ← الإعدادات ← إدارة الفروع (أو الملف `branches.dart` قبل أول تشغيل) |
| تغيير النص السفلي (م / محمد الجلال) | `lib/core/constants/app_constants.dart` ← `developerCredit` |
| تغيير الشعار | استبدل الملفات في `assets/images/` بنفس الأسماء |
| ألوان التطبيق | `lib/core/theme/app_theme.dart` |
| شكل رقم التحويل (MQ-260918-0001) | `Transfer.number` في `lib/models/transfer.dart` |

## 5) ملاحظات تقنية

- **PDF**: ملف حقيقي (نص قابل للتحديد) بخط Amiri لأنه يحتوي على جميع أشكال الحروف العربية، ويدعم عدة صفحات مع تكرار رأس الجدول.
- **Word**: يُنشأ ملف DOCX حقيقي مباشرة بدون مكتبة خارجية (شعار + جداول + اتجاه RTL). «تحميل PDF» و«تصدير Word» يفتحان نافذة اختيار مكان الحفظ.
- **الباركود**: `mobile_scanner` يدعم أشهر الأنواع (EAN-13/8، UPC، Code 128/39/93، ITF، QR وغيرها). عند فشل الكاميرا أو رفض الصلاحية يظهر خيار الإدخال اليدوي.
- الأرقام العربية (٠-٩) تُحوَّل تلقائيًا إلى لاتينية في حقول الجوال والعدد والباركود.
- التطبيق للجوال (أندرويد/iOS) لأن sqflite لا يدعم الويب.
