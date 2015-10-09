import 'dart:html';

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

import 'package:video_creator/video_creator.dart';
import 'package:video_creator/src/frame.dart';

List frames = [];

main() async {
  await initPolymer();
  (querySelector('video-creator') as VideoCreator)
    ..on['encode-complete'].listen((event) {
      VideoElement video = querySelector('video');
      video.src = Url.createObjectUrl(event.detail);
      video.onDurationChange.listen((e) {
        print('duration: ${video.duration}');
      });

      print('duration: ${video.duration}');
    })
    ;


  querySelector('#files').onChange.listen(upload);
}

void upload(Event e) {
  print('uploaded');
  frames
    ..clear()
    ..addAll((e.target as FileUploadInputElement).files.map((file) {
      return new MyFrame(file, 2000, "This is my trip");
    }))
    ;
  (querySelector('video-creator') as VideoCreator).encodeFrames(frames);
}


class MyFrame implements Frame {
  Blob image;
  String caption;
  int duration;

  MyFrame(this.image, this.duration, [this.caption = '']);
}