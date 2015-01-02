import QtQuick 2.0
import Sailfish.Silica 1.0

import Qt.labs.folderlistmodel 2.1

Dialog {
    id: directoryPickerDialog

    property string directoryPath: '';
    property string directoryName: '';

    onDirectoryPathChanged: {
        canAccept = fileSystemHelper.isWritable(directoryPath)
    }

    onDirectoryNameChanged: {
        header.acceptText = qsTr('Select %1').arg(directoryName)
    }

    Column {
        anchors.fill: parent

        DialogHeader {
            id: header

            acceptText: qsTr('Select')
        }

        SilicaListView {
            id: directoryView

            width: parent.width
            height: parent.height - header.height - controls.height

            clip: true

            VerticalScrollDecorator  {}

            ViewPlaceholder {
                text: qsTr('No nested directories')
                enabled: folderListModel.count == 0
            }

            model: FolderListModel {
                id: folderListModel

                showFiles: false
                showHidden: true

                onFolderChanged: {
                    var folderStr = Qt.resolvedUrl(folder);

                    if (folderStr.substring(0, 7).toLowerCase() === 'file://')
                        directoryPath = folderStr.substring(7);
                    else
                        directoryPath = folderStr;

                    directoryName = directoryPath.substring(directoryPath.lastIndexOf('/') + 1);
                }
            }


            delegate: ListItem {
                id: delegate

                Label {
                    text: fileName

                    color: highlighted? Theme.highlightColor: Theme.primaryColor
                }

                onClicked: {
                    folderListModel.folder = model.filePath;
                }

                menu: Component {
                    ContextMenu {
                        MenuItem {
                            text: enabled? qsTr('Rename'): qsTr('Renaming is not allowed')

                            enabled: fileSystemHelper.isWritable(model.filePath)

                            onClicked: {
                                renameDirectory();
                            }
                        }

                        MenuItem {
                            text: enabled? qsTr('Delete'): qsTr('Removal is not allowed')

                            enabled: fileSystemHelper.isRemovable(model.filePath)

                            onClicked: {
                                deleteDirectory()
                            }
                        }
                    }
                }

                function deleteDirectory() {
                    remorseAction("Deleting directory", function() {
                        console.log('Removing ' + model.filePath);

                        fileSystemHelper.remove(model.filePath);
                    })
                }

                function renameDirectory() {
                    var dlg = pageStack.push("DirectoryNameDialog.qml", {
                        directoryName: model.fileName
                    });

                    dlg.accepted.connect(function() {
                        console.log('Renaming ' + model.filePath + ' to ' + dlg.directoryName);

                        fileSystemHelper.rename(model.filePath, dlg.directoryName);
                    });
                }
            }
        }

        DockedPanel {
            id: controls

            width: parent.width
            height: buttons.height

            Row {
                id: buttons

                IconButton {
                    icon.source: 'qrc:/images/icon-m-up.png'

                    enabled: directoryPath !== '/'

                    onClicked: {
                        folderListModel.folder = folderListModel.parentFolder;
                    }
                }

                IconButton {
                    icon.source: 'image://theme/icon-m-home'

                    onClicked: {
                        folderListModel.folder = 'file:///home/nemo';
                    }
                }

                IconButton {
                    icon.source: 'qrc:/images/icon-m-sdcard.png'

                    enabled: fileSystemHelper.sdCardExists()

                    onClicked: {
                        folderListModel.folder = 'file://' + fileSystemHelper.sdCardPath();
                    }
                }

                IconButton {
                    icon.source :'image://theme/icon-m-add'

                    onClicked: {
                        var dlg = pageStack.push("DirectoryNameDialog.qml");

                        dlg.accepted.connect(function() {
                            var dirPath = directoryPath + '/' + dlg.directoryName;

                            console.log('Making path ' + dirPath);

                            if (fileSystemHelper.mkpath(dirPath))
                                folderListModel.folder = 'file://' + dirPath;
                        });
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        if (directoryPath === '')
        {
            directoryPath = '/home/nemo';
            directoryName = 'nemo';
        }
        else
        {
            directoryName = directoryPath.substring(directoryPath.lastIndexOf('/') + 1);
        }

        folderListModel.folder = 'file://' + directoryPath;
    }
}
