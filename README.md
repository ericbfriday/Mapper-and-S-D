**Mapper + Search and Destroy Database Guide (Mudlet)**
This guide explains where to place your database files, how to name them, and which commands to use to inspect/import/convert/rebuild map data for both mapper and Search and Destroy (S&D).

**1) What each database is for**
Mapper DB (Aardwolf.db by default)
Used by mapper features for room/exit data and for building/rebuilding your Mudlet map from a SQLite source database. The default configured names in mapper state is Aardwolf.db.
You can copy this file from mush client. It is located in the root directory of mush client.

S&D DB (SnDdb.db by default)
Used by Search and Destroy to store mob sightings, area start rooms, keyword exceptions, and history. Default path is getMudletHomeDir() .. "/SnDdb.db".
You can copy this file from mush client. It is located in the root directory of mush client.

**2) Where to put the files**
Mudlet profile base location
Both modules resolve relative DB names from your Mudlet profile directory (getMudletHomeDir()). Mapper resolves relative native DB paths as getMudletHomeDir() .. "/<filename>".

Suggested placement
Put your DB files directly in your Mudlet profile folder:
C:\Users\username\.config\mudlet\profiles\Aardwolf

Aardwolf.db (mapper source SQLite DB)
SnDdb.db (Search and destroy database file)

S&D and mapper location:
SearchAndDestroy and mapper go under your Mudlet profile path.
You then import SearchAndDestroy.xml and mm_package.xml

**3) Naming conventions (recommended)**
Mapper source SQLite DB: Aardwolf.db (default expected name).

S&D DB: SnDdb.db by default, but any filename/path works if set via command (snd db <path>).

**4) Mapper commands you will actually use**
Check/set database paths
mapper database → show current source DB (map_db).

mapper native db → show native map DB path.

mapper native db <path> → set native map DB path if needed

Validate source SQLite before import
mapper native inspect or mapper native inspect <path>
Checks compatibility and counts. Can skip this step if you copy from mush client.

Convert/import SQLite into Mudlet map
mapper native convert → this will import rooms from Aardwolf.db into the visual map (big map)

Converts SQLite rooms/exits into Mudlet map data and saves map export (default: mmapper_converted_map.dat).

Rebuild/import shortcut commands
mapper rebuild map (it takes time. The client will temporarily freeze)

mapper import rooms (it takes time. The client will temporarily freeze)
Both run conversion from current map_db and then re-center player view if possible.

mapper rebuild layout → run this is big map doesn't look ok. This will fix it. Sometimes an area will look slightly off. Running this command will fix it.

More mapper commands for building/rebuilding/coloring map are found under "mapper help config"

**5) S&D database commands**
Show DB status/path
snd db → shows current path, file exists/not found, connection status, tables, and profile dir.

Point S&D to a different DB file
snd db /full/path/to/snd.db
This sets snd.db.file and immediately initializes the DB connection.

Default behavior if DB is missing
If configured S&D DB file is not found, S&D prints an error and tells you to copy DB into your Mudlet home dir.

**6) Typical first-time setup workflow**
Install/load mapper + S&D modules in Mudlet.

Copy your old SQLite mapper DB into Mudlet profile as Aardwolf.db (recommended to use this name because it is preconfigured).

Run mapper set database Aardwolf.db (should not be needed).

Run mapper native inspect to validate schema/counts before import.

Run mapper rebuild map (or mapper native convert) to import rooms/exits into Mudlet format.

If needed, run mapper native db mmapper_converted_map.dat and mapper native load to load the converted file explicitly.

Place/copy S&D DB as SnDdb.db in Mudlet profile (or keep custom path).

Run snd db to verify S&D path and connection, then snd db /path/to/your/snd.db if you want a different file.

**7) Quick troubleshooting**
mapper native load fails with “looks like SQLite” / not a Mudlet map file
You attempted to load a raw SQLite DB. Use mapper native convert (or mapper rebuild map) first, then load the resulting map export if needed.

mapper native inspect says schema mismatch
Your source DB doesn’t have required room/exit columns. Verify source DB comes from compatible Aard/MUSHclient mapper schema.

S&D says DB file not found
Wrong path or filename. Either copy DB into Mudlet profile as SnDdb.db or run snd db /full/path/file.db to point to it.

snd db shows file exists but no useful data
Open snd db output and check tables/contents count; your file may be an unexpected schema or empty DB.

Import commands do nothing / no mapper responses
Verify mapper module is loaded and use path display commands (mapper database, mapper native db) to confirm the file being referenced is the one you expect.

Nothing is working
Close Mudlet and use Mushclient :)
