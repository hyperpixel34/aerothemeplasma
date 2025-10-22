/*
    SPDX-FileCopyrightText: 2014 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2015 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.iconthemes as KIconThemes
import org.kde.config // for KAuthorized
import org.kde.kirigami 2.20 as Kirigami

import io.gitgud.wackyideas.desktopcontainment.folder as Folder

Item {
    id: configIcons

    property bool isPopup: (Plasmoid.location !== PlasmaCore.Types.Floating)

    property string cfg_icon: Plasmoid.configuration.icon
    property alias cfg_useCustomIcon: useCustomIcon.checked
    property alias cfg_arrangement: arrangement.currentIndex
    property alias cfg_alignment: alignment.currentIndex
    property bool cfg_locked
    property alias cfg_sortMode: sortMode.mode
    property alias cfg_sortDesc: sortDesc.checked
    property alias cfg_sortDirsFirst: sortDirsFirst.checked
    property alias cfg_toolTips: toolTips.checked
    property alias cfg_selectionMarkers: selectionMarkers.checked
    property alias cfg_renameInline: renameInline.checked
    property alias cfg_popups: popups.checked
    property alias cfg_previews: previews.checked
    property var cfg_previewPlugins
    property alias cfg_viewMode: viewMode.currentIndex
    property alias cfg_iconSize: iconSize.value
    property alias cfg_labelWidth: labelWidth.currentIndex
    property alias cfg_textLines: textLines.value

    property alias cfg_textShadows: textShadows.checked
    property alias cfg_iconShadows: iconShadows.checked

    property alias cfg_selectionStyle: selectionStyle.currentIndex


    readonly property bool lockedByKiosk: !KAuthorized.authorize("editable_desktop_icons")

    implicitHeight: layout.height

    KIconThemes.IconDialog {
        id: iconDialog
        onIconNameChanged: cfg_icon = iconName || "folder-symbolic";
    }

    Kirigami.FormLayout {
        id: layout

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        // Panel button
        RowLayout {
            spacing: Kirigami.Units.smallSpacing
            visible: isPopup

            Kirigami.FormData.label: i18n("Panel-Button:")

            CheckBox {
                id: useCustomIcon
                visible: isPopup
                checked: cfg_useCustomIcon
                text: i18n("Benutzerdefiniertes Icon verwenden")
            }

            Button {
                id: iconButton
                Layout.minimumWidth: Kirigami.Units.iconSizes.large + Kirigami.Units.smallSpacing * 2
                Layout.maximumWidth: Layout.minimumWidth
                Layout.minimumHeight: Layout.minimumWidth
                Layout.maximumHeight: Layout.minimumWidth

                checkable: true
                enabled: useCustomIcon.checked

                onClicked: {
                    checked = Qt.binding(() =>
                        iconMenu.status === PlasmaExtras.Menu.Open);

                    iconMenu.open(0, height);
                }

                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.large
                    height: width
                    source: cfg_icon
                }
            }

            PlasmaExtras.Menu {
                id: iconMenu
                visualParent: iconButton

                PlasmaExtras.MenuItem {
                    text: i18nc("@item:inmenu Symbolauswahldialog öffnen", "Auswählen…")
                    icon: "document-open-folder"
                    onClicked: iconDialog.open()
                }

                PlasmaExtras.MenuItem {
                    text: i18nc("@item:inmenu Icon zum Standard zurücksetzen", "Icon löschen")
                    icon: "edit-clear"
                    onClicked: cfg_icon = "folder-symbolic";
                }
            }
        }

        Item {
            visible: isPopup
            Kirigami.FormData.isSection: true
        }



        // Arrangement section
        ComboBox {
            id: arrangement
            Layout.fillWidth: true
            visible: !isPopup || viewMode.currentIndex === 1 /* Icons mode */

            Kirigami.FormData.label: i18n("Anordnung:")

            model: [
                Qt.application.layoutDirection === Qt.LeftToRight ?
                    i18nc("@item:inlistbox Anordnung der Icons", "Links nach Rechts") :
                    i18nc("@item:inlistbox Anordnung der Icons", "Rechts nach links"),
                i18nc("@item:inlistbox Anordnung der Icons", "Oben nach Unten"),
            ]
        }

        ComboBox {
            id: alignment
            Layout.fillWidth: true
            visible: !isPopup || viewMode.currentIndex === 1 /* Icons mode */

            model: [i18nc("@item:inlistbox Anordnung der Icons", "Links anordnen"),
                    i18nc("@item:inlistbox Anordnung der Icons", "Rechts anordnen")]
        }

        CheckBox {
            id: locked
            visible: ("containmentType" in plasmoid)
            checked: cfg_locked || lockedByKiosk
            enabled: !lockedByKiosk

            onCheckedChanged: {
                if (!lockedByKiosk) {
                    cfg_locked = checked;
                }
            }

            text: i18n("Festsetzen")
        }

        Item {
            Kirigami.FormData.isSection: true
            visible: !isPopup || viewMode.currentIndex === 1 /* Icons mode */
        }


        // Sorting section
        ComboBox {
            id: sortMode
            Layout.fillWidth: true

            Kirigami.FormData.label: i18n("Sortierung:")

            property int mode
            // FIXME TODO HACK: This maps the combo box list model to the KDirModel::ModelColumns
            // enum, which should be done in C++.
            property var indexToMode: [-1, 0, 1, 6, 2]
            property var modeToIndex: {'-1': '0', '0': '1', '1': '2', '6': '3', '2': '4'}

            model: [i18nc("@item:inlistbox Sortiert Icons manuell", "Manuell"),
                    i18nc("@item:inlistbox Sortiert Icons nach Name", "Name"),
                    i18nc("@item:inlistbox Sortiert Icons nach Größe", "Größe"),
                    i18nc("@item:inlistbox Sortiert Icons nach Dateityp", "Typ"),
                    i18nc("@item:inlistbox Sortiert Icons nach Datum", "Datum")]

            Component.onCompleted: currentIndex = modeToIndex[mode]
            onActivated: mode = indexToMode[index]
        }

        CheckBox {
            id: sortDesc

            enabled: sortMode.currentIndex !== 0

            text: i18nc("@option:check Sortiert Icons absteigend", "Absteigend")
        }

        CheckBox {
            id: sortDirsFirst

            enabled: sortMode.currentIndex !== 0

            text: i18nc("@option:check Sortiert Icons mit Ordnern zuerst", "Ordner zuerst")
        }

        Item {
            Kirigami.FormData.isSection: true
        }


        // View Mode section (only if we're a pop-up)
        ComboBox {
            id: viewMode
            visible: isPopup
            Layout.fillWidth: true

            Kirigami.FormData.label: i18nc("Ansicht ändern", "Ansicht:")

            model: [i18nc("@item:inlistbox Zeigt Icons in einer Liste", "Liste"),
                    i18nc("@item:inlistbox Zeigt Icons in einem Raster", "Raster")]
        }


        // Size section
        Slider {
            id: iconSize

            Layout.fillWidth: true
            visible: !isPopup || viewMode.currentIndex === 1 /* Icons mode */

            Kirigami.FormData.label: i18n("Icongröße:")

            from: 0
            to: 6
            stepSize: 1
            snapMode: Slider.SnapAlways
        }

        RowLayout {
            Layout.fillWidth: true

            Label {
                Layout.alignment: Qt.AlignLeft
                visible: !isPopup || viewMode.currentIndex === 1 /* Icons mode */

                text: i18nc("@label:slider Kleinste Icongröße", "Klein")
            }
            Item {
                Layout.fillWidth: true
            }
            Label {
                Layout.alignment: Qt.AlignRight
                visible: !isPopup || viewMode.currentIndex === 1 /* Icons mode */

                text: i18nc("@label:slider Größte Icongröße", "Groß")
            }
        }

        ComboBox {
            id: labelWidth
            visible: !isPopup || viewMode.currentIndex === 1 /* Icons mode */
            Layout.fillWidth: true

            Kirigami.FormData.label: i18n("Beschriftungsbreite:")

            model: [
                i18nc("@item:inlistbox how long a text label should be", "Klein"),
                i18nc("@item:inlistbox how long a text label should be", "Mittel"),
                i18nc("@item:inlistbox how long a text label should be", "Breit"),
            ]
        }

        SpinBox {
            id: textLines
            visible: !isPopup || viewMode.currentIndex === 1 /* Icons mode */

            Kirigami.FormData.label: i18n("Textzeilen:")

            from: 1
            to: 10
            stepSize: 1
        }

        Item {
            Kirigami.FormData.isSection: true
        }


        // Features section
        CheckBox {
            id: toolTips

            Kirigami.FormData.label: i18n("Beim hovern über Icons:")

            text: i18n("Tooltips anzeigen")
        }

        CheckBox {
            id: selectionMarkers
            visible: Qt.styleHints.singleClickActivation

            text: i18n("Auswahlmarkierungen anzeigen")
        }

        CheckBox {
            id: popups
            visible: !isPopup

            text: i18n("Ordnervorschau-Popups anzeigen")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        CheckBox {
            id: renameInline

            Kirigami.FormData.label: i18n("Umbenennen:")

            visible: !selectionMarkers.visible

            text: i18n("Inline umbenennen, indem Sie auf den Text des ausgewählten Elements klicken")
        }

        Item {
            Kirigami.FormData.isSection: true
            visible: renameInline.visible
        }

        CheckBox {
            id: textShadows
            text: i18n("Verwenden Sie Schlagschatten für Symbolbeschriftungen auf dem Desktop")
        }
        CheckBox {
            id: iconShadows
            text: i18n("Verwenden Sie Schlagschatten für Symbole auf dem Desktop")
        }

        ComboBox {
            id: selectionStyle
            visible: !isPopup
            Layout.fillWidth: true

            Kirigami.FormData.label: i18n("Auswahlstil:")

            model: [
                i18nc("@item:inlistbox how the selection should be", "Plasma-Stil"),
                i18nc("@item:inlistbox how the selection should be", "Klassisch"),
            ]
        }

        CheckBox {
            id: previews

            Kirigami.FormData.label: i18n("Vorschau:")

            text: i18n("Vorschau anzeigen")
        }

        Button {
            id: previewSettings
            Layout.fillWidth: true

            icon.name: "configure"
            text: i18n("Preview Plugins konfigurieren…")

            onClicked: {
                const component = Qt.createComponent(Qt.resolvedUrl("FolderItemPreviewPluginsDialog.qml"));
                component.incubateObject(configIcons.Window.window.contentItem, {
                    "previewPlugins": configIcons.cfg_previewPlugins,
                }, Qt.Asynchronous);
                component.destroy();
            }
        }
    }
}
