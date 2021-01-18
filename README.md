# rutracker-dl-lost

Скрипт предназначен для скачивания torrent-файлов популярного треккера [RuTracker.org](https://rutracker.org), нуждающихся в дополнительном сидировании.
Данный скрипт может быть полезен кандидатам в группу [Хранители](https://rutracker.org/forum/viewtopic.php?t=3118460) треккера для быстрого старта.

## Формат вызова

```
./dl-forum-lost.sh номер_раздела_форума папка_для_скачивания_торрентов
```

Пример:

```
./dl-forum-lost.sh 2287 rutracker-2287-jazz/#torrents
```

Если в том же каталоге, что и скрипт `dl-forum-lost.sh` расположить скрипт с именем `add_torrent.sh`, то он будет запускаться для каждого скаченного торрента.
Смотрите пример `add_torrent-example.sh` - это актуальный скрипт, используемый мной.
