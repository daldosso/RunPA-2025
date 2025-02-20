import 'package:flutter/material.dart';
import 'package:runpa/menu.dart';
import 'package:runpa/pages/athletes.dart';
import 'package:runpa/routes.dart';

class HomePage extends StatelessWidget {
  final Body body = Body();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Podistica Arona'), actions: <Widget>[
        IconButton(
          icon: Icon(Icons.login),
          onPressed: () {},
        ),
      ]),
      body: body.build(context),
      drawer: Drawer(child: Menu().build(context)),
    );
  }
}

class Body {
  Container build(BuildContext context) {
    final MyGridView myGridView = MyGridView();
    return Container(
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Container(
                margin: const EdgeInsets.all(20.0),
                child: Image(image: AssetImage('data/img/logo_top.png'))),
            myGridView.build(context)
          ],
        ));
  }
}

class MyGridView {
  GestureDetector getStructuredGridCell(name, icon, onTap) {
    // Wrap the child under GestureDetector to setup a on click action
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1.5,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              Icon(
                icon,
                color: Colors.lightBlue,
                size: 100.0,
                semanticLabel: 'Text to announce in accessibility modes',
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 25.0,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Container build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: GridView.count(
        shrinkWrap: true,
        primary: true,
        padding: const EdgeInsets.all(1.0),
        crossAxisCount: 2,
        childAspectRatio: 1,
        mainAxisSpacing: 1.0,
        crossAxisSpacing: 1.0,
        children: <Widget>[
          getStructuredGridCell("Atleti", Icons.person, () {
            Navigator.pushNamed(context, AppRoutes.athletes);
          }),
          getStructuredGridCell("Eventi", Icons.alarm, () {}),
          getStructuredGridCell("Challenge run", Icons.directions_run, () {}),
          getStructuredGridCell("Foto", Icons.photo_camera, () {}),
        ],
      ),
    );
  }
}
