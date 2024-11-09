import 'package:brick_core/core.dart';
import 'package:brick_core/src/provider.dart';

/// A model can be queried by the `Repository`, and if merited by the `Repository` implementation,
/// the [Provider]. Subclasses may extend [Model] to include Repository-specific needs,
/// such as an HTTP endpoint or a table name.
abstract class Model {
  const Model();
}
