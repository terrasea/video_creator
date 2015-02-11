import 'dart:html';
import 'dart:async';
import 'dart:js' as js;

import 'package:polymer/polymer.dart';

import 'src/frame.dart';

@CustomTag('video-creator')
class VideoCreator extends PolymerElement {
  @PublishedProperty(reflect: true)
  List<Frame> get frames => readValue(#frames);
  void set frames(val) => writeValue(#frames, val);

  @PublishedProperty(reflect: true)
  int get width => readValue(#width) != null ? readValue(#width) : 300;
  void set width(val) => writeValue(#width, val);

  @PublishedProperty(reflect: true)
  int get height => readValue(#height) != null ? readValue(#height) : 300;
  void set height(val) => writeValue(#height, val);

  @PublishedProperty(reflect: true)
  int get captionHeight => readValue(#captionHeight) != null ? readValue(#captionHeight) : 50;
  void set cationHeight(val) => writeValue(#captionHeight, val);

  CanvasElement _canvas;
  js.JsObject _videoWhammy;

  VideoCreator.created() : super.created();

  void attached() {
    super.attached();
    _canvas = $['scratch'];
  }

  Future _process(Frame frame) {
    var completer = new Completer();
    var reader = new FileReader();
    var future = reader.onLoad.listen((event) {
      var image = new ImageElement();
      var future = image.onLoad.listen((event) {
        var context = _canvas.context2D;
        context.clearRect(0, 0, width, height+captionHeight);

        //fill with white for transparent background images, otherwise you get black
        context.fillStyle = 'white';
        context.fillRect(0, 0, width, height+captionHeight);

        context.drawImageScaled(image, 0, 0, width, height);

        context.fillStyle = 'white';
        context.fillRect(0, height, width, height+captionHeight);
        context.setFillColorRgb(0, 2, 2);
        context.fillText(frame.caption, 0, height+10, width);
        context.stroke();
        _videoWhammy.callMethod('add', [_canvas.toDataUrl('image/webp', 1), frame.duration]);
        context.clearRect(0, 0, width, height+captionHeight);
        completer.complete();
      }).asFuture();
      image.src = event.target.result;
      document.body.append(image);
    }).asFuture();
    reader.readAsDataUrl(frame.image);

    return completer.future;
  }

  void framesChanged(old, current) {
    if(frames.length > 0) {
      _processImages().then((_) {
        var video = _videoWhammy.callMethod('compile');
        this.fire('encode-complete', detail: video);
      });
    }
  }

  Future _processImages() {
    var futures = new List<Future>();
    _videoWhammy = new js.JsObject(js.context['Whammy']['Video']);
    frames.forEach((frame) {
      futures.add(_process(frame));
    });

    return Future.wait(futures);
  }
}
