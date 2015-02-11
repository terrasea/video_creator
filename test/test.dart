// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library video_creator.test;

import 'dart:html';
import 'dart:async';

import 'package:polymer/polymer.dart';
import 'package:scheduled_test/scheduled_test.dart';


import 'package:video_creator/video_creator.dart';
import 'package:video_creator/src/frame.dart';

main() {
  initPolymer();

  group('[video-creator]', () {
    VideoCreator creator;

    setUp(() {
      schedule(() => Polymer.onReady);
      schedule(() {
        var completer = new Completer();
        creator = new Element.html('<video-creator></video-creator>', treeSanitizer: new NullTreeSanitizer());
        document.body.append(creator);
        creator.async((_) => completer.complete());

        return completer.future;
      });

      currentSchedule.onComplete.schedule(() {
        creator.remove();
        creator = null;
      });
    });

    test('is created', () {
      schedule(() {
        expect(creator, isNotNull);
      });
    });

    test('shadowRoot is present', () {
      schedule(() {
        expect(creator.shadowRoot, isNotNull);
      });
    });

    test('fires encode-complete when finished creating video', () {
      var completer = new Completer();
      schedule(() {
        creator.on['encode-complete'].first.then((e) {
          completer.complete();
        });
      });
      schedule(() {
        List<Future<Blob>> blobs = [getImage('img/img01.png'), getImage('img/img02.png')];
        return Future.wait(blobs).then((blobList) {
          var frames = blobList.map((blob) => new MyFrame(blob, "Caption", 1000)).toList();
          creator.frames = frames;
        });
      });
      schedule(() {
        expect(completer.future, completes);
      });
    });

    test('when encode-complete fired video is created', () {
      var completer = new Completer<Blob>();
      schedule(() {
        creator.on['encode-complete'].first.then((e) {
          completer.complete(e.detail);
        });
      });
      schedule(() {
        List<Future<Blob>> blobs = [getImage('img/img01.png'), getImage('img/img02.png')];
        return Future.wait(blobs).then((blobList) {
          var frames = blobList.map((blob) => new MyFrame(blob, "Caption", 2000)).toList();
          creator.frames = frames;
        });
      });
      var durationCompleter = new Completer<double>();
      schedule(() {
        completer.future.then((blob) {
          expect(blob is Blob, isTrue);
          VideoElement video = new VideoElement()
            ..src = Url.createObjectUrl(blob)
            ..onDurationChange.listen((e) {
              durationCompleter.complete(e.target.duration);
            });
        });
        expect(completer.future, completes);

        return durationCompleter.future;
      });
      schedule(() {
        durationCompleter.future.then((duration) {
          expect(duration, 4.0);
        });
        expect(durationCompleter.future, completes);
      });
    });
  });
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