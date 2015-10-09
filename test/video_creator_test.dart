part of video_creator.test;

void video_creator_test() {
  group('[video-creator]', () {
    VideoCreator creator;

    setUp(() {
      var completer = new Completer();
      creator = new Element.html('<video-creator></video-creator>', treeSanitizer: new NullTreeSanitizer());
      document.body.append(creator);
      creator.async(() => completer.complete());

      return completer.future;
    });

    tearDown(() {
      creator.remove();
      creator = null;
    });

    test('is created', () {
      expect(creator, isNotNull);
    });

//    Not relevant in Polymer Dart 1.0.0 as it doesn't use ShadowRoot by default
//    test('shadowRoot is present', () {
//      schedule(() {
//        expect(creator.shadowRoot, isNotNull);
//      });
//    });

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
          creator.set('frames', frames);
        });
      });
      schedule(() {
        expect(completer.future, completes);
      });
    });

    test('when encode-complete fired video is created', () async {
      var completer = new Completer<Blob>();
      creator.on['encode-complete'].first.then((e) {
        completer.complete(e.detail);
      });
      List<Blob> blobList = [await getImage('img/img01.png'), await getImage('img/img02.png')];
      List<Frame> frames = blobList.map((blob) => new MyFrame(blob, "Caption", 2000)).toList();
      creator.set('frames', frames);
      var durationCompleter = new Completer<double>();
      completer.future.then((blob) {
        expect(blob is Blob, isTrue);
        VideoElement video = new VideoElement()
          ..src = Url.createObjectUrl(blob)
          ..onDurationChange.listen((e) {
          durationCompleter.complete(e.target.duration);
        });
        expect(completer.future, completes);

        durationCompleter.future.then((duration) {
          expect(duration, 4.0);
        });
        expect(durationCompleter.future, completes);
      });
    });

    test('encodeFrames fires encode-complete and video is created', () async {
      var completer = new Completer<Blob>();
      creator.on['encode-complete'].first.then((e) {
        completer.complete(e.detail);
      });
      List<Blob> blobList = [await getImage('img/img01.png'), await getImage('img/img02.png')];
      List<Frame> frames = blobList.map((blob) => new MyFrame(blob, "Caption", 2000)).toList();

      creator.encodeFrames(frames);

      var durationCompleter = new Completer<double>();
      completer.future.then((blob) {
        expect(blob is Blob, isTrue);
        VideoElement video = new VideoElement()
          ..src = Url.createObjectUrl(blob)
          ..onDurationChange.listen((e) {
          durationCompleter.complete(e.target.duration);
        });
        expect(completer.future, completes);

        durationCompleter.future.then((duration) {
          expect(duration, 4.0);
        });
        expect(durationCompleter.future, completes);
      });
    });
  });
}