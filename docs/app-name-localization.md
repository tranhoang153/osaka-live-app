# App Name Localization

## Cấu hình hiện tại

App name sẽ tự động thay đổi dựa trên ngôn ngữ hệ thống của thiết bị:

- **Mặc định (English/Other)**: `Osaka Live`
- **Tiếng Hàn (Korean)**: `마이마캠`

## Implementation

### 1. Constants (`lib/constants/common.dart`)

```dart
const appName = "Osaka Live";

String getLocalizedAppName(String? languageCode) {
  if (languageCode == 'ko') {
    return "마이마캠";
  }
  return appName;
}
```

### 2. Main App (`lib/main.dart`)

```dart
MaterialApp(
  onGenerateTitle: (BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    return getLocalizedAppName(locale?.languageCode);
  },
  // ... other configs
)
```

## Cách hoạt động

1. `onGenerateTitle` được gọi khi MaterialApp build
2. Lấy `Locale` hiện tại từ context
3. Truyền `languageCode` vào `getLocalizedAppName()`
4. Return app name tương ứng với ngôn ngữ

## Testing

### iOS

1. Mở **Settings** > **General** > **Language & Region**
2. Thay đổi giữa English và Korean
3. Mở lại app
4. Kiểm tra tên app trong task switcher và title bar

### Android

1. Mở **Settings** > **System** > **Languages**
2. Thay đổi giữa English và Korean
3. Mở lại app
4. Kiểm tra tên app trong recent apps và title

## Native App Name (cấu hình riêng)

**Note**: Các file cấu hình native vẫn giữ nguyên như cũ:

### iOS

- `ios/Runner/Prod-Info.plist`: `CFBundleDisplayName = "Osaka Live"`
- `ios/Runner/ko.lproj/InfoPlist.strings`: `CFBundleDisplayName = "마이마캠"`
- Dev/Staging giữ tên riêng

### Android

- `android/app/src/main/res/values/strings.xml`: `app_name = "Osaka Live"`
- Environment-specific folders chứa tên riêng cho Dev/Staging
- Có thể tạo `values-ko/strings.xml` nếu muốn localization native

## Mở rộng thêm ngôn ngữ

Để thêm ngôn ngữ mới, update function `getLocalizedAppName()`:

```dart
String getLocalizedAppName(String? languageCode) {
  switch (languageCode) {
    case 'ko':
      return "마이마캠";
    case 'ja':
      return "マイマキャム"; // Ví dụ tiếng Nhật
    case 'zh':
      return "我的马凸轮"; // Ví dụ tiếng Trung
    default:
      return appName; // Osaka Live
  }
}
```
