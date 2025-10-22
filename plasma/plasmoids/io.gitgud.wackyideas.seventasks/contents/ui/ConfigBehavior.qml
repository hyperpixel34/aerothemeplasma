/*
    SPDX-FileCopyrightText: 2013 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.19 as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.kcmutils as KCM

import org.kde.plasma.workspace.dbus as DBus

KCM.SimpleKCM {

    readonly property bool iconsOnly: !Plasmoid.configuration.showLabels
    property alias cfg_groupingStrategy: groupingStrategy.currentIndex
    property alias cfg_groupedTaskVisualization: groupedTaskVisualization.currentIndex
    property alias cfg_groupPopups: groupPopups.checked
    property alias cfg_onlyGroupWhenFull: onlyGroupWhenFull.checked
    property alias cfg_sortingStrategy: sortingStrategy.currentIndex
    property alias cfg_separateLaunchers: separateLaunchers.checked
    property alias cfg_hideLauncherOnStart: hideLauncherOnStart.checked
    property alias cfg_middleClickAction: middleClickAction.currentIndex
    property alias cfg_wheelEnabled: wheelEnabled.checked
    property alias cfg_wheelSkipMinimized: wheelSkipMinimized.checked
    property alias cfg_showOnlyCurrentScreen: showOnlyCurrentScreen.checked
    property alias cfg_showOnlyCurrentDesktop: showOnlyCurrentDesktop.checked
    property alias cfg_showOnlyCurrentActivity: showOnlyCurrentActivity.checked
    property alias cfg_showOnlyMinimized: showOnlyMinimized.checked
    property alias cfg_minimizeActiveTaskOnClick: minimizeActive.checked
    property alias cfg_unhideOnAttention: unhideOnAttention.checked
    property alias cfg_reverseMode: reverseMode.checked

    DBus.DBusServiceWatcher {
        id: effectWatcher
        busType: DBus.BusType.Session
        watchedService: "org.kde.KWin.Effect.WindowView1"
    }

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right


        ComboBox {
            id: groupingStrategy
            Kirigami.FormData.label: i18n("Gruppierung:")
            Layout.fillWidth: true
            Layout.minimumWidth: Kirigami.Units.iconSizes.small * 14
            model: [i18n("Nicht gruppieren"), i18n("Nach Programmname")]
            visible: false
        }

        ComboBox {
            id: groupedTaskVisualization
            Kirigami.FormData.label: i18n("Click auf gruppierten Task:")
            Layout.fillWidth: true
            Layout.minimumWidth: Kirigami.Units.iconSizes.small * 14

            enabled: groupingStrategy.currentIndex !== 0
            visible: false

            model: [
                i18nc("Vervollständigt den Satz 'Clicking grouped task cycles through tasks' ", "Wechselt durch Tasks"),
                i18nc("Vervollständigt den Satz 'Clicking grouped task shows tooltip window thumbnails' ", "Zeigt kleine Fensterpreviews"),
                i18nc("Vervollständigt den Satz 'Clicking grouped task shows windows side by side' ", "Zeigt große Fensterpreviews"),
                i18nc("Vervollständigt den Satz 'Clicking grouped task shows textual list' ", "Zeigt eine Textliste an"),
            ]

            Accessible.name: currentText
            Accessible.onPressAction: currentIndex = currentIndex === count - 1 ? 0 : (currentIndex + 1)
        }
        // "You asked for Window View but Window View is not available" message
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: groupedTaskVisualization.currentIndex === 2 && !effectWatcher.registered
            type: Kirigami.MessageType.Warning
            text: i18n("Der Compositor unterstützt die Anzeige von Fenstern nebeneinander nicht, daher wird stattdessen eine Textliste angezeigt.")
        }


        CheckBox {
            id: onlyGroupWhenFull
            visible: !iconsOnly //(Plasmoid.pluginName !== "org.kde.plasma.icontasks")
            text: i18n("Gruppieren wenn der Task Manager voll ist")
            enabled: groupingStrategy.currentIndex > 0 && groupPopups.checked
            Accessible.onPressAction: toggle()
        }

        Item {
            Kirigami.FormData.isSection: true
            visible: !iconsOnly //(Plasmoid.pluginName !== "org.kde.plasma.icontasks")
        }

        ComboBox {
            id: sortingStrategy
            Kirigami.FormData.label: i18n("Sort:")
            Layout.fillWidth: true
            Layout.minimumWidth: Kirigami.Units.iconSizes.small * 14
            model: [i18n("Nicht sortieren"), i18n("Manuell"), i18n("Alphabetisch"), i18n("Nach Desktop"), i18n("Nach Aktivität")]
        }

        CheckBox {
            id: groupPopups
            //visible: !iconsOnly//(Plasmoid.pluginName !== "org.kde.plasma.icontasks")
            text: i18n("Tasks gruppieren")
        }
        CheckBox {
            id: separateLaunchers
            visible: !iconsOnly//(Plasmoid.pluginName !== "org.kde.plasma.icontasks")
            text: i18n("Launcher getrennt halten")
            enabled: sortingStrategy.currentIndex == 1
        }

        CheckBox {
            id: hideLauncherOnStart
            visible: !iconsOnly//(Plasmoid.pluginName !== "org.kde.plasma.icontasks")
            text: i18n("Launcher nach Start verstecken")
        }

        Item {
            Kirigami.FormData.isSection: true
            visible: !iconsOnly//(Plasmoid.pluginName !== "org.kde.plasma.icontasks")
        }

        CheckBox {
            id: minimizeActive
            Kirigami.FormData.label: i18nc("Teil eines Satzes: 'Clicking active task minimizes the task'", "Beim Anklicken einer aktiven Task:")
            text: i18nc("Part of a sentence: 'Clicking active task minimizes the task'", "Minimieren")
        }

        ComboBox {
            id: middleClickAction
            Kirigami.FormData.label: i18n("Mittelklick auf Task:")
            Layout.fillWidth: true
            Layout.minimumWidth: Kirigami.Units.iconSizes.small * 14
            model: [
                i18nc("Part of a sentence: 'Middle-clicking any task does nothing'", "Nichts"),
                i18nc("Part of a sentence: 'Middle-clicking any task closes window or group'", "Schließt Fenster oder Gruppe"),
                i18nc("Part of a sentence: 'Middle-clicking any task opens a new window'", "Öffnet ein neues Fenster"),
                i18nc("Part of a sentence: 'Middle-clicking any task minimizes/restores window or group'", "Minimizes/Restores window or group"),
                i18nc("Part of a sentence: 'Middle-clicking any task toggles grouping'", "Toggles grouping"),
                i18nc("Part of a sentence: 'Middle-clicking any task brings it to the current virtual desktop'", "Brings it to the current virtual desktop")
            ]
        }

        Item {
            Kirigami.FormData.isSection: true
        }


        CheckBox {
            id: wheelEnabled
            Kirigami.FormData.label: i18nc("Part of a sentence: 'Mouse wheel cycles through tasks'", "Mausrad:")
            text: i18nc("Part of a sentence: 'Mouse wheel cycles through tasks'", "Wechselt durch Tasks")
            visible: false
        }

        RowLayout {
            visible: false
            // HACK: Workaround for Kirigami bug 434625
            // due to which a simple Layout.leftMargin on CheckBox doesn't work
            Item { implicitWidth: Kirigami.Units.iconSizes.small }
            CheckBox {
                id: wheelSkipMinimized
                text: i18n("Überspringe minimierte Tasks")
                enabled: wheelEnabled.checked
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        CheckBox {
            id: showOnlyCurrentScreen
            Kirigami.FormData.label: i18n("Tasks anzeigen von:")
            text: i18n("Aktuellem Bildschirm")
        }

        CheckBox {
            id: showOnlyCurrentDesktop
            text: i18n("Aktuellem Desktop")
        }

        CheckBox {
            id: showOnlyCurrentActivity
            text: i18n("Aktueller Aktivität")
        }

        CheckBox {
            id: showOnlyMinimized
            text: i18n("Nur minimierte")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        CheckBox {
            id: unhideOnAttention
            Kirigami.FormData.label: i18n("Wenn das Panel versteckt ist:")
            text: i18n("Einblenden, wenn ein Fenster Aufmerksamkeit erfordert")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        ButtonGroup {
            id: reverseModeRadioButtonGroup
        }

        RadioButton {
            Kirigami.FormData.label: i18n("Neue Task startet:")
            checked: !reverseMode.checked
            text: {
                if (Plasmoid.formFactor === PlasmaCore.Types.Vertical) {
                    return i18n("Unten")
                }
                // horizontal
                if (Qt.application.layoutDirection === Qt.LeftToRight) {
                    return i18n("Rechts");
                } else {
                    return i18n("Links")
                }
            }
            ButtonGroup.group: reverseModeRadioButtonGroup
            visible: reverseMode.visible
        }

        RadioButton {
            id: reverseMode
            checked: Plasmoid.configuration.reverseMode === true
            text: {
                if (Plasmoid.formFactor === PlasmaCore.Types.Vertical) {
                    return i18n("Oben")
                }
                // horizontal
                if (Qt.application.layoutDirection === Qt.LeftToRight) {
                    return i18n("Links");
                } else {
                    return i18n("Rechts");
                }
            }
            ButtonGroup.group: reverseModeRadioButtonGroup
        }

    }
}
