import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class PreferredOrientationBuilder extends StatefulWidget {
  final List<DeviceOrientation> preferredOrientations;
  final WidgetBuilder builder;

  const PreferredOrientationBuilder({
    super.key,
    required this.preferredOrientations,
    required this.builder,
  });

  @override
  State<PreferredOrientationBuilder> createState() =>
      _PreferredOrientationBuilderState();
}

class _PreferredOrientationBuilderState
    extends State<PreferredOrientationBuilder> {
  @override
  Widget build(BuildContext context) => widget.builder(context);

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(widget.preferredOrientations);
  }
}
