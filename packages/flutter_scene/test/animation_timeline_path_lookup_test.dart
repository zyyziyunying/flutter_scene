// Timeline search is shared by TRS, morph and path-property animation.
// ignore_for_file: implementation_imports
import 'dart:typed_data';

import 'package:flutter_scene/scene.dart' show Node;
import 'package:flutter_scene/src/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  for (final step in [false, true]) {
    test('path lookup preserves duplicates and boundaries, step=$step', () {
      final node = Node(name: 'target');
      final state = AnimatedPathState(resolveAnimatedPath(node, 'visible')!);
      final target = AnimationTransforms(
        bindPose: DecomposedTransform(
          translation: Vector3.zero(),
          rotation: Quaternion.identity(),
          scale: Vector3.all(1),
        ),
      )..paths['visible'] = state;
      final resolver = PropertyResolver.makePathTimeline(
        'visible',
        [0, .5, .5, 1],
        Float32List.fromList([0, 1, 0, 1]),
        componentCount: 1,
        step: step,
      );
      for (final time in [-1.0, 0.0, .25, .5, .75, 1.0, 2.0]) {
        state.animated.setAll(0, state.bind);
        resolver.apply(target, time, 1);
        final expected = switch (time) {
          < .0 => 0.0,
          .0 => 0.0,
          .25 => step ? 0.0 : .5,
          .5 => 1.0,
          .75 => step ? 0.0 : .5,
          _ => 1.0,
        };
        expect(state.animated[0], expected, reason: 'time=$time');
      }
    });
  }
}
