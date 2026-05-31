# AutoCheckMobile — полный стенд

Единый репозиторий для запуска конкурсного сервиса: React web dashboard, Flutter client source, Kotlin/Spring backend, worker, PostgreSQL, Redis и Docker checker image.

## Быстрый старт

```bash
git clone --recurse-submodules git@github.com:Olegg000/allTogether.git
cd allTogether

cp .env.example .env
docker compose up -d --build
```

Адреса после запуска:

- Web dashboard: `http://localhost:5173`
- Backend Swagger: `http://localhost:8080/api/swagger-ui/index.html#/`
- OpenAPI JSON: `http://localhost:8080/api/docs`
- API base URL: `http://localhost:8080/api/v1`

Если репозиторий был склонирован без submodules:

```bash
git submodule update --init --recursive
```

## Проверка стенда

```bash
docker compose ps
./scripts/smoke.sh
docker compose logs -f backend worker web
```

Для чистого перезапуска с новой базой:

```bash
docker compose down -v
docker compose up -d --build
```

## Демо-сценарий для эксперта

1. Открыть `http://localhost:5173`.
2. На экране входа нажать создание пользователя или зарегистрировать эксперта.
3. Создать задание: указать название, описание, чекеры и веса ровно `100%`.
4. Загрузить решение через ZIP до 50 МБ или Git URL.
5. Открыть карточку проверки, дождаться статуса `pending -> running -> done/error`.
6. Проверить ScoreCard, раскрываемые строки чекеров, AI fallback, timeline, экспорт отчета.
7. Проставить вердикт `accepted/rejected` с комментарием эксперта.

## Flutter-клиент

Flutter-код лежит в `mobile/`. Для Android emulator backend должен быть доступен как `10.0.2.2`, потому что `localhost` внутри эмулятора указывает на сам эмулятор.

```bash
cd mobile
flutter pub get
flutter run --dart-define=AUTOCHECK_API_URL=http://10.0.2.2:8080/api/v1
```

Для desktop/web Flutter можно использовать:

```bash
flutter run --dart-define=AUTOCHECK_API_URL=http://localhost:8080/api/v1
```

## Что закрыто по конкурсному заданию

- REST API живёт под `/api/v1`; ответы backend идут через envelope `{data,error,meta}`.
- JWT Bearer используется для защищённых endpoint-ов, login/register открыты.
- Backend разделён на `domain`, `application`, `infrastructure`, `presentation`.
- Web разделён на UI/components, Redux/RTK Query state, API client layer; компоненты не вызывают `fetch` напрямую.
- Flutter отделяет экраны, виджеты, DTO-модели и `BackendRepository` как network/data layer.
- Логи есть на backend, web и Flutter: `DEBUG`, `INFO`, `ERROR`; ключевые действия upload/rerun/verdict/login/create assignment логируются.
- Для backend в compose включён шаблон консольного лога вида `[Component]: LEVEL event details`.
- Web и Flutter содержат структурные комментарии у ключевых компонентов, экранов, репозиториев и DTO.
- Docker compose поднимает backend, worker, database, redis, checker image и web.
- Worker запускает проверку в Docker-контейнерах и пишет результаты в backend.
- Секреты вынесены в `.env`; пример лежит в `.env.example`.

## Визуальная проверка перед сдачей

Проверьте глазами не код, а сценарии:

- login/register: ошибки валидации, успешный переход в dashboard;
- dashboard: KPI, поиск, фильтры, таблица, status badges;
- create assignment: сумма весов должна быть `100%`, иначе кнопка создания недоступна;
- upload: ZIP/Git URL, disabled state, toast после отправки;
- details: итоговый балл, чекеры раскрываются, логи видны, rerun работает;
- report/verdict: отчет открывается, комментарий вердикта сохраняется;
- statistics: график за 30 дней и топ кандидатов не ломают адаптив.

## Ограничения, которые стоит проговорить спокойно

- Статус проверки обновляется клиентским polling. Если эксперт строго спросит про WebSocket/SSE, можно сказать, что контракт UI готов к live status, но текущая сборка использует polling как более надёжный режим для локального стенда.
- HTTPS и публичный домен не включены в локальный compose; для площадки достаточно локального запуска, для облака нужен reverse proxy.
- AI-анализ работает, если в `.env` задан совместимый `AI_API_KEY`; без ключа UI показывает корректный fallback.
