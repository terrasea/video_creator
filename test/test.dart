// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library video_creator.test;

import 'package:test/test.dart';
import 'dart:html';
import 'dart:async';
import 'package:polymer/init.dart';
import 'package:polymer/polymer.dart';

import 'package:video_creator/video_creator.dart';
import 'package:video_creator/src/frame.dart';

part 'video_creator_test.dart';

main() async {
  await initPolymer();

  video_creator_test();
}

class NullTreeSanitizer implements NodeTreeSanitizer {
  void sanitizeTree(node) {}
}

class MyFrame implements Frame {
  var image;
  var caption;
  var duration;

  MyFrame(this.image, this.caption, this.duration);
}

Future<Blob> getImage(String url) {
  var completer = new Completer<Blob>();

  HttpRequest.request(url, responseType: 'blob').then((request) {
    completer.complete(request.response);
  });

  return completer.future;
}

schedule(callback) {
  return callback();
}
