/*
    Call Recorder for SailfishOS
    Copyright (C) 2016 Dmitriy Purgin <dpurgin@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.2
import Sailfish.Silica 1.0

import kz.dpurgin.callrecorder.BackupHelper 1.0

Page
{
    property string fileName
    property bool compress: false
    property bool overwrite: true

    property alias busy: backupHelper.busy
    property alias errorCode: backupHelper.errorCode
    property alias progress: backupHelper.progress

    states: [
        State
        {
            when: busy

            PropertyChanges
            {
                target: progressBar

                label: qsTr('Running...')
            }
        },

        State
        {
            when: !busy && errorCode === BackupHelper.None && progress > 0

            PropertyChanges
            {
                target: progressBar

                label: qsTr('Complete!')
            }
        },

        State
        {
            when: errorCode !== BackupHelper.None

            PropertyChanges
            {
                target: progressBar

                label: qsTr('Error')
            }

            PropertyChanges
            {
                target: progressBar

                indeterminate: false
                label:
                {
                    switch (errorCode)
                    {
                    case BackupHelper.UnableToWrite: return qsTr('Unable to write archive');
                    case BackupHelper.UnableToStart: return qsTr('Unable to start thread');
                    case BackupHelper.FileExists: return qsTr('Backup file already exists');
                    case BackupHelper.FileNotExists: return qsTr('Backup file doesn\'t exist');
                    }

                    return qsTr('Unknown error');
                }
            }
        }

    ]

    BackupHelper
    {
        id: backupHelper
    }

    Column
    {
        anchors.fill: parent

        PageHeader
        {
            title: qsTr('Backup')
        }

        Label
        {
            text: qsTr('Performing backup. Please do not go back or close the application until the operation is complete')

            x: Theme.horizontalPageMargin
            width: parent.width - x * 2
            height: implicitHeight + Theme.paddingLarge

            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.Wrap
        }

        ProgressBar
        {
            id: progressBar

            width: parent.width

            indeterminate: progress <= 1

            minimumValue: 0
            maximumValue: backupHelper.totalCount
            value: backupHelper.progress
        }
    }

    onStatusChanged:
    {
        if (status === PageStatus.Activating)
            backupHelper.backup(fileName, compress, overwrite);
    }
}
