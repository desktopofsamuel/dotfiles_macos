# Homebrew cask + Mac App Store (mas) catalog for setup_homebrew.zsh (nested UI).
# Each BREW_CASKS_* list mixes cask tokens (e.g. ghostty) and MAS lines as mas:<numeric_id>.
# Human names for MAS rows come from BREW_MAS_NAME (key = id without mas: prefix).

typeset -ga BREW_CASK_CATEGORY_ORDER=(
    utility
    productivity
    communication
    web_development
    native_development
    general_development
    media
)

typeset -A BREW_CASK_CATEGORY_LABEL=(
    utility              "Utility"
    productivity         "Productivity"
    communication        "Communication"
    web_development      "Web development"
    native_development   "Native development"
    general_development  "General development"
    media                "Media & finance"
)

# Lookup for mas:<id> rows in the lists below (id -> short name)
typeset -A BREW_MAS_NAME=(
    1091189122           "Bear"
    425264550            "Blackmagic Disk Speed Test"
    1435957248           "Drafts"
    406056744            "Evernote"
    682658836            "GarageBand"
    1502839586           "Hand Mirror"
    1294126402           "HEIC Converter"
    1474276998           "HP"
    967004861            "HP Easy Scan"
    408981434            "iMovie"
    409183694            "Keynote"
    1196268448           "Klib"
    1661733229           "LocalSend"
    985367838            "Microsoft Outlook"
    1274495053           "Microsoft To Do"
    409203825            "Numbers"
    361304891            "Numbers (alternate)"
    409201541            "Pages"
    6714467650           "Perplexity"
    1444636541           "Photomator"
    1611378436           "Pure Paste"
    1566621533           "ScreenHint"
    1153157709           "Speedtest"
    747648890            "Telegram"
    899247664            "TestFlight"
    425424353            "The Unarchiver"
    966085870            "TickTick"
    585829637            "Todoist"
    423123087            "UnPlugged"
    1284863847           "Unsplash Wallpapers"
    497799835            "Xcode"
)

# System / Mac utilities & maintenance (casks + relevant MAS utilities)
typeset -ga BREW_CASKS_utility=(
    ghostty
    input-source-pro
    itsycal
    keepingyouawake
    monitorcontrol
    sf-symbols
    vanilla
    hiddenbar
    fujitsu-scansnap-home
    teamviewer
    imageoptim
    transmission
    mas:425264550
    mas:1502839586
    mas:1294126402
    mas:1474276998
    mas:967004861
    mas:1611378436
    mas:1566621533
    mas:1153157709
    mas:425424353
    mas:423123087
)

# Notes, tasks, writing, iWork, etc.
typeset -ga BREW_CASKS_productivity=(
    raycast
    notion
    notion-calendar
    obsidian
    granola
    hazel
    setapp
    trackweight
    mas:1091189122
    mas:1435957248
    mas:406056744
    mas:409183694
    mas:1196268448
    mas:1274495053
    mas:409203825
    mas:361304891
    mas:409201541
    mas:6714467650
    mas:966085870
    mas:585829637
)

typeset -ga BREW_CASKS_communication=(
    zoom
    whatsapp
    slack
    mas:985367838
    mas:747648890
    mas:1661733229
)

typeset -ga BREW_CASKS_web_development=(
    arc
    google-chrome
    figma
    figma@beta
)

# IDEs, Apple dev tools (casks + Xcode / TestFlight from MAS)
typeset -ga BREW_CASKS_native_development=(
    cursor
    visual-studio-code
    github
    mas:497799835
    mas:899247664
)

typeset -ga BREW_CASKS_general_development=(
    postman
    linear-linear
    ollama-app
)

# Media & creative (casks + MAS creative apps)
typeset -ga BREW_CASKS_media=(
    spotify
    vlc
    tradingview
    mas:682658836
    mas:408981434
    mas:1444636541
    mas:1284863847
)
