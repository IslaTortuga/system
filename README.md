# system
Standardization module for directories, files and locales

## Attributes
`paths`: A table with all existent paths (read only)

```lua
{
    info = "/usr/info/",
    config = "/usr/config/",
    temp = "/usr/temp/",
    locales = "/usr/locales/",
    messages = "/usr/locales/messages/",
    apis = "/usr/apis/",
    modules = "/usr/modules/",
    programs = "/usr/programs/",
    startup = "/startup/"
    home = "/home/",
}
```

`locales`: A table with locales (read only)
```lua
{
    language = "en",
    timezone = "UTC"
}
```

## Methods

`import`: Imports a module given its name

`isInstalled`: Check if a package is installed

`getMessages`: Retrieves all messages of a given program

`getVersion`: Returns package version

`loadAPI`: Loads an api given its name

`loadConfig`: Loads a config file given its name

`loadInfo`: Loads a info file given its name

`run`: Runs a program/command given its name

`setLanguage`: Set language locale

`setTimezone`: Set timezone locale

`writeConfig`: Writes a config file given its name