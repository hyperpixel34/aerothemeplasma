/*
    SPDX-FileCopyrightText: 2014 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core as PlasmaCore
import io.gitgud.wackyideas.desktopcontainment.folder as Folder
import org.kde.kitemmodels 1.0 as KItemModels

ColumnLayout {
    id: configIcons

    property alias cfg_filterMode: filterMode.currentIndex
    property alias cfg_filterPattern: filterPattern.text
    property alias cfg_filterMimeTypes: mimeTypesModel.checkedTypes
    property alias cfg_showHiddenFiles: showHiddenFiles.checked

    KItemModels.KSortFilterProxyModel {
        id: filteredMimeTypesModel

        sourceModel: Folder.MimeTypesModel {
            id: mimeTypesModel
        }

        filterRegularExpression: RegExp(mimeFilter.text, "i")
        filterRoleName: "name"

        sortRoleName: "name"
        sortOrder: Qt.AscendingOrder

        function checkFiltered() {
            var types = [];

            for (var i = 0; i < count; ++i) {
                types.push(get(i).name);
            }

            mimeTypesModel.checkedTypes = types;
        }

        function uncheckFiltered() {
            var types = [];

            for (var i = 0; i < count; ++i) {
                types.push(get(i).name);
            }

            mimeTypesModel.checkedTypes = mimeTypesModel.checkedTypes
                .filter(x => types.indexOf(x) === -1);
        }
    }
    Kirigami.FormLayout {
        ComboBox {
            id: filterMode
            Kirigami.FormData.label: i18n("Dateien:")
            model: [i18n("Alle anzeigen"), i18n("Passende anzeigen"), i18n("Passende ausblenden")]
        }

        TextField {
            id: filterPattern
            Kirigami.FormData.label: i18n("Dateinamenmuster:")
            enabled: (filterMode.currentIndex > 0)
            inputMethodHints: Qt.ImhNoPredictiveText
        }

        Kirigami.SearchField {
            id: mimeFilter
            Kirigami.FormData.label: i18n("Dateitypen:")
            enabled: (filterMode.currentIndex > 0)
        }

        CheckBox {
            id: showHiddenFiles
            Kirigami.FormData.label: i18n("Versteckte Dateien anzeigen:")
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true

        CheckBox { // Purely for metrics.
            id: metricsCheckBox
            visible: false
        }

        ScrollView {
            id: scrollView
            enabled: (filterMode.currentIndex > 0)
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 100 // Note: this arbitrary number is a workaround to the layout trying to resize the scrollview to an huge value, the behavior is still correctly stretching

            Component.onCompleted: {
                if (background) {
                    background.visible = true;
                }
            }

            contentItem: ListView {
                id: mimeTypesView
                clip: true

                // Signal the delegates listen to when user presses space to toggle current row.
                signal toggleCurrent()


                model: filteredMimeTypesModel
                property real columnSize: Kirigami.Units.iconSizes.small * 15
                headerPositioning: ListView.OverlayHeader

                Keys.onSpacePressed: toggleCurrent()

                header: HorizontalHeaderView {
                    id: headerView
                    z: 9
                    implicitWidth: mimeTypesView.width
                    rowHeightProvider: function () {
                        return Kirigami.Units.iconSizes.small * 2
                    }
                    clip: true // This removes event handling blocking by the header
                    model: ListModel {
                        Component.onCompleted: {
                            append({ display: i18n("Dateityp") });
                            append({ display: i18n("Beschreibung") });
                        }
                    }
                    interactive: false
                    columnWidthProvider: function(column) {
                        if (column === 0) {
                            return mimeTypesView.columnSize;
                        } else {
                            return mimeTypesView.width - mimeTypesView.columnSize;
                        }
                    }
                }

                delegate: ItemDelegate {
                    id: delegate
                    width: mimeTypesView.width
                    required property string name
                    required property string comment
                    required property var decoration

                    contentItem: RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Kirigami.Units.iconSizes.small
                        RowLayout {
                            Layout.preferredWidth: mimeTypesView.columnSize
                            Layout.maximumWidth: mimeTypesView.columnSize
                            Layout.fillHeight: true
                            CheckBox {
                                Layout.fillHeight: true
                                checked: mimeTypesModel.checkedTypes.indexOf(name) >= 0
                                onToggled: {
                                    let idx = mimeTypesModel.checkedTypes.indexOf(name);
                                    if (idx >= 0) {
                                        mimeTypesModel.checkedTypes.splice(idx, 1);
                                    } else {
                                        mimeTypesModel.checkedTypes.push(name)
                                    }
                                }
                            }
                            Kirigami.Icon {
                                Layout.fillHeight: true
                                implicitWidth: Kirigami.Units.iconSizes.small
                                implicitHeight: Kirigami.Units.iconSizes.small
                                animated: false // TableView re-uses delegates, avoid animation when sorting/filtering.
                                source: decoration
                            }
                            Label {
                                text: name
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }
                        }
                        Label {
                            text: comment
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                }
            }
        }

        RowLayout {
            id: selectLayout
            Button {
                id: selectAllButton
                enabled: (filterMode.currentIndex > 0)
                icon.name: "edit-select-all"
                ToolTip.delay: Kirigami.Units.toolTipDelay
                ToolTip.visible: (Kirigami.Settings.isMobile ? pressed : hovered) && ToolTip.text.length > 0
                ToolTip.text: i18n("Alle auswählen")
                onClicked: filteredMimeTypesModel.checkFiltered()
            }

            Button {
                id: deselectAllButton
                enabled: (filterMode.currentIndex > 0)
                icon.name: "edit-select-none"
                ToolTip.delay: Kirigami.Units.toolTipDelay
                ToolTip.visible: (Kirigami.Settings.isMobile ? pressed : hovered) && ToolTip.text.length > 0
                ToolTip.text: i18n("Alle abwählen")
                onClicked: filteredMimeTypesModel.uncheckFiltered()
            }

            Button {
                enabled: (filterMode.currentIndex > 0)
                icon.name: filteredMimeTypesModel.sortOrder === Qt.AscendingOrder ? "view-sort-ascending-symbolic" : "view-sort-descending-symbolic"
                ToolTip.delay: Kirigami.Units.toolTipDelay
                ToolTip.visible: (Kirigami.Settings.isMobile ? pressed : hovered) && ToolTip.text.length > 0
                ToolTip.text: i18n("Sortierreihenfolge ändern")
                onClicked: {
                    filteredMimeTypesModel.sortOrder = filteredMimeTypesModel.sortOrder === Qt.AscendingOrder ? Qt.DescendingOrder : Qt.AscendingOrder;
                    filteredMimeTypesModel.sort(0, filteredMimeTypesModel.sortOrder);
                }
            }
        }
    }
}
