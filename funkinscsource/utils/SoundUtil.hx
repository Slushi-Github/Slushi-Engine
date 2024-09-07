package utils;

import openfl.media.Sound;

/**
 * Props for vocal checking because I need variables from the place grabing the props to use here.
 */
typedef VocalPropsCheck =
{
  song:String,
  prefix:String,
  suffix:String,
  externVocal:String,
  character:String,
  difficulty:String
}

/**
 * Small class to help with getting mutiple outcomes of one sound.
 */
class SoundUtil
{
  /**
   * Checks for vocal props and finds all possible vocals with these props.
   */
  public static function findVocal(soundProps:VocalPropsCheck):Sound
  {
    // Props
    final song:String = soundProps.song;
    final prefix:String = soundProps.prefix;
    final suffix:String = soundProps.suffix;
    final vocal:String = soundProps.externVocal;
    final character:String = soundProps.character;
    final difficulty:String = soundProps.difficulty;

    // Final Sound Check
    final findingArguments:Array<String> = [
      // Basic
      vocal + character,
      vocal + difficulty,
      character,
      character + vocal,
      character + difficulty,
      difficulty,
      difficulty + vocal,
      difficulty + character,

      // Complex
      vocal + character + difficulty,
      vocal + difficulty + character,
      character + vocal + difficulty,
      character + difficulty + vocal,
      difficulty + vocal + character,
      difficulty + character + vocal
    ];
    var pathAmount:Int = 0;
    var finalSound:Sound = null;
    finalSound = Paths.voices(prefix, song, suffix, vocal);

    while (finalSound == null && pathAmount != findingArguments.length)
    {
      finalSound = Paths.voices(prefix, song, suffix, findingArguments[pathAmount]);
      pathAmount++;
    }

    return finalSound;
  }

  // // Basic
  // if (finalSound == null) finalSound = Paths.voices(prefix, song, suffix, vocal + character);
  // if (finalSound == null) finalSound = Paths.voices(prefix, song, suffix, vocal + difficulty);
  // if (finalSound == null) finalSound = Paths.voices(prefix, song, suffix, character);
  // if (finalSound == null) finalSound = Paths.voices(prefix, song, suffix, character + vocal);
  // if (finalSound == null) finalSound = Paths.voices(prefix, song, suffix, character + difficulty);
  // if (finalSound == null) finalSound = Paths.voices(prefix, song, suffix, difficulty);
  // if (finalSound == null) finalSound = Paths.voices(prefix, song, suffix, difficulty + vocal);
  // if (finalSound == null) finalSound = Paths.voices(prefix, song, suffix, difficulty + character);
  // // Complex
  // if (finalSound == null) finalSound = Paths.voices(prefix, song, suffix, vocal + character + difficulty);
  // if (finalSound == null) finalSound = Paths.voices(prefix, song, suffix, vocal + difficulty + character);
  // if (finalSound == null) finalSound = Paths.voices(prefix, song, suffix, character + vocal + difficulty);
  // if (finalSound == null) finalSound = Paths.voices(prefix, song, suffix, character + difficulty + vocal);
  // if (finalSound == null) finalSound = Paths.voices(prefix, song, suffix, difficulty + vocal + character);
  // if (finalSound == null) finalSound = Paths.voices(prefix, song, suffix, difficulty + character + vocal);
}
