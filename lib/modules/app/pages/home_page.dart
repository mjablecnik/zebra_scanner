import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:zebra_scanner/components/layout.dart';
import 'package:zebra_scanner/core/constants.dart';
import 'package:zebra_scanner/core/singletons/logger.dart';
import 'package:zebra_scanner/modules/app/user_store.dart';
import 'package:zebra_scanner/modules/app/models/action_model.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';

class HomePage extends StatelessWidget {
  final UserStore userStore = Modular.get<UserStore>();
  late final List<ActionModel> actions;

  HomePage() {
    actions = [
      ActionModel(
        label: translate.app.actions.barcodeRegistration,
        color: Colors.blue,
        function: () => Modular.to.navigate(Routes.barcode),
      ),
      ActionModel(
        label: translate.app.actions.logout,
        color: Colors.orange,
        function: userStore.logout,
      ),
      ActionModel(
        label: translate.app.actions.example,
        color: Colors.green,
        function: () => Modular.to.pushNamed(Routes.example),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      enableQuitAction: true,
      child: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(8.0),
        children: [
          for (ActionModel action in actions)
            GestureDetector(
              onTap: () {
                logger.info(LogAction.select(action.label));
                action.function.call();
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    color: action.color,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.9),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(1, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      action.label,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
