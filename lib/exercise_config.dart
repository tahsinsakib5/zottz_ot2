// models/exercise_config.dart
class ExerciseCounts {
  final int scissor, pencil, pincher, button;

  const ExerciseCounts({
    this.scissor = 0,
    this.pencil = 0, 
    this.pincher = 0,
    this.button = 0,
  });
}

class ExerciseConfig {
  final bool chkScissor, chkPencil, chkPincher, chkButton;
  final bool musicScissor, musicPencil, musicPincher, musicButton;
  final bool noLed, repeatMode;
  final int mode;
  final String modeName;
  final ExerciseCounts counts;

  const ExerciseConfig({
    this.chkScissor = false,
    this.chkPencil = false,
    this.chkPincher = false, 
    this.chkButton = false,
    this.musicScissor = true,
    this.musicPencil = true,
    this.musicPincher = true,
    this.musicButton = true,
    this.noLed = false,
    this.repeatMode = false,
    this.mode = 0,
    this.modeName = '',
    required this.counts,
  });
}