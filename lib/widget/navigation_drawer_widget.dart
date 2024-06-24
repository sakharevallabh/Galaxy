import 'package:flutter/material.dart';
import 'package:galaxy/data/drawer_items.dart';
import 'package:galaxy/model/drawer_model.dart';
import 'package:galaxy/pages/accounts_page.dart';
import 'package:galaxy/pages/achivements_page.dart';
import 'package:galaxy/pages/assets_page.dart';
import 'package:galaxy/pages/documents_page.dart';
import 'package:galaxy/pages/expenses_page.dart';
import 'package:galaxy/pages/home_page.dart';
import 'package:galaxy/pages/my_universe_page.dart';
import 'package:galaxy/pages/people_page.dart';
import 'package:galaxy/pages/profile_settings_page.dart';
import 'package:galaxy/pages/settings_page.dart';
import 'package:galaxy/pages/vehicles_page.dart';
import 'package:galaxy/provider/navigation_provider.dart';
import 'package:provider/provider.dart';

class NavigationDrawerWidget extends StatefulWidget {
  const NavigationDrawerWidget({super.key});

  @override
  NavigationDrawerWidgetState createState() => NavigationDrawerWidgetState();
}

class NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  final padding = const EdgeInsets.symmetric(horizontal: 20);

  @override
  Widget build(BuildContext context) {
    final safeArea =
        EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top);
    final provider = Provider.of<NavigationProvider>(context);
    final isCollapsed = provider.isCollapsed;

    return Drawer(
      width: isCollapsed ? MediaQuery.of(context).size.width * 0.2 : null,
      child: Container(
        color: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24)
                  .add(safeArea),
              width: double.infinity,
              color: Colors.white10,
              child: buildHeader(isCollapsed),
            ),
            buildList(items: drawerItemsFirst, isCollapsed: isCollapsed),
            const Divider(color: Colors.white, thickness: 0.3),
            buildList(
                indexOffset: drawerItemsFirst.length,
                items: drawerItemsSecond,
                isCollapsed: isCollapsed),
            buildCollapsibleIcon(context, isCollapsed),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(bool isCollapsed) => isCollapsed
      ? Image.asset('assets/images/GalaxyLogo.png')
      : Row(
          children: [
            const SizedBox(width: 24),
            Image.asset(
              'assets/images/GalaxyLogo.png',
              width: 48,
              height: 48,
            ),
            const SizedBox(width: 16),
            const Text(
              'Galaxy',
              style: TextStyle(fontSize: 32, color: Colors.white),
            ),
          ],
        );

  Widget buildCollapsibleIcon(BuildContext context, bool isCollapsed) {
    const double size = 52;
    final icon = isCollapsed ? Icons.arrow_forward_ios : Icons.arrow_back_ios;
    final alignment = isCollapsed ? Alignment.center : Alignment.centerRight;
    final margin = isCollapsed ? null : const EdgeInsets.only(right: 16);
    final width = isCollapsed ? double.infinity : size;

    return Container(
      alignment: alignment,
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          child: SizedBox(
            width: width,
            height: size,
            child: Icon(icon, color: Colors.white),
          ),
          onTap: () {
            final provider =
                Provider.of<NavigationProvider>(context, listen: false);
            provider.toggleIsCollapsed();
          },
        ),
      ),
    );
  }

  buildList({
    required bool isCollapsed,
    required List<DrawerItemModel> items,
    int indexOffset = 0,
  }) => 
      ListView.separated(
        padding: isCollapsed ? EdgeInsets.zero : padding,
        shrinkWrap: true,
        primary: false,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 5),
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];
          return buildMenuItem(
            isCollapsed: isCollapsed,
            text: item.title,
            icon: item.icon,
            onClicked: () => selectItem(context, indexOffset + index),
          );
        },
      );

  buildMenuItem({
    required bool isCollapsed,
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    const color = Colors.white;
    final leading = Icon(icon, color: color);

    return Material(
      color: Colors.transparent,
      child: isCollapsed
          ? ListTile(
              title: leading,
              onTap: onClicked,
            )
          : ListTile(
              leading: leading,
              title: Text(text,
                  style: const TextStyle(color: color, fontSize: 16)),
              onTap: onClicked,
            ),
    );
  }

  selectItem(BuildContext context, int index) {
    navigateTo(page) => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => page,
        ));
    switch (index) {
      case 0:
        navigateTo(const MyHomePage(title: 'Galaxy View'));
        break;
      case 1:
        navigateTo(const PeoplePage());
        break;
      case 2:
        navigateTo(const DocumentsPage());
        break;
      case 3:
        navigateTo(const AccountsPage());
        break;
      case 4:
        navigateTo(const VehiclesPage());
        break;
      case 5:
        navigateTo(const AssetsPage());
        break;
      case 6:
        navigateTo(const ExpensesPage());
        break;
      case 7:
        navigateTo(const AchivementsPage());
        break;
      case 8:
        navigateTo(const MyUniversePage());
        break;
      case 9:
        navigateTo(const ProfileSettingsPage());
        break;
      case 10:
        navigateTo(const SettingsPage());
        break;
      case 11:
        navigateTo(const DocumentsPage());
        break;
    }
  }
}
