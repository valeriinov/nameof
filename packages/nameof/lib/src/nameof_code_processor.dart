import 'package:nameof/src/util/string_extensions.dart';
import 'package:nameof_annotation/nameof_annotation.dart';

import 'model/element_info.dart';
import 'model/options.dart';
import 'model/property_info.dart';
import 'nameof_visitor.dart';

/// Code lines builder
class NameofCodeProcessor {
  /// Build options
  final NameofOptions options;

  /// Code info
  final NameofVisitor visitor;

  NameofCodeProcessor(this.options, this.visitor);

  String process() {
    return _generateNames(visitor);
  }

  String _generateNames(NameofVisitor visitor) {
    StringBuffer buffer = StringBuffer();

    final classContainerName = 'Nameof${visitor.className}';

    buffer.writeln(
        '/// Container for names of elements belonging to the [${visitor
            .className}] class');
    buffer.writeln('class $classContainerName {');

    buffer.writeln('$classContainerName._();');
    buffer.writeln();

    final className =
        'final String className = \'${visitor.className}\';';

    final constructorNames =
    _getCodeParts('constructor', visitor.constructors.values);

    final fieldNames = _getCodeParts('field', visitor.fields.values);

    final functionNames = _getCodeParts('function', visitor.functions.values);

    final propertyNames = _getFilteredNames(visitor.properties.values).map((
        prop) =>
    'final String property${(prop as PropertyInfo).propertyPrefix}${prop
        .originalName.capitalize().privatize()} = \'${prop.name}\';');

    void writeCode(Iterable<String> codeLines) {
      if (codeLines.isNotEmpty) {
        buffer.writeln();
        buffer.writeln(join(codeLines));
      }
    }

    buffer.writeln(className);

    for (var codeLines in [
      constructorNames,
      fieldNames,
      propertyNames,
      functionNames
    ]) {
      writeCode(codeLines);
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  Iterable<ElementInfo> _getFilteredNames(Iterable<ElementInfo> infos) {
    Iterable<ElementInfo> result = (options.coverage == Coverage.includeImplicit
        ? infos.map((e) => e)
        : infos.where((element) => element.isAnnotated).map((e) => e))
        .where((element) => !element.isIgnore);

    return options.scope == NameofScope.onlyPublic
        ? result.where((element) => !element.isPrivate)
        : result;
  }

  Iterable<String> _getCodeParts(String elementType,
      Iterable<ElementInfo> elements) {
    return _getFilteredNames(elements).map((element) =>
    'final String $elementType${element.scopePrefix}${element.originalName
        .capitalize().privatize()} = \'${element.name}\';');
  }
}
