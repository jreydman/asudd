# АСУДР [v2]

_Автоматизовані системи управління дорожнім рухом_

## Опис

### Статус: `В розробці`

---

## Структура бази даних

### Типи

> OBJECT_TYPE (ENUM) [
 'crossroad',
 'signal',
 'direction',
 ...
];

> OBJECT_GEOMETRY_GEOTYPE (ENUM) [
 'local',
 'global'
];

> OBJECT_SIGNAL_KIND (ENUM) [
 'traffic'
 'pedestrian',
 ...
];

> OBJECT_SIGNAL_STANDARD (ENUM) [
 't1.1',
 't1.2',
 ...
];

### Сутності

Адаптер: Postgres

Розширення:
- plpgsql
- hstore
- pg_cron
- pgrouting
- postgis
- postgis_raster
- postgis_topology
- postgis_sfcgal?   (див. [Стан виконання](#стан-виконання))

#### Об'єкт [table:objects]

_Базова сутність усієї архітектури_

| Поле        | Тип                      | Опис                         |
| ----------- | ------------------------ | ---------------------------- |
| id          | INTEGER                  | Ідентифікатор об'єкта        |
| type        | OBJECT_TYPE              | Тип об'єкта                  |
| is_active   | BOOLEAN                  | Статус активності об'єкта    |
| attributes  | JSONB / HSTORE           | Дод. атрибути об'єкта.       |
| created_at  | TIMESTAMP                | Час створення об'єкта        |
| updated_at  | TIMESTAMP                | Час оновлення об'єкта        |

#### Перехрестя [table:object_crossroads]

_Наслідує атрибути базової сутності `objects`_

| Поле        | Тип                      | Опис                         |
| ----------- | ------------------------ | ---------------------------- |
| id          | INTEGER                  | Ідентифікатор об'єкта        |
| name        | TEXT                     | Назва перехрестя             |

- `<id>` посилається на запис у `table:objects` ONE-TO-ONE

#### Світлофор [table:object_signals]

_Наслідує атрибути базової сутності `objects`_

| Поле        | Тип                      | Опис                         |
| ----------- | ------------------------ | ---------------------------- |
| id          | INTEGER                  | Ідентифікатор об'єкта        |
| standard    | OBJECT_SIGNAL_STANDARD   | ДСТУ тип стандарту           |
| kind        | OBJECT_SIGNAL_KIND       | Підтип ДК                    |

- `<id>` посилається на запис у `table:objects` ONE-TO-ONE

#### Напрямок [table:object_directions]

_Наслідує атрибути базової сутності `objects`_

| Поле        | Тип                      | Опис                         |
| ----------- | ------------------------ | ---------------------------- |
| id          | INTEGER                  | Ідентифікатор об'єкта        |

- `<id>` посилається на запис у `table:objects` ONE-TO-ONE

#### Залежність об'єктів [table:object_dependencies]

_Таблиця зв'язків залежностей об'єктів_

| Поле        | Тип                      | Опис                         |
| ----------- | ------------------------ | ---------------------------- |
| master_id   | INTEGER                  | Ідентифікатор головного      |
| slave_id    | INTEGER                  | Ідентифікатор залежного      |

- `<master_id>` посилається на запис у `table:objects` MANY-TO-ONE
- `<slave_id>` посилається на запис у `table:objects` MANY-TO-ONE
- виконується умова `<master_id>` не ідентичний `<slave_id>`

#### Геометрія [table:object_geometries]

_Глобальне позиціонування / локальне проектування_

| Поле        | Тип                      | Опис                         |
| ----------- | ------------------------ | ---------------------------- |
| id          | SERIAL                   | Ідентифікатор геометрії      |
| object_id   | INTEGER                  | Ідентифікатор об'єкта        |
| geometry    | GEOMETRY                 | Геометрична сутність         |
| angle       | DOUBLE PRECISION         | Нахил на карті (радіани)     |

- `<object_id>` посилається на запис у `table:objects` MANY-TO-ONE
- виконується умова унікальності (`<object_id>`, `<geometry>`)

#### Зображення [table:object_pictures]

| Поле        | Тип                      | Опис                         |
| ----------- | ------------------------ | ---------------------------- |
| id          | SERIAL                   | Ідентифікатор зображення     |
| object_id   | INTEGER                  | Ідентифікатор об'єкта        |
| buffer      | BYTEA                    | Бінарний буфер зображення    |
| axis_width  | DECIMAL / INTEGER        | Розрахункова ширина сітки    |
| axis_height | DECIMAL / INTEGER        | Розрахункова висота сітки    |
| scale       | DOUBLE PRECISION         | Коефіцієнт масштабу на карті |
| angle       | DOUBLE PRECISION         | Нахил на карті (радіани)     |

- `<object_id>` посилається на запис у `table:objects` MANY-TO-ONE
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
DATABASE_PASSWORD=admin
DATABASE_NAME=assud
DATABASE_URL=${DATABASE_ADAPTER}://${DATABASE_USER}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}

# ------------------------------------------------------------------------------

DBADMINER_HOST=${DOMAIN}-dbadminer
DBADMINER_PORT=8888
DBADMINER_USER=admin@${DOMAIN}.com
DBADMINER_PASSWORD=supersecred

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

- Інструмент імплементації карт у базу даних - [osm2pgsql](https://osm2pgsql.org/doc/manual.html#introduction)

- нструмент конвертації карт - [osmosis](https://wiki.openstreetmap.org/wiki/Osmosis)

- Джерело геоданих - [geofabrik](https://download.geofabrik.de/europe/ukraine.html)

- Джерело даних управління - [АСУДД-v1](#)

- Область тестової інтеграції - [OpenStreedMap area](https://map.project-osrm.org/?z=16&center=50.443711%2C30.510782&loc=50.448227%2C30.483134&loc=50.443499%2C30.512295&loc=50.442211%2C30.520057&hl=en&alt=0&srv=0
)

- Діаграми розрахункових маршрутів - [time-space diagram](https://help.miovision.com/s/article/Evaluating-signal-coordination-in-TrafficLink)

- ДСТУ тип стандарту світлофорів - [DORNDI](https://dorndi.org.ua/files/upload/%D0%BF%D1%80%D0%94%D0%A1%D0%A2%D0%A3_4092_1_%D1%80%D0%B5%D0%B4.pdf)

- Скрипт імплементації геоданих
```sh
wget http://download.geofabrik.de/osm/central-europe/ukraine-map.osm.pbf

# read with osmosis and stream into osm2pgsql, note '-' arg to both
osmosis --read-bin ukraine-map.osm.pbf --write-xml - | osm2pgsql --slim -d <dbname> -
```

---

## Стан виконання

[+] - виконано
[~] - в процесі
[@] - в планах

- Структура бази даних [~]
    - Базові атрибути [+]
    - Типові атрибути [~]

- Глобальні геопозиції перехресть [+]

- Адаптація зображень перехресть під геомасштаб [+]

- Накладання залежних об'єктів на зображення перехрестя [~]
    - Світлофори [+]
    - Напрямки [~]

- Адаптація напрямків під гео маршрутизацію [@]

- Імплементація SFCGAL для адаптера бази даних [@]
_дозволить зберігати криву/плавну геометрію в `GEOMETRY`_

- Інтеграція Swagger до API сервісу [@]
_дозволить структуровано описувати сервіс під `OPENAPI` стандарт_

...

---

## Концепт


![crossroad_ID_inter_state](docs/test_crossroad%20[ID]/test_crossroad%20[ID]_map_position.png)

![crossroad_ID_inter_state](docs/test_crossroad%20[ID]/test_crossroad%20[ID]_program1_inter.png)

![crossroad_ID_program1_phace1_state](docs/test_crossroad%20[ID]/test_crossroad%20[ID]_program1_phace1.png)

![crossroad_ID_program1_phace2_state](docs/test_crossroad%20[ID]/test_crossroad%20[ID]_program1_phace2.png)
