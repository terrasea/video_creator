import 'dart:html';

import 'package:polymer/polymer.dart';

import 'package:video_creator/src/frame.dart';

List frames = toObservable([]);

main() {
  initPolymer().run(() {
    Polymer.onReady.then((_) {
      querySelector('video-creator')
        ..frames = frames
        ..on['encode-complete'].listen((event) {
          VideoElement video = querySelector('video');
          video.src = Url.createObjectUrl(event.detail);
          video.onDurationChange.listen((e) {
            print('duration: ${video.duration}');
          });

          print('duration: ${video.duration}');
        })
        ;
    });

  });

  querySelector('#files').onChange.listen(upload);
}

void upload(Event e) {
  frames
    ..clear()
    ..addAll((e.target as FileUploadInputElement).files.map((file) {
      return new MyFrame(file, 2000, "This is my trip");
    }))
    ;
}


class MyFrame implements Frame {
  Blob image;
  String caption;
  int duration;

  MyFrame(this.image, this.duration, [this.caption = '']);
}