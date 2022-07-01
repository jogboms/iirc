import 'package:flutter/material.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/registry.dart';

// TODO(Jogboms): Improve UI.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

@visibleForTesting
class HomePageState extends State<HomePage> {
  static const Key loadingViewKey = Key('loadingViewKey');
  static const Key errorViewKey = Key('errorViewKey');

  late final Stream<List<ItemModel>> stream = context.registry.get<FetchItemsUseCase>().call();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appName),
      ),
      body: StreamBuilder<List<ItemModel>>(
        stream: stream,
        builder: (BuildContext context, AsyncSnapshot<List<ItemModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              key: loadingViewKey,
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
            return Center(
              key: errorViewKey,
              child: Text(snapshot.error.toString()),
            );
          }

          final List<ItemModel> items = snapshot.requireData;

          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              final ItemModel item = items[index];

              return ListTile(
                key: Key(item.id),
                title: Text(item.title),
                subtitle: Text(item.description),
              );
            },
            itemCount: items.length,
          );
        },
      ),
    );
  }
}
