package utils;

import openfl.media.Sound;

/**
 * Props for vocal/inst checking because I need variables from the place grabing the props to use here.
 */
typedef SoundMusicPropsCheck =
{
  var ?song:String;
  var ?prefix:String;
  var ?suffix:String;
  var ?externVocal:String;
  var ?character:String;
  var ?difficulty:String;
}

/**
 * Props for sound checking.
 */
typedef SoundPropsCheck =
{
  var ?soundProps:SoundMusicPropsCheck;
  var ?name:String;
  var ?folder:String;
}

/**
 * Small class to help with getting mutiple outcomes of one sound. Made by me -glow
 */
class SoundUtil
{
  /**
   * Checks for sound props and finds all possible vocals or instrumentals with these props.
   * @param soundProps song, prefix, suffix, externalVocal (externVocal), character, difficulty.
   * @param soundType VOCALS or INST.
   * @param postFix if the sound should allow to look for sound with **-**
   * @param list perfered list you want found instead of doing all of the rest.
   * @return Sound
   */
  public static function findVocalOrInst(soundProps:SoundMusicPropsCheck, soundType:String = 'VOCALS', postFix:Bool = true):Sound
  {
    // Props
    final song:String = soundProps.song;
    final prefix:String = soundProps.prefix;
    final suffix:String = soundProps.suffix;
    final vocal:String = soundProps.externVocal;
    final character:String = soundProps.character;
    final difficulty:String = soundProps.difficulty;

    // Final Sound Check
    final findingArguments:Array<String> = !postFix ? [ // Basic
      vocal + character, vocal + difficulty, character, character + vocal, character + difficulty, difficulty, difficulty + vocal, difficulty +
      character, // Complex

      vocal + character + difficulty, vocal + difficulty + character, character + vocal + difficulty, character + difficulty + vocal, difficulty + vocal +
      character, difficulty + character + vocal] : [ // Basic
        vocal + '-' + character,
        vocal + '-' + difficulty,
        character,
        character + '-' + vocal,
        character + '-' + difficulty,
        difficulty,
        difficulty + '-' + vocal,
        difficulty + '-' + character,

        // Complex
        vocal + '-' + character + '-' + difficulty,
        vocal + '-' + difficulty + '-' + character,
        character + '-' + vocal + '-' + difficulty,
        character + '-' + difficulty + '-' + vocal,
        difficulty + '-' + vocal + '-' + character,
        difficulty + '-' + character + '-' + vocal
      ];
    final soundFoundType:String = soundType;
    var completeVocal:String = postFix ? (vocal.startsWith('-') ? vocal : '-$vocal') : vocal;
    var finalSound:Sound = null;

    switch (soundFoundType)
    {
      case 'VOCALS', 'VOC', 'VOCAL':
        finalSound = Paths.voices(prefix, song, suffix, completeVocal);
      case 'INST', 'INSTRUMETANL':
        finalSound = Paths.inst(prefix, song, suffix + completeVocal);
    }

    if (finalSound == null)
    {
      for (external in findingArguments)
      {
        completeVocal = postFix ? (external.startsWith('-') ? external : '-$external') : external;
        switch (soundFoundType)
        {
          case 'VOCALS', 'VOC', 'VOCAL':
            finalSound = Paths.voices(prefix, song, suffix, external);
          case 'INST', 'INSTRUMETANL':
            finalSound = Paths.inst(prefix, song, suffix + external);
        }
        if (finalSound != null) return finalSound;
      }
    }
    return finalSound;
  }

  /**
   * Checks for sound props and finds all possible props for that sound.
   * @param newSoundProps sound, prefix, suffix, externalVocal (externVocal), character, difficulty, folder, type.
   * @param modsAllowed if allowed to search for mod sounds.
   * @param postFix if allows external parts and original to contain **-** at the start.
   * @return Sound
   */
  public static function findSound(newSoundProps:SoundPropsCheck, modsAllowed:Bool = true, postFix:Bool = true):Sound
  {
    // Props
    final fileName:String = newSoundProps.name;
    final prefix:String = newSoundProps.soundProps.prefix;
    final suffix:String = newSoundProps.soundProps.suffix;
    final vocal:String = newSoundProps.soundProps.externVocal;
    final character:String = newSoundProps.soundProps.character;
    final difficulty:String = newSoundProps.soundProps.difficulty;
    final folder:String = newSoundProps.folder;

    // Final Sound Check
    final findingArguments:Array<String> = !postFix ? [ // Basic
      vocal + character, vocal + difficulty, character, character + vocal, character + difficulty, difficulty, difficulty + vocal, difficulty +
      character, // Complex

      vocal + character + difficulty, vocal + difficulty + character, character + vocal + difficulty, character + difficulty + vocal, difficulty + vocal +
      character, difficulty + character + vocal] : [ // Basic
        vocal + '-' + character,
        vocal + '-' + difficulty,
        character,
        character + '-' + vocal,
        character + '-' + difficulty,
        difficulty,
        difficulty + '-' + vocal,
        difficulty + '-' + character,

        // Complex
        vocal + '-' + character + '-' + difficulty,
        vocal + '-' + difficulty + '-' + character,
        character + '-' + vocal + '-' + difficulty,
        character + '-' + difficulty + '-' + vocal,
        difficulty + '-' + vocal + '-' + character,
        difficulty + '-' + character + '-' + vocal
      ];

    var completeVocal:String = postFix ? (vocal.startsWith('-') ? vocal : '-$vocal') : vocal;
    var soundPath:String = '$prefix$fileName$suffix$vocal';
    var finalSound:Sound = Paths.returnSound(soundPath, folder, modsAllowed, false, true);

    if (finalSound == null)
    {
      for (external in findingArguments)
      {
        completeVocal = postFix ? (external.contains('-') ? '-$external' : external) : external;
        soundPath = '$prefix$fileName$suffix$external';
        finalSound = Paths.returnSound(soundPath, folder, modsAllowed, false, true);
        if (finalSound != null) return finalSound;
      }
    }
    return finalSound;
  }
}
