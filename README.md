# АСУДД [v2]

_Автоматизированые системы управления дорожным движением_

## Описание

### Статус: `Development`

---

## Структура базы даных

### Типы

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

### Сущности

Адаптер: Postgres

Расширения:
- plpgsql
- hstore
- pg_cron
- pgrouting
- postgis
- postgis_raster
- postgis_topology
- postgis_sfcgal?   (см. [Дайджест](#дайджест))

#### Обьект [table:objects]

_Базовая сущность всей архитектуры_

| Поле        | Тип                      | Описание                    |
| ----------- | ------------------------ | --------------------------- |
| id          | INTEGER                  | Идентификатор обьекта       |
| type        | OBJECT_TYPE              | Тип обьекта                 |
| is_active   | BOOLEAN                  | Статус активности обьекта   |
| attributes  | JSONB / HSTORE           | Доп. атрибуты обьекта.      |
| created_at  | TIMESTAMP                | Время создания обьекта      |
| updated_at  | TIMESTAMP                | Время обновления обьекта    |

#### Перекресток [table:object_crossroads]

_Наследует атрибуты принадлежной базовой сущности `objects`_

| Поле        | Тип                      | Описание                    |
| ----------- | ------------------------ | --------------------------- |
| id          | INTEGER                  | Идентификатор обьекта       |
| name        | TEXT                     | Название перекрестка        |

- `<id>` ссылается на запись в `table:objects` ONE-TO-ONE

#### Светофор [table:object_signals]

_Наследует атрибуты принадлежной базовой сущности `objects`_

| Поле        | Тип                      | Описание                    |
| ----------- | ------------------------ | --------------------------- |
| id          | INTEGER                  | Идентификатор обьекта       |
| standard    | OBJECT_SIGNAL_STANDARD   | ДСТУ тип стантарта          |
| kind        | OBJECT_SIGNAL_KIND       | Подтип ДК                   |

- `<id>` ссылается на запись в `table:objects` ONE-TO-ONE

#### Направление [table:object_directions]

_Наследует атрибуты принадлежной базовой сущности `objects`_

| Поле        | Тип                      | Описание                    |
| ----------- | ------------------------ | --------------------------- |
| id          | INTEGER                  | Идентификатор обьекта       |

- `<id>` ссылается на запись в `table:objects` ONE-TO-ONE

#### Зависимость обьектов [table:object_dependencies]

_Связная таблица зависимостей обьектов_

| Поле        | Тип                      | Описание                    |
| ----------- | ------------------------ | --------------------------- |
| master_id   | INTEGER                  | Идентификатор главного      |
| slave_id    | INTEGER                  | Идентификатор зависомого    |

- `<master_id>` ссылается на запись в `table:objects` MANY-TO-ONE
- `<slave_id>` ссылается на запись в `table:objects` MANY-TO-ONE
- выполняется условие `<master_id>` не идентичен `<slave_id>`

#### Геометрия [table:object_geometries]

_Глобальное позиционирование / локальное проектирование_

| Поле        | Тип                      | Описание                    |
| ----------- | ------------------------ | --------------------------- |
| id          | SERIAL                   | Идентификатор геометрии     |
| object_id   | INTEGER                  | Идентификатор обьекта       |
| geometry    | GEOMETRY                 | Геометрическая сущность     |

- `<object_id>` ссылается на запись в `table:objects` MANY-TO-ONE
- выполняется условие уникальности (`<object_id>`, `<geometry>`)

#### Изображение [table:object_pictures]

| Поле        | Тип                      | Описание                    |
| ----------- | ------------------------ | --------------------------- |
| id          | SERIAL                   | Идентификатор изображения   |
| object_id   | INTEGER                  | Идентификатор обьекта       |
| buffer      | BYTEA                    | Бинарный буфер изображения  |
| axis_width  | DECIMAL / INTEGER        | Расчетная ширина сетки      |
| axis_height | DECIMAL / INTEGER        | Расчетная высота сетки      |
| scale       | DECIMAL / INTEGER        | Коеф масштаба по карте      |
| angle       | DECIMAL / INTEGER        | Наклон по карте (радианы)   |

- `<object_id>` ссылается на запись в `table:objects` MANY-TO-ONE
- выполняется условие уникальности (`<object_id>`, `<buffer>`)

---

## Системное окружение

_Пример экземпляра системного окружения_

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

## Сервисы

### API

_префикс /api_

```sh

# получение всех глобальных точек перекрестков
[GET] /crossroad/point

# получение атрибутов перекрестка по идентификатору обьекта перекрестка
[GET] /crossroad/:id

# получение зависимых от перекрестка обьектов
[GET] /crossroad/:id/object

```

---

## Источники

- Инструмет имплементации карт в базу данных - [osm2pgsql](https://osm2pgsql.org/doc/manual.html#introduction)

- Инструмент конвертации карт - [osmosis](https://wiki.openstreetmap.org/wiki/Osmosis)

- Источник геоданных - [geofabrik](https://download.geofabrik.de/europe/ukraine.html)

- Область тестовой интеграции - [OpenStreedMap area](https://map.project-osrm.org/?z=16&center=50.443711%2C30.510782&loc=50.448227%2C30.483134&loc=50.443499%2C30.512295&loc=50.442211%2C30.520057&hl=en&alt=0&srv=0
)

- Диграммы расчетных маршрутов - [time-space diagram](https://help.miovision.com/s/article/Evaluating-signal-coordination-in-TrafficLink)

- ДСТУ тип стантарта светофоров - [DORNDI](https://dorndi.org.ua/files/upload/%D0%BF%D1%80%D0%94%D0%A1%D0%A2%D0%A3_4092_1_%D1%80%D0%B5%D0%B4.pdf)

- Скрипт имплементации геоданных
```sh
wget http://download.geofabrik.de/osm/central-europe/ukraine-map.osm.pbf

# read with osmosis and stream into osm2pgsql, note '-' arg to both
osmosis --read-bin ukraine-map.osm.pbf --write-xml - | osm2pgsql --slim -d <dbname> -
```

---

## Дайджест

- Структура базы данных [~]

    - Базовые атрибуты [+]
    - Типовые атрибуты [~]

- Глобальные геопозиции перекрестков [+]

- Адаптация изображений перекрестков под геомасштаб [+]

- Наложение зависимых обьектов на изображение перекрестка [~]

    - Светофоры [+]
    - Направления [~]

- Адаптация направлений под гео маршрутизацию [~]

- Имплементация SFCGAL для адаптера базы данных [~]

    _позволит хранить кривую/плавную геометрию в `GEOMETRY`_

- Интеграция Swagger к API сервису [~]

    _позволит структурировано описывать сервис под `OPENAPI` стандарт_

...

---
