package utils;

/**
  * Class contains regular FlxEases and advanced ones.
  ** Class is used for more than the original eases from FlxEase.
  * Class is also used for EASE external functiones such as *stepped();*
 */
class EaseUtil
{
  /**
   * Returns an ease function that eases via steps.
   * Useful for "retro" style fades (week 6!)
   * @param steps how many steps to ease over
   * @return Float->Float
   */
  public static inline function stepped(steps:Int):Float->Float
  {
    return function(t:Float):Float {
      return Math.floor(t * steps) / steps;
    }
  }

  public static inline function bounce(t:Float):Float
  {
    return 4 * t * (1 - t);
  }

  public static inline function tri(t:Float):Float
  {
    return 1 - Math.abs(2 * t - 2);
  }

  public static inline function bell(t:Float):Float
  {
    return quintInOut(tri(t));
  }

  public static inline function pop(t:Float):Float
  {
    return 3.5 * (1 - t) * (1 - t) * Math.sqrt(t);
  }

  public static inline function tap(t:Float):Float
  {
    return 3.5 * t * t * Math.sqrt(1 - t);
  }

  public static inline function pulse(t:Float):Float
  {
    return t < .5 ? tap(t * 2) : -pop(t * 2 - 1);
  }

  public static inline function spike(t:Float):Float
  {
    return Math.exp(-10 * Math.abs(2 * t - 1));
  }

  public static inline function inverse(t:Float):Float
  {
    return t * t * (1 - t) * (1 - t) / (0.5 - t);
  }

  public static inline function popElastic(t:Float):Float
  {
    return InternalEases.popElasticInternal(t, 1.4, 6);
  }

  public static inline function tapElastic(t:Float):Float
  {
    return InternalEases.tapElasticInternal(t, 1.4, 6);
  }

  public static inline function pulseElastic(t:Float):Float
  {
    return InternalEases.pulseElasticInternal(t, 1.4, 6);
  }

  public static inline function impluse(t:Float):Float
  {
    return InternalEases.impulseInternal(t, 0.9);
  }

  public static inline function instant(t:Float):Float
  {
    return t = 1.0;
  }

  public static inline function linear(t:Float):Float
  {
    return t;
  }

  public static inline function quadIn(t:Float):Float
  {
    return t * t;
  }

  public static inline function quadOut(t:Float):Float
  {
    return -t * (t - 2);
  }

  public static inline function quadInOut(t:Float):Float
  {
    t = t * 2;
    return t < 1 ? 0.5 * Math.pow(t, 2) : 1 - 0.5 * Math.pow((2 - t), 2);
  }

  public static inline function quadOutIn(t:Float):Float
  {
    t = t * 2;
    return t < 1 ? 0.5 - 0.5 * Math.pow((1 - t), 2) : 0.5 + 0.5 * Math.pow((t - 1), 2);
  }

  public static inline function cubeIn(t:Float):Float
  {
    return t * t * t;
  }

  public static inline function cubeOut(t:Float):Float
  {
    return 1 - Math.pow((1 - t), 3);
  }

  public static inline function cubeInOut(t:Float):Float
  {
    t = t * 2;
    return t < 1 ? 0.5 * Math.pow(t, 3) : 1 - 0.5 * Math.pow((2 - t), 3);
  }

  public static inline function cubeOutIn(t:Float):Float
  {
    t = t * 2;
    return t < 1 ? 0.5 - 0.5 * Math.pow((1 - t), 3) : 0.5 + 0.5 * Math.pow((t - 1), 3);
  }

  public static inline function quartIn(t:Float):Float
  {
    return t * t * t * t;
  }

  public static inline function quartOut(t:Float):Float
  {
    return 1 - Math.pow((1 - t), 4);
  }

  public static inline function quartInOut(t:Float):Float
  {
    t = t * 2;
    return t < 1 ? 0.5 * Math.pow(t, 4) : 1 - 0.5 * Math.pow((2 - t), 4);
  }

  public static inline function quartOutIn(t:Float):Float
  {
    t = t * 2;
    return t < 1 ? 0.5 - 0.5 * Math.pow((1 - t), 4) : 0.5 * 0.5 * Math.pow((t - 1), 4);
  }

  public static inline function quintIn(t:Float):Float
  {
    return t * t * t * t * t;
  }

  public static inline function quintOut(t:Float):Float
  {
    return 1 - Math.pow((1 - t), 5);
  }

  public static inline function quintInOut(t:Float):Float
  {
    t = t * 2;
    return t < 1 ? 0.5 * Math.pow(t, 5) : 1 - 0.5 * Math.pow((2 - t), 5);
  }

  public static inline function quintOutIn(t:Float):Float
  {
    t = t * 2;
    return t < 1 ? 0.5 - 0.5 * Math.pow((1 - t), 5) : 0.5 + 0.5 * Math.pow((t - 1), 5);
  }

  public static inline function smoothStepIn(t:Float):Float
  {
    return 2 * smoothStepInOut(t / 2);
  }

  public static inline function smoothStepOut(t:Float):Float
  {
    return 2 * smoothStepInOut(t / 2 + 0.5) - 1;
  }

  public static inline function smoothStepInOut(t:Float):Float
  {
    return t * t * (t * -2 + 3);
  }

  public static inline function smootherStepIn(t:Float):Float
  {
    return 2 * smootherStepInOut(t / 2);
  }

  public static inline function smootherStepOut(t:Float):Float
  {
    return 2 * smootherStepInOut(t / 2 + 0.5) - 1;
  }

  public static inline function smootherStepInOut(t:Float):Float
  {
    return t * t * t * (t * (t * 6 - 15) + 10);
  }

  public static inline function sineIn(t:Float):Float
  {
    return 1 - Math.cos(t * (Math.PI * 0.5));
  }

  public static inline function sineOut(t:Float):Float
  {
    return Math.sin(t * (Math.PI * 0.5));
  }

  public static inline function sineInOut(t:Float):Float
  {
    return 0.5 - 0.5 * Math.cos(t * Math.PI);
  }

  public static inline function sineOutIn(t:Float):Float
  {
    return t < .5 ? sineOut(t * 2) * 0.5 : sineIn((t * 2 - 1)) * 0.5 + 0.5;
  }

  public static inline function bounceOut(t:Float):Float
  {
    if (t < 1 / 2.75) return 7.5625 * t * t;
    if (t < 2 / 2.75)
    {
      t = t - 1.5 / 2.75;
      return 7.5625 * t * t + 0.75;
    }
    if (t < 2.5 / 2.75)
    {
      t = t - 2.25 / 2.75;
      return 7.5625 * t * t + 0.9375;
    }
    t = t - 2.625 / 2.75;
    return 7.5625 * t * t + 0.984375;
  }

  public static inline function bounceIn(t:Float):Float
  {
    return 1 - bounceOut(1 - t);
  }

  public static inline function bounceInOut(t:Float):Float
  {
    return t < 0.5 ? bounceIn(t * 2) * 0.5 : bounceOut(t * 2 - 1) * 0.5 + 0.5;
  }

  public static inline function bounceOutIn(t:Float):Float
  {
    return t < 0.5 ? bounceOut(t * 2) * 0.5 : bounceIn(t * 2 - 1) * 0.5 + 0.5;
  }

  public static inline function circIn(t:Float):Float
  {
    return 1 - Math.sqrt(1 - t * t);
  }

  public static inline function circOut(t:Float):Float
  {
    return Math.sqrt(-t * t + 2 * t);
  }

  public static inline function circInOut(t:Float):Float
  {
    t = t * 2;
    if (t < 1) return 0.5 - 0.5 * Math.sqrt(1 - t * t);
    t = t - 2;
    return 0.5 + 0.5 * Math.sqrt(1 - t * t);
  }

  public static inline function circOutIn(t:Float):Float
  {
    return t < 0.5 ? circOut(t * 2) * 0.5 : circIn(t * 2 - 1) * 0.5 + 0.5;
  }

  public static inline function expoIn(t:Float):Float
  {
    return Math.pow(1000, (t - 1)) - 0.001;
  }

  public static inline function expoOut(t:Float):Float
  {
    return 1.001 - Math.pow(1000, -t);
  }

  public static inline function expoInOut(t:Float):Float
  {
    t = t * 2;
    return t < 1 ? 0.5 * Math.pow(1000, (t - 1)) - 0.0005 : 1.0005 - 0.5 * Math.pow(1000, (1 - t));
  }

  public static inline function expoOutIn(t:Float):Float
  {
    return t < 0.5 ? expoOut(t * 2) * 0.5 : expoIn(t * 2 - 1) * 0.5 + 0.5;
  }

  public static inline function backIn(t:Float):Float
  {
    return InternalEases.inBackInternal(t, 1.70158);
  }

  public static inline function backOut(t:Float):Float
  {
    return InternalEases.outBackInternal(t, 1.70158);
  }

  public static inline function backInOut(t:Float):Float
  {
    return InternalEases.inOutBackInternal(t, 1.70158);
  }

  public static inline function backOutIn(t:Float):Float
  {
    return InternalEases.outInBackInternal(t, 1.70158);
  }

  public static inline function elasticIn(t:Float):Float
  {
    return InternalEases.inElasticInternal(t, 1, 0.3);
  }

  public static inline function elasticOut(t:Float):Float
  {
    return InternalEases.outElasticInternal(t, 1, 0.3);
  }

  public static inline function elasticInOut(t:Float):Float
  {
    return InternalEases.inOutElasticInternal(t, 1, 0.3);
  }

  public static inline function elasticOutIn(t:Float):Float
  {
    return InternalEases.outInElasticInternal(t, 1, 0.3);
  }
}

// Internal functiones to then convert to the main functiones
class InternalEases
{
  public static inline function popElasticInternal(t:Float, damp:Float, count:Float):Float
  {
    return (Math.pow(1000, -(Math.pow(t, damp))) - 0.001) * Math.sin(count * Math.PI * t);
  }

  public static inline function tapElasticInternal(t:Float, damp:Float, count:Float):Float
  {
    return (Math.pow(1000, -(Math.pow((1 - t), damp))) - 0.001) * Math.sin(count * Math.PI * (1 - t));
  }

  public static inline function pulseElasticInternal(t:Float, damp:Float, count:Float):Float
  {
    return t < .5 ? tapElasticInternal(t * 2, damp, count) : -popElasticInternal(t * 2 - 1, damp, count);
  }

  public static inline function impulseInternal(t:Float, damp:Float):Float
  {
    t = Math.pow(t, damp);
    return t * (Math.pow(100, -t) - 0.001) * 18.6;
  }

  public static inline function inBackInternal(t:Float, a:Float):Float
  {
    return t * t * (a * t + t - a);
  }

  public static inline function outBackInternal(t:Float, a:Float):Float
  {
    t = t - 1;
    return t * t * ((a + 1) * t + a) + 1;
  }

  public static inline function inOutBackInternal(t:Float, a:Float):Float
  {
    return t < 0.5 ? 0.5 * inBackInternal(t * 2, a) : 0.5 + 0.5 * outBackInternal(t * 2 - 1, a);
  }

  public static inline function outInBackInternal(t:Float, a:Float):Float
  {
    return t < 0.5 ? 0.5 * outBackInternal(t * 2, a) : 0.5 + 0.5 * inBackInternal(t * 2 - 1, a);
  }

  public static inline function outElasticInternal(t:Float, a:Float, p:Float):Float
  {
    return a * Math.pow(2, -10 * t) * Math.sin((t - p / (2 * Math.PI) * Math.asin(1 / a)) * 2 * Math.PI / p) + 1;
  }

  public static inline function inElasticInternal(t:Float, a:Float, p:Float):Float
  {
    return 1 - outElasticInternal(1 - t, a, p);
  }

  public static inline function inOutElasticInternal(t:Float, a:Float, p:Float):Float
  {
    return t < 0.5 ? 0.5 * inElasticInternal(t * 2, a, p) : 0.5 + 0.5 * outElasticInternal(t * 2 - 1, a, p);
  }

  public static inline function outInElasticInternal(t:Float, a:Float, p:Float):Float
  {
    return t < 0.5 ? 0.5 * outElasticInternal(t * 2, a, p) : 0.5 + 0.5 * inElasticInternal(t * 2 - 1, a, p);
  }
}
