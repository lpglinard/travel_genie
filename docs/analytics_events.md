# Firebase Analytics Events

O aplicativo utiliza o Firebase Analytics para monitorar algumas ações básicas realizadas pelo usuário. A tabela a seguir descreve cada evento disponível no código atual.

| Evento | Descrição | Parâmetros |
|-------|-----------|------------|
| `login` (`logLogin`) | Disparado quando o usuário realiza login não anônimo. | `method` – provedor de autenticação utilizado. |
| `sign_up` (`logSignUp`) | Disparado quando o usuário cria uma nova conta. | `method` – provedor de autenticação utilizado. |
| `create_itinerary` | Deve ser utilizado ao criar um roteiro/itinerário inicial. | `itinerary_id` – identificador opcional do roteiro. |
| `change_language` | Registrado quando o idioma do aplicativo é alterado. | `language` – código do idioma selecionado. |
| `change_theme` | Registrado ao alternar entre tema claro ou escuro. | `theme` – nome do tema selecionado (`light` ou `dark`). |

Os eventos são registrados através da classe `AnalyticsService`, localizada em `lib/services/analytics_service.dart`. Utilize esse serviço sempre que novas ações relevantes forem implementadas para manter um padrão de registro.
