import 'package:flutter/widgets.dart';

import 'package:graphql_flutter/src/client.dart';
import 'package:graphql_flutter/src/widgets/graphql_provider.dart';

typedef void RunMutation(Map<String, dynamic> variables);
typedef void OnMutationCompleted(Map<String, dynamic> data);
typedef Widget MutationBuilder(
  RunMutation mutation, {
  @required bool loading,
  Map<String, dynamic> data,
  String error,
});

class Mutation extends StatefulWidget {
  Mutation(
    this.mutation, {
    final Key key,
    @required this.builder,
    this.onCompleted,
  }) : super(key: key);

  final String mutation;
  final MutationBuilder builder;
  final OnMutationCompleted onCompleted;

  @override
  MutationState createState() => MutationState();
}

class MutationState extends State<Mutation> {
  bool loading = false;
  Map<String, dynamic> data = {};
  String error = '';

  void runMutation(Map<String, dynamic> variables) async {
    /// Gets the client from the closest wrapping [GraphqlProvider].
    Client client = GraphqlProvider.of(context).value;
    assert(client != null);

    setState(() {
      loading = true;
      error = '';
      data = {};
    });

    try {
      final Map<String, dynamic> result = await client.query(
        query: widget.mutation,
        variables: variables,
      );

      setState(() {
        loading = false;
        data = result;
      });

      if (widget.onCompleted != null) {
        widget.onCompleted(result);
      }
    } on Error catch (e) {
      setState(() {
        loading = false;
        error = 'GQL ERROR';
      });

      // TODO: Handle error
      print(e);
      print(e.stackTrace);
    }
  }

  Widget build(BuildContext context) {
    return widget.builder(
      runMutation,
      loading: loading,
      error: error,
      data: data,
    );
  }
}
