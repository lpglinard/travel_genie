# travel_genie

A new Flutter project.

This project now includes state management using [Riverpod](https://riverpod.dev).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Como construir e executar

1. Instale o [Flutter](https://docs.flutter.dev/get-started/install).
2. Instale o Android NDK versão `27.0.12077973`. Você pode utilizar o SDK Manager do Android Studio ou o comando `sdkmanager "ndk;27.0.12077973"`.
3. Execute `flutter pub get` para baixar as dependências.
4. Para gerar os arquivos de internacionalização utilize `flutter gen-l10n`.
5. Em seguida rode `flutter run` para iniciar o aplicativo no dispositivo ou emulador desejado.
6. Para gerar um APK de release use `flutter build apk`. Outras plataformas podem ser construídas com comandos equivalentes.

Os arquivos `.arb` que definem as traduções ficam em `lib/l10n` e o arquivo `l10n.yaml` configura a geração automática do código de localização.
