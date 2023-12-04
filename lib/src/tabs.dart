import 'package:flutter/material.dart';
import 'tabs/tabs.dart';

class Tabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('T2'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Buscar'),
            Tab(text: 'Trending Movies'),
            Tab(text: 'Trending TV'),
            Tab(text: 'Trending People'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          SearchTabContent(),
          TrendingList(itemType: 'movie'),
          TrendingList(itemType: 'tv'),
          TrendingPeopleList(),
        ],
      ),
    );
  }
}
