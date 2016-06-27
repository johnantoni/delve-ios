/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import SpriteKit
import GameplayKit


enum tileType: Int {
  case tileAir = 0
  case tileWall = 1
  case tileWallLit = 2
  case tileGround = 3
  case tileStart = 4
  case tileEnd = 5
  case tileEnemy = 6
  case tileFood = 7
}

protocol tileMapDelegate {
  func createNodeOf(type type:tileType, location:CGPoint)
}

struct tileMap {
  
  var delegate: tileMapDelegate?
  
  //1
  var tileSize = CGSize(width: 32, height: 32)
  //2
  var tileLayer: [[Int]] = Array()
  //3
  var mapSize:CGPoint {
    get {
      return CGPoint(x: sections.x * sectionSize.x, y: sections.y * sectionSize.y)
    }
  }
  
  let sectionSize = CGPoint(x: 10, y: 10)
  var sections = CGPoint(x: 5, y: 3)
  
  mutating func generateLevel(defaultValue: Int) {
    var columnArray:[[Int]] = Array()
    repeat {
      var rowArray:[Int] = Array()
      repeat {
        rowArray.append(defaultValue)
      } while rowArray.count < Int(mapSize.x)
      columnArray.append(rowArray)
    } while columnArray.count < Int(mapSize.y)
    tileLayer = columnArray
  }
  
  //MARK: Setters and getters for the tile map
  
  //1
  mutating func setTile(position position:CGPoint, toValue:Int) {
    tileLayer[Int(position.y)][Int(position.x)] = toValue
  }
  //2
  func getTile(position position:CGPoint) -> Int {
    return tileLayer[Int(position.y)][Int(position.x)]
  }
  //3
  func tilemapSize() -> CGSize {
    return CGSize(width: tileSize.width * mapSize.x, height:
      tileSize.height * mapSize.y)
  }
  
  func isValidTile(position position:CGPoint) -> Bool {
    if ((position.x >= 1) && (position.x < (mapSize.x - 1)))
      && ((position.y >= 1) && (position.y < (mapSize.y - 1))) {
        return true
    } else {
      return false
    }
  }
  
  //MARK: Level creation
  
  mutating func generateMap() {
    
    //top Row
    setTemplateBy(0,
      leftTiles: tileMapSection.sectionTopLeft.sections,
      middleTiles: tileMapSection.sectionTop.sections,
      rightTiles: tileMapSection.sectionTopRight.sections)
    //Middle Row
    var row = 2
    repeat {
      setTemplateBy(row - 1,
        leftTiles: tileMapSection.sectionLeft.sections,
        middleTiles: tileMapSection.sectionMiddle.sections,
        rightTiles: tileMapSection.sectionRight.sections)
      row += 1
    } while row < Int(sections.y)
    //Bottom Row
    setTemplateBy((Int(sections.y) - 1),
      leftTiles: tileMapSection.sectionBottomLeft.sections,
      middleTiles: tileMapSection.sectionBottom.sections,
      rightTiles: tileMapSection.sectionBottomRight.sections)
  }
  
  mutating func setTemplateBy(rowIndex:Int,leftTiles:[[[Int]]],middleTiles:[[[Int]]],rightTiles:[[[Int]]]) {
    var randomSection = GKRandomDistribution()
    
    //Left Tiles
    randomSection = GKRandomDistribution(forDieWithSideCount: leftTiles.count)
    setTilesByTemplate(leftTiles[randomSection.nextInt() - 1], sectionIndex: CGPoint(x: 0, y: rowIndex))
    //Right Tiles
    randomSection = GKRandomDistribution(forDieWithSideCount: rightTiles.count)
    setTilesByTemplate(rightTiles[randomSection.nextInt() - 1], sectionIndex: CGPoint(x: Int(sections.x - 1), y: rowIndex))
    //Middle Tiles
    var i = 2
    randomSection = GKRandomDistribution(forDieWithSideCount: middleTiles.count)
    repeat {
      setTilesByTemplate(middleTiles[randomSection.nextInt() - 1], sectionIndex: CGPoint(x: i - 1, y: rowIndex))
      i += 1
    } while i < Int(sections.x)
  }
  
  mutating func setTilesByTemplate(template:[[Int]],sectionIndex:CGPoint) {
    for (indexr, row) in template.enumerate() {
      for (indexc, cvalue) in row.enumerate() {
        setTile(position: CGPoint(
          x: (Int(sectionIndex.x * sectionSize.x) + indexc),
          y: (Int(sectionIndex.y * sectionSize.y) + indexr)),
          toValue: cvalue)
      }
    }
  }
  
  //MARK: Presenting the layer
  
  func presentLayerViaDelegate() {
    for (indexr, row) in tileLayer.enumerate() {
      for (indexc, cvalue) in row.enumerate() {
        if (delegate != nil) {
          delegate!.createNodeOf(type: tileType(rawValue: cvalue)!,
            location: CGPoint(
              x: tileSize.width * CGFloat(indexc),
              y: tileSize.height * CGFloat(-indexr)))
        }
      }
    }
  }
  
  
}
