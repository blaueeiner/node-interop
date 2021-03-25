// Copyright (c) 2018, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:build_modules/build_modules.dart';
import 'package:build_node_compilers/build_node_compilers.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  late Map<String, dynamic> assets;
  final platform = dart2jsPlatform;

  setUp(() async {
    assets = <String, Object>{
      'b|lib/b.dart': '''
        // @dart=2.9
        final world = 'world';''',
      'a|lib/a.dart': '''
        // @dart=2.9
        import 'package:b/b.dart';
        final hello = world;
      ''',
      'a|web/index.dart': '''
        // @dart=2.9
        import "package:a/a.dart";
        main() {
          print(hello);
        }
      ''',
    };

    // Set up all the other required inputs for this test.
    await testBuilderAndCollectAssets(const ModuleLibraryBuilder(), assets);
    await testBuilderAndCollectAssets(MetaModuleBuilder(platform), assets);
    await testBuilderAndCollectAssets(MetaModuleCleanBuilder(platform), assets);
    await testBuilderAndCollectAssets(ModuleBuilder(platform), assets);
  });

  test('can bootstrap dart entrypoints', () async {
    // Just do some basic sanity checking, integration tests will validate
    // things actually work.
    var expectedOutputs = {
      'a|web/index.dart.js': decodedMatches(contains('world')),
      'a|web/index.dart.js.map': anything,
    };
    await testBuilder(NodeEntrypointBuilder(WebCompiler.Dart2Js), assets as Map<String, Object>,
        outputs: expectedOutputs);
  });
}
