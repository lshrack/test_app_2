import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flame/gestures.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'database_helper.dart';

class Forest extends BaseGame with TapDetector {
  final double squareSize = 20;
  List<Tree> trees;

  Forest() {
    // add(Square()
    //   ..x = 100
    //   ..y = 100);
    Tree newTree = Tree(1, 30, 30);
    add(Background(this));
    trees.add(newTree);
    add(newTree);
    TreeEntry newTreeEntry;
    newTreeEntry.treeType = newTree.type;
    newTreeEntry.xLoc = newTree.xLoc;
    newTreeEntry.yLoc = newTree.yLoc;

    print("Ok, I added the tree. Now I'm gonna do fancy database stuff.");
    DatabaseMethods.save(newTreeEntry, TreeDatabaseHelper.instance);
  }

  @override
  void onTapUp(details) {
    print("running on tapup");
    print("X pos of tap is ${details.localPosition.dx}");
    print('Y pos of tap is ${details.localPosition.dy}');
    final touchArea = Rect.fromLTRB(
        details.localPosition.dx - 40,
        details.localPosition.dy - 40,
        details.localPosition.dx,
        details.localPosition.dy);
    // final touchArea = Rect.fromCenter(
    //   center: details.localPosition,
    //   width: 20,
    //   height: 20,
    // );

    bool handled = false;
    components.forEach((c) {
      print("examining a component");
      if (c is Tree) {
        print("hey it's the tree");
      } else
        print("hey it's not the tree");
      if (c is PositionComponent && c.toRect().overlaps(touchArea)) {
        print(handled);
        print("hey you tapped it");
        if (handled == false) {
          handled = true;

          if ((c as Tree).getType() == 4)
            markToRemove(c);
          else
            (c as Tree).setType((c as Tree).getType() + 1);
        }
      }
    });

    if (!handled) {
      addLater(Tree(1, touchArea.left, touchArea.top)
        ..x = touchArea.center.dx
        ..y = touchArea.center.dy);
    }
  }
}

class Palette {
  static const PaletteEntry white = BasicPalette.white;
  static const PaletteEntry red = PaletteEntry(Color(0xFFFF0000));
  static const PaletteEntry blue = PaletteEntry(Color(0xFF0000FF));
}

class Tree extends PositionComponent with HasGameRef<Forest> {
  int type;
  double treeWidth;
  double treeHeight;
  double xLoc;
  double yLoc;
  Sprite image;
  int index;

  Tree(this.type, this.xLoc, this.yLoc) {
    setType(type);
    x = xLoc;
    y = yLoc;
  }

  @override
  void render(Canvas c) {
    width = height = gameRef.squareSize;
    prepareCanvas(c);
    image.render(c, width: treeWidth, height: treeHeight);
  }

  int getType() {
    return type;
  }

  void setType(int newType) {
    type = newType;
    if (type == 1) {
      image = Sprite("baby2.png");
      treeWidth = treeHeight = 25.0;
    }
    if (type == 2) {
      image = Sprite("small2.png");
      treeWidth = treeHeight = 40.0;
    }
    if (type == 3) {
      image = Sprite("medium2.png");
      treeWidth = treeHeight = 50.0;
    }
    if (type == 4) {
      image = Sprite("big2.png");
      treeWidth = treeHeight = 60.0;
    }
  }
}

class Background extends PositionComponent with HasGameRef<Forest> {
  final Forest game;
  Rect bgRect;
  Paint green = Paint()..color = const Color(0xff9cfc97);

  Background(this.game) {
    bgRect = Rect.fromLTWH(0, 0, 1000, 1000);
  }

  void render(Canvas c) {
    c.drawRect(bgRect, green);
  }

  void update(double t) {}
}
