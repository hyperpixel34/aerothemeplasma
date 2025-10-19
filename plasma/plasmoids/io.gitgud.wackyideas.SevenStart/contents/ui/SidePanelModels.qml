
import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Window
import QtCore
import org.kde.plasma.plasmoid
import org.kde.plasma.private.kicker as Kicker
import org.kde.coreaddons 1.0 as KCoreAddons // kuser
import org.kde.kitemmodels as KItemModels


Item {
    id: models
    KCoreAddons.KUser {   id: kuser  }  // Used for getting the username and icon.
    Kicker.RecentUsageModel {
        id: fileUsageModel
        ordering: 0
        shownItems: Kicker.RecentUsageModel.OnlyDocs
    }

    property var firstCategory:
    [
        {
            name: "Benutzerordner",
            itemText: Plasmoid.configuration.useFullName ? kuser.fullName : kuser.loginName,
            description: "Öffnet den persönlichen Ordner.",
            itemIcon: "user-home",
            itemIconFallback: "unknown",
            executableString: StandardPaths.writableLocation(StandardPaths.HomeLocation),
            menuModel: null,
            executeProgram: false
        },
        {
            name: "Dokumente",
            itemText: "Dokumente",
            description: "Greift auf Briefe, Berichte, Notizen und andere Dokumente zu.", 
            itemIcon: "library-txt",
            itemIconFallback: "folder-library",
            executableString: StandardPaths.writableLocation(StandardPaths.DocumentsLocation),
            menuModel: null,
            executeProgram: false
        },
        {
            name: "Bilder",
            itemText: "Bilder",
            description: "Zeigt digitale Bilder an und verwaltet Sie.",
            itemIcon: "library-images",
            itemIconFallback: "folder-image",
            executableString: StandardPaths.writableLocation(StandardPaths.PicturesLocation),
            menuModel: null,
            executeProgram: false
        },
        {
            name: "Musik",
            itemText: "Musik",
            description: "Gibt Musik und andere Audiodateien wieder.",
            itemIcon: "library-music",
            itemIconFallback: "folder-music",
            executableString: StandardPaths.writableLocation(StandardPaths.MusicLocation),
            menuModel: null,
            executeProgram: false
        },
        {
            name: "Videos",
            itemText: "Videos",
            description: "Gibt Filme und andere digitale Videos wieder.", 
            itemIcon: "library-video",
            itemIconFallback: "folder-videos",
            executableString: StandardPaths.writableLocation(StandardPaths.MoviesLocation),
            menuModel: null,
            executeProgram: false
        },
        {
            name: "Downloads",
            itemText: "Downloads",
            description: "Findet Internet Downloads und Links zu Ihren Favouritenwebsites.",
            itemIcon: "folder-download",
            itemIconFallback: "folder-download",
            executableString: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/Downloads",
            menuModel: null,
            executeProgram: false
        },

    ]
    property var secondCategory:
    [
        {
            name: "Spiele",
            itemText: "Spiele",
            description: "Verwaltet Spiele auf dem Computer.",
            itemIcon: "applications-games",
            itemIconFallback: "folder-games",
            executableString: "applications:///Games/",
            menuModel: null,
            executeProgram: false
        },
        {
            name: "Zuletzt verwendet",
            itemText: "Zuletzt verwendet",
            description: "",
            itemIcon: "document-open-recent",
            itemIconFallback: "folder-documents",
            executableString: "recentlyused:/",
            menuModel: fileUsageModel,
            executeProgram: false
        },
        {
            name: "Computer",
            itemText: "Computer",
            description: "Zeigt Laufwerke und andere an den Computer angeschlossene Hardware an.",
            itemIcon: "computer",
            itemIconFallback: "unknown",
            executableString: "file:///.",
            menuModel: null,
            executeProgram: false
        },
        {
            name: "Netzwerk",
            itemText: "Netzwerk",
            description: "Bietet Zugriff auf Computer und Geräte im Netzwerk.",
            itemIcon: "folder-network",
            itemIconFallback: "network-server",
            executableString: "remote:/",
            menuModel: null,
            executeProgram: false
        },
    ]
    property var thirdCategory:
    [
        {
            name: "Systemsteuerung",
			itemText: "Systemsteuerung",
            description: "Ändert Einstellungen, und passt die Funktionalität des Computers an.",
			itemIcon: "preferences-system",
			itemIconFallback: "preferences-desktop",
			executableString: "systemsettings",
			executeProgram: true,
            menuModel: null,
        },
        {
            name: "Geräte und Drucker",
			itemText: "Geräte und Drucker",
            description: "Zeigt Geräte, Drucker und Druckaufträge an und verwaltet sie.",
			itemIcon: "input_devices_settings",
			itemIconFallback: "printer",
			executableString: "systemsettings kcm_printer_manager",
			executeProgram: true,
            menuModel: null,
        },
        {
            name: "Standardprogramme",
			itemText: "Standardprogramme",
            description: "Wählt Standardprogramme für Browsen, E-Mail, Musikwiedergabe und andere Aktivitäten aus.",
			itemIcon: "preferences-desktop-default-applications",
			itemIconFallback: "application-x-executable",
			executableString: "systemsettings kcm_componentchooser",
			executeProgram: true,
            menuModel: null,
        },
        {
            name: "Hilfe und Support",
			itemText: "Hilfe und Support",
            description: "Sucht Hilfethemen, Lernprogramme, Problembehandlung und andere Supportdienste.",
			itemIcon: "help-browser",
			itemIconFallback: "system-help",
			executableString: "https://develop.kde.org/docs/",
			executeProgram: false,
            menuModel: null,
        },
        {
            name: "Ausführen...",
			itemText: "Ausführen...",
            description: "Öffnet ein Programm, einen Ordner, ein Dokument oder eine Website.",
			itemIcon: "krunner",
			itemIconFallback: "system-run",
			executableString: "krunner --replace",
			executeProgram: true,
            menuModel: null,
        },
        /*{
            name: "Donate",
			itemText: "Donate",
			itemIcon: "favorites",
			itemIconFallback: "emblem-favorite",
			executableString: "https://ko-fi.com/M4M2NJ9PJ",
			executeProgram: false,
            menuModel: null,
        },*/
    ]

}
