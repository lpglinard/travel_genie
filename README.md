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

## Configuração do Google Sign-In no Android

Este projeto utiliza o pacote [`google_sign_in`](https://pub.dev/packages/google_sign_in).

1. Registre seu aplicativo seguindo o guia do [Firebase para Android](https://firebase.google.com/docs/android/setup).
2. Habilite as APIs OAuth necessárias no [Google Cloud Platform API Manager](https://console.developers.google.com/), como a [Google People API](https://developers.google.com/people/).
3. Preencha todos os campos obrigatórios da [tela de consentimento OAuth](https://console.developers.google.com/apis/credentials/consent) no console do Google Cloud para evitar erros `APIException`.
4. Inclua o arquivo `google-services.json` em `android/app` caso utilize serviços do Google que o exijam.
