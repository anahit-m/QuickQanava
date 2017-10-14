/*
 Copyright (c) 2008-2017, Benoit AUTHEMAN All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the author or Destrat.io nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AUTHOR BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

//-----------------------------------------------------------------------------
// This file is a part of the QuickQanava software library. Copyright 2014 Benoit AUTHEMAN.
//
// \file	CurvedEdge.qml
// \author	benoit@destrat.io
// \date	2018 09 04
//-----------------------------------------------------------------------------

import QtQuick          2.7
import QtQuick.Layouts  1.3
import QtQuick.Shapes   1.0

import QuickQanava      2.0 as Qan

Qan.EdgeItem {
    id: edgeItem

    property color color: style ? style.lineColor : Qt.rgba(0.,0.,0.,1.)

    Shape {
        id: edgeCap
        transformOrigin: Item.TopLeft
        rotation: edgeItem.dstAngle
        x: edgeItem.p2.x
        y: edgeItem.p2.y
        visible: edgeItem.visible && !edgeItem.hidden
        ShapePath {
            id: cap
            strokeColor: edgeItem.color
            fillColor: edgeItem.color
            strokeWidth: 2
            startX: edgeItem.dstA1.x;   startY: edgeItem.dstA1.y
            PathLine { x: edgeItem.dstA3.x; y: edgeItem.dstA3.y }
            PathLine { x: edgeItem.dstA2.x; y: edgeItem.dstA2.y }
            PathLine { x: edgeItem.dstA1.x; y: edgeItem.dstA1.y }
        }
    } // edgeCap
    Component {
        id: straightShapePath
        ShapePath {
            id: edgeShapePath
            startX: edgeItem.p1.x
            startY: edgeItem.p1.y
            capStyle: ShapePath.FlatCap
            strokeWidth: edgeItem.style ? edgeItem.style.lineWidth : 2
            strokeColor: edgeItem.color
            strokeStyle: style && style.dashed ? ShapePath.DashLine : ShapePath.SolidLine
            dashPattern: style ? style.dashPattern : [4, 2]
            fillColor: Qt.rgba(0,0,0,0)
            PathLine {
                x: edgeItem.p2.x
                y: edgeItem.p2.y
            }
        }
    }
    Component {
        id: curvedShapePath
        ShapePath {
            id: edgeShapePath
            startX: edgeItem.p1.x
            startY: edgeItem.p1.y
            capStyle: ShapePath.FlatCap
            strokeWidth: edgeItem.style ? edgeItem.style.lineWidth : 2
            strokeColor: edgeItem.color
            strokeStyle: style && style.dashed ? ShapePath.DashLine : ShapePath.SolidLine
            dashPattern: style ? style.dashPattern : [4, 2]
            fillColor: Qt.rgba(0,0,0,0)
            PathCubic {
                x: edgeItem.p2.x
                y: edgeItem.p2.y
                control1X: edgeItem.c1.x
                control1Y: edgeItem.c1.y
                control2X: edgeItem.c2.x
                control2Y: edgeItem.c2.y
            }
        }
    }

    Shape {
        id: edgeShape
        anchors.fill: parent
        visible: edgeItem.visible && !edgeItem.hidden
        //asynchronous: true    // FIXME: Benchmark that
        smooth: true
        property var lineType : style.lineType
        property var curvedLine : undefined
        property var straightLine : undefined
        onLineTypeChanged: {
            if ( lineType === Qan.EdgeStyle.Straight ) {
                if ( curvedLine )
                    curvedLine.destroy()
                straightLine = straightShapePath.createObject(edgeShape)
                edgeShape.data = straightLine
            } else if ( lineType === Qan.EdgeStyle.Curved ) {
                if ( straightLine )
                    straightLine.destroy()
                curvedLine = curvedShapePath.createObject(edgeShape)
                edgeShape.data = curvedLine
            }
        }
        /*
        // Debug control points display code. FIXME: remove that for final release
        Rectangle {
            width: 8; height: width
            x: edgeItem.c1.x - ( radius / 2 )
            y: edgeItem.c1.y - ( radius / 2 )
            radius: width / 2
            color: "red"
        }
        Rectangle {
            width: 8; height: width
            x: edgeItem.c2.x - ( radius / 2 )
            y: edgeItem.c2.y - ( radius / 2 )
            radius: width / 2
            color: "green"
        }
        */
    }
}
