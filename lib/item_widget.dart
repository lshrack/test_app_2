import 'package:flutter/material.dart';

abstract class ItemWidget {
  int id;
  Widget buildTitle(BuildContext context);
  Widget buildSubtitle(BuildContext context);
  Widget buildLeading(BuildContext context);
  int getForeignKey();
  //Widget buildTrailing(BuildContext context);
}
