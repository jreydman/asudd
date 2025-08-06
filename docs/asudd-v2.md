# АСУДР [v2]

_Автоматизовані системи управління дорожнім рухом_

## Опис

### Статус: `Розробка`

---

## Структура бази даних

### Типи

> OBJECT_TYPE (ENUM) [ 'crossroad', 'signal', 'direction', 'gateway' ... ];

> OBJECT_GEOMETRY_GEOTYPE (ENUM) [ 'local', 'global' ];

> OBJECT_SIGNAL_KIND (ENUM) [ 'traffic' 'pedestrian', ... ];

> OBJECT_SIGNAL_STANDARD (ENUM) [ 't1.1', 't1.2', ... ];

> OBJECT_DIRECTION_DEFINITION (ENUM) [ 'internal', 'external', ];

### Сутності

Адаптер: Postgres

Шари:
- public
- geometry_layout
- topology_layout
- osm_`<AREA>`_layout / _авто-імплементація_ ([див. Джерела>cкрипт імплементації геоданих](#джерела))

Розширення:

- plpgsql
- hstore
- pg_cron
- pgrouting
- postgis
- postgis_raster
- postgis_topology
- postgis_sfcgal? (див. [Стан виконання](#стан-виконання))

#### Об'єкт [table:public.objects]

_Базова сутність усієї архітектури_

| Поле       | Тип            | Опис                      |
| ---------- | -------------- | ------------------------- |
| id         | INTEGER        | Ідентифікатор об'єкта     |
| type       | OBJECT_TYPE    | Тип об'єкта               |
| is_active  | BOOLEAN        | Статус активності об'єкта |
| attributes | JSONB / HSTORE | Дод. атрибути об'єкта.    |
| created_at | TIMESTAMP      | Час створення об'єкта     |
| updated_at | TIMESTAMP      | Час оновлення об'єкта     |

#### Перехрестя [table:public.object_crossroads]

_Наслідує атрибути базової сутності `objects`_

| Поле | Тип     | Опис                  |
| ---- | ------- | --------------------- |
| id   | INTEGER | Ідентифікатор об'єкта |
| name | TEXT    | Назва перехрестя      |

- `<id>` посилається на запис у `table:public.objects` ONE-TO-ONE

#### Світлофор [table:public.object_signals]

_Наслідує атрибути базової сутності `objects`_
_Сутність для ідентифікації світлофорів_

| Поле     | Тип                    | Опис                  |
| -------- | ---------------------- | --------------------- |
| id       | INTEGER                | Ідентифікатор об'єкта |
| standard | OBJECT_SIGNAL_STANDARD | ДСТУ тип стандарту    |
| kind     | OBJECT_SIGNAL_KIND     | Підтип ДК             |

- `<id>` посилається на запис у `table:public.objects` ONE-TO-ONE

#### Напрямок [table:public.object_directions]

_Наслідує атрибути базової сутності `objects`_
_Сутність для ідентифікації шляхів руху на перехресті_

| Поле | Тип     | Опис                  |
| ---- | ------- | --------------------- |
| id   | INTEGER | Ідентифікатор об'єкта |

- `<id>` посилається на запис у `table:public.objects` ONE-TO-ONE

### Шлюзи [table:public.object_gateways]

_Наслідує атрибути базової сутності `objects`_
_Сутність для ідентифікації шлюзів (вхід/вихід) перехрестя_

| Поле        | Тип     | Опис                      |
| ----------- | ------- | ------------------------- |
| id          | INTEGER | Ідентифікатор об'єкта     |
| is_inbound  | BOOLEAN | Ключ входу до перехрестя  |
| is_outbound | BOOLEAN | Ключ виходу із перехрестя |

- `<id>` посилається на запис у `table:public.objects` ONE-TO-ONE
- виконується умова дійсності (`<is_inbound>` або `<is_outbound>`)

#### Залежність об'єктів [table:public.object_dependencies]

_Таблиця зв'язків залежностей об'єктів_

| Поле      | Тип     | Опис                    |
| --------- | ------- | ----------------------- |
| master_id | INTEGER | Ідентифікатор головного |
| slave_id  | INTEGER | Ідентифікатор залежного |

- `<master_id>` посилається на запис у `table:public.objects` MANY-TO-ONE
- `<slave_id>` посилається на запис у `table:public.objects` MANY-TO-ONE
- виконується умова `<master_id>` не ідентичний `<slave_id>`

```summary
# аннотація

MASTER                    | ==> | SLAVE
---------------------------------------------------------
crossroad_id:N            |     | signal_id:N
crossroad_id:N            |     | direction_id:N
---------------------------------------------------------
signal_id:N               |     | direction_id:N
---------------------------------------------------------

# Специфікація для залежностей `шлюз/напрямок` це нотується як (куди ===> звідки)

direction_id:N            |     | gateway_id:N (inbound)
gateway_id:N (outbound)   |     | direction_id:N
```

#### Геометрія [table:geometry_layout.object_geometries]

_Глобальне позиціонування / локальне проектування_

| Поле      | Тип              | Опис                     |
| --------- | ---------------- | ------------------------ |
| id        | SERIAL           | Ідентифікатор геометрії  |
| object_id | INTEGER          | Ідентифікатор об'єкта    |
| figure    | GEOMETRY         | Геометрична сутність     |
| angle     | DOUBLE PRECISION | Нахил на карті (радіани) |

- `<object_id>` посилається на запис у `table:public.objects` MANY-TO-ONE
- виконується умова унікальності (`<object_id>`, `<geometry>`)

#### Зображення [table:object_pictures]

| Поле        | Тип               | Опис                         |
| ----------- | ----------------- | ---------------------------- |
| id          | SERIAL            | Ідентифікатор зображення     |
| object_id   | INTEGER           | Ідентифікатор об'єкта        |
| buffer      | BYTEA             | Бінарний буфер зображення    |
| axis_width  | DECIMAL / INTEGER | Розрахункова ширина сітки    |
| axis_height | DECIMAL / INTEGER | Розрахункова висота сітки    |
| scale       | DOUBLE PRECISION  | Коефіцієнт масштабу на карті |
| angle       | DOUBLE PRECISION  | Нахил на карті (радіани)     |

- `<object_id>` посилається на запис у `table:public.objects` MANY-TO-ONE
- виконується умова унікальності (`<object_id>`, `<buffer>`)

---

## Системне оточення

_Приклад екземпляру системного оточення_

```.env
DOMAIN=traffic-lights
NETWORK=traffic-lights-network

# ------------------------------------------------------------------------------

WEBCLIENT_HOST=${DOMAIN}-webclient
WEBCLIENT_PORT=3000

# -------------------------------------------------------------------------------

APISERVER_HOST=${DOMAIN}-api-server
APISERVER_PORT=3001

# ------------------------------------------------------------------------------

DATABASE_HOST=${DOMAIN}-database
DATABASE_ADAPTER=postgres
DATABASE_PORT=5432
DATABASE_USER=admin
DATABASE_PASSWORD=supersecret
DATABASE_NAME=asudd
DATABASE_URL=${DATABASE_ADAPTER}://${DATABASE_USER}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}

# ------------------------------------------------------------------------------

DBADMINER_HOST=${DOMAIN}-dbadminer
DBADMINER_PORT=8888
DBADMINER_USER=admin@${DOMAIN}.com
DBADMINER_PASSWORD=supersecret

# ------------------------------------------------------------------------------
```

---

## Сервіси

### API

_префікс /api_

```sh
# отримання усіх глобальних точок перехресть
[GET] /crossroad/point

# отримання атрибутів перехрестя за ідентифікатором об'єкта перехрестя
[GET] /crossroad/:id

# отримання залежних від перехрестя об'єктів
[GET] /crossroad/:id/object
```

---

## Джерела

- Інструмент імплементації карт у базу даних -
  [osm2pgsql](https://osm2pgsql.org/doc/manual.html#introduction)

- нструмент конвертації карт -
  [osmosis](https://wiki.openstreetmap.org/wiki/Osmosis)

- Джерело геоданих -
  [geofabrik](https://download.geofabrik.de/europe/ukraine.html)

- Джерело даних управління - [АСУДД-v1](#)

- Область тестової інтеграції -
  [OpenStreedMap area](https://www.openstreetmap.org/edit#map=19/50.444072/30.509295)

- Діаграми розрахункових маршрутів -
  [time-space diagram](https://help.miovision.com/s/article/Evaluating-signal-coordination-in-TrafficLink)

- ДСТУ тип стандарту світлофорів -
  [DORNDI](https://dorndi.org.ua/files/upload/%D0%BF%D1%80%D0%94%D0%A1%D0%A2%D0%A3_4092_1_%D1%80%D0%B5%D0%B4.pdf)

- Скрипт імплементації геоданих
```sh
# завантажити область тестової інтеграції
wget http://download.geofabrik.de/osm/central-europe/ukraine-map.osm.pbf

# відрезолювати область
# left:min(longtitude)  right:max(longtitude)
# top:max(latitude)     bottom:min(latitude)
osmosis --read-pbf file="ukraine-latest.osm.pbf" \
        --bounding-box top=50.492 left=30.408 bottom=50.420 right=30.540 \
        --write-xml file="ukraine-kyiv-latest.osm"

# записати область в базу даних
osm2pgsql --database="<dbname>" \
          --user="<user>" \
          --host="<host>" \
          --port="<port>" \
          --password \
          --schema="osm_ukraine-kyiv_layout" \
          --slim \
          ./ukraine-kyiv-latest.osm
```

---

## Стан виконання

[+] - виконано [~] - в процесі [@] - в планах

- Структура бази даних [~]
  - Базові атрибути [+]
  - Типові атрибути [~]

    - Перехрестя [~]
    - Світлофори [~]
    - Напрямки [~]
    - Порти [~]

- Глобальні геопозиції перехресть [+]

- Адаптація зображень перехресть під геомасштаб [+]

- Накладання залежних об'єктів на зображення перехрестя [~]
  - Світлофори [+]
  - Напрямки [+]
  - Порти [~]

- Адаптація напрямків під гео маршрутизацію [~]

- Імплементація SFCGAL для адаптера бази даних [@] _дозволить зберігати
  криву/плавну геометрію в `GEOMETRY`_

- Інтеграція Swagger до API сервісу [@] _дозволить структуровано описувати
  сервіс під `OPENAPI` стандарт_

...

---
