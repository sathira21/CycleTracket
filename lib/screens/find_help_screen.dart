import 'package:find_help/find_help_host.dart';
import 'package:flutter/material.dart';

/// Location tab entry. [FindHelpHost] keeps search, filters, the map, place
/// details, and the lists on a navigator that can still read Find Help data.
class FindHelpScreen extends StatelessWidget {
  const FindHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FindHelpHost();
  }
}
