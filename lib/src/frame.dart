library video_creator.frame;

import 'dart:html';

abstract class Frame {
  ///a simple caption to put at the bottom of the image
  String caption;
  ///the image to use
  Blob image;
  ///length of time this frame takes in seconds
  int duration;
}