/*
 *    SPDX-FileCopyrightText: 2013 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 *    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15

import org.kde.kquickcontrolsaddons 2.0 // For kcmshell
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.private.digitalclock 1.0
import org.kde.kirigami as Kirigami

import org.kde.kcmutils as KCMUtils
import org.kde.config // KAuthorized

KCMUtils.ScrollViewKCM {
    id: timeZonesPage

    property alias cfg_selectedTimeZones: timeZones.selectedTimeZones
    property alias cfg_wheelChangesTimezone: enableWheelCheckBox.checked

    TimeZoneModel {
        id: timeZones

        onSelectedTimeZonesChanged: {
            if (selectedTimeZones.length === 0) {
                // Verhindern, dass alle Zeitzonen entfernt werden
                messageWidget.visible = true;
                timeZones.selectLocalTimeZone();
            }
        }
    }

    header: ColumnLayout {
        spacing: Kirigami.Units.smallSpacing

        QQC2.Label {
            Layout.fillWidth: true
            text: i18n("Tipp: Wenn Sie häufig reisen, fügen Sie bitte Ihre Heimatzeitzone dieser Liste hinzu. Sie wird nur angezeigt, wenn Sie die systemweite Zeitzone ändern.")
            wrapMode: Text.Wrap
        }
    }

    view: ListView {
        id: configuredTimezoneList
        clip: true
        focus: true
        activeFocusOnTab: true

        model: TimeZoneFilterProxy {
            sourceModel: timeZones
            onlyShowChecked: true
        }

        currentIndex: -1

        delegate: Kirigami.RadioSubtitleDelegate {
            id: timeZoneListItem

            readonly property bool isCurrent: Plasmoid.configuration.lastSelectedTimezone === model.timeZoneId
            readonly property bool isIdenticalToLocal: !model.isLocalTimeZone && model.city === timeZones.localTimeZoneCity()

            width: ListView.view.width

            font.bold: isCurrent

            Kirigami.Theme.useAlternateBackgroundColor: true

            text: model.city
            subtitle: {
                if (configuredTimezoneList.count > 1) {
                    if (isCurrent) {
                        return i18n("Die Uhr verwendet derzeit diese Zeitzone.");
                    } else if (isIdenticalToLocal) {
                        return i18nc("@label Diese Zeitzone entspricht der lokalen Zeitzone und wird ausgeblendet", "Diese Zeitzone wird ausgeblendet, da es sich um die Stadt Ihrer lokalen Zeitzone handelt.");
                    }
                }
                return "";
            }

            checked: isCurrent
            onToggled: Plasmoid.configuration.lastSelectedTimezone = model.timeZoneId

            contentItem: RowLayout {
                spacing: Kirigami.Units.smallSpacing

                Kirigami.TitleSubtitle {
                    Layout.fillWidth: true
                    opacity: timeZoneListItem.isIdenticalToLocal ? 0.6 : 1.0

                    title: timeZoneListItem.text
                    subtitle: timeZoneListItem.subtitle

                    reserveSpaceForSubtitle: true
                }

                QQC2.Button {
                    visible: model.isLocalTimeZone && KAuthorized.authorizeControlModule("kcm_clock.desktop")
                    text: i18n("Systemweite Zeitzone ändern…")
                    icon.name: "preferences-system-time"
                    font.bold: false
                    onClicked: KCMUtils.KCMLauncher.openSystemSettings("kcm_clock")
                }

                QQC2.Button {
                    visible: !model.isLocalTimeZone && configuredTimezoneList.count > 1
                    icon.name: "edit-delete"
                    font.bold: false
                    onClicked: model.checked = false;
                    QQC2.ToolTip {
                        text: i18n("Diese Zeitzone entfernen")
                    }
                }
            }
        }

        section {
            property: "isLocalTimeZone"
            delegate: Kirigami.ListSectionHeader {
                width: configuredTimezoneList.width
                label: section === "true" ? i18n("Systemweite Zeitzone") : i18n("Weitere Zeitzonen")
            }
        }

        Kirigami.PlaceholderMessage {
            visible: configuredTimezoneList.count === 1
            anchors {
                top: parent.verticalCenter
                left: parent.left
                right: parent.right
                leftMargin: Kirigami.Units.largeSpacing * 6
                rightMargin: Kirigami.Units.largeSpacing * 6
            }
            text: i18n("Bitte fügen Sie weitere Zeitzonen hinzu, um alle im Pop-up des Applets anzuzeigen, oder wählen Sie eine davon für die Uhr aus.")
        }
    }

    footer: ColumnLayout {
        spacing: Kirigami.Units.smallSpacing

        QQC2.Button {
            Layout.alignment: Qt.AlignLeft
            text: i18n("Zeitzonen hinzufügen…")
            icon.name: "list-add"
            onClicked: timezoneSheet.open()
        }

        QQC2.CheckBox {
            id: enableWheelCheckBox
            enabled: configuredTimezoneList.count > 1
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18n("Angezeigte Zeitzone durch Scrollen über das Uhr-Applet wechseln")
        }

        QQC2.Label {
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.largeSpacing * 2
            Layout.rightMargin: Kirigami.Units.largeSpacing * 2
            text: i18n("Die Nutzung dieser Funktion ändert die systemweite Zeitzone nicht. Wenn Sie reisen, ändern Sie bitte stattdessen die systemweite Zeitzone.")
            font: Kirigami.Theme.smallFont
            wrapMode: Text.Wrap
        }
    }

    Kirigami.OverlaySheet {
        id: timezoneSheet
        parent: timeZonesPage.QQC2.Overlay.overlay

        onVisibleChanged: {
            filter.text = "";
            messageWidget.visible = false;
            if (visible) {
                filter.forceActiveFocus()
            }
        }

        header: ColumnLayout {
            Kirigami.Heading {
                Layout.fillWidth: true
                text: i18n("Weitere Zeitzonen hinzufügen")
                wrapMode: Text.Wrap
            }
            Kirigami.SearchField {
                id: filter
                Layout.fillWidth: true
            }
            Kirigami.InlineMessage {
                id: messageWidget
                Layout.fillWidth: true
                type: Kirigami.MessageType.Warning
                text: i18n("Bitte aktivieren Sie mindestens eine Zeitzone. Ihre lokale Zeitzone wurde automatisch aktiviert.")
                showCloseButton: true
            }
        }

        footer: QQC2.DialogButtonBox {
            standardButtons: QQC2.DialogButtonBox.Ok
            onAccepted: timezoneSheet.close()
        }

        ListView {
            focus: true
            activeFocusOnTab: true
            clip: true
            implicitWidth: Math.max(timeZonesPage.width/2, Kirigami.Units.iconSizes.small * 25)

            model: TimeZoneFilterProxy {
                sourceModel: timeZones
                filterString: filter.text
            }

            delegate: QQC2.CheckDelegate {
                required property int index
                required property var model
                required checked
                required property string city
                required property string comment
                required property string region

                width: ListView.view.width
                focus: true
                text: {
                    if (!city || city.indexOf("UTC") === 0) {
                        return comment;
                    } else if (comment) {
                        return i18n("%1, %2 (%3)", city, region, comment);
                    } else {
                        return i18n("%1, %2", city, region)
                    }
                }

                onToggled: {
                    model.checked = checked
                    ListView.view.currentIndex = index
                    ListView.view.forceActiveFocus()
                }
                highlighted: ListView.isCurrentItem
            }
        }
    }
}
