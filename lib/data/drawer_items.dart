// Define your drawer items as data objects
import 'package:flutter/material.dart';
import 'package:Galaxy/model/drawer_model.dart';

final drawerItemsFirst = [
  DrawerItemModel(title: 'Home', icon: Icons.home, onTap: () {  }),
  DrawerItemModel(title: 'People', icon: Icons.people_sharp, onTap: () {  }),
  DrawerItemModel(title: 'Documents', icon: Icons.picture_as_pdf_sharp, onTap: () {  }),
  DrawerItemModel(title: 'Accounts', icon: Icons.account_circle_sharp, onTap: () {  }),
  DrawerItemModel(title: 'Vehicles', icon: Icons.time_to_leave_sharp, onTap: () {  }),
  DrawerItemModel(title: 'Assets', icon: Icons.real_estate_agent_outlined, onTap: () {  }),
  DrawerItemModel(title: 'Expenses', icon: Icons.attach_money_sharp, onTap: () {  }),
  DrawerItemModel(title: 'Achievements', icon: Icons.workspace_premium, onTap: () {  }),
  DrawerItemModel(title: 'My Universe', icon: Icons.auto_awesome_sharp, onTap: () {  }),
];


final drawerItemsSecond = [
  DrawerItemModel(title: 'Profile', icon: Icons.manage_accounts_sharp, onTap: () {  }),
  DrawerItemModel(title: 'Settings', icon: Icons.settings_sharp, onTap: () {  }),
];