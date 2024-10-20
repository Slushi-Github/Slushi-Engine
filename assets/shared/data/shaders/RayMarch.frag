 #pragma header

  // "RayMarching starting point"
  // by Martijn Steinrucken aka The Art of Code/BigWings - 2020
  // The MIT License
  // Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  // Email: countfrolic@gmail.com
  // Twitter: @The_ArtOfCode
  // YouTube: youtube.com/TheArtOfCodeIsCool
  // Facebook: https://www.facebook.com/groups/theartofcode/
  //
  // You can use this shader as a template for ray marching shaders

  const float MAX_STEPS = 100;
  const float MAX_DIST = 100.0;
  const float SURF_DIST = 0.001;
  uniform vec3 rotation;
  uniform vec3 iResolution;
  uniform float zoom;
  uniform float MAX_STEPS_LIMIT;
  uniform float MAX_DIST_LIMIT;
  uniform float SURF_DIST_LIMIT;
  // Rotation matrix around the X axis.
  mat3 rotateX(float theta)
  {
    float
    c = cos(theta);
    float
    s = sin(theta);
    return mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, c, -s), vec3(0.0, s, c));
  }
  // Rotation matrix around the Y axis.
  mat3 rotateY(float theta)
  {
    float
    c = cos(theta);
    float
    s = sin(theta);
    return mat3(vec3(c, 0.0, s), vec3(0.0, 1.0, 0.0), vec3(-s, 0.0, c));
  }
  // Rotation matrix around the Z axis.
  mat3 rotateZ(float theta)
  {
    float
    c = cos(theta);
    float
    s = sin(theta);
    return mat3(vec3(c, -s, 0.0), vec3(s, c, 0.0), vec3(0.0, 0.0, 1.0));
  }
  mat2 Rot(float a)
  {
    float
    s = sin(a),
    c = cos(a);
    return mat2(c, -s, s, c);
  }
  float sdBox(vec3 p, vec3 s)
  {
    // p = p * rotateX(rotation.x) * rotateY(rotation.y) * rotateZ(rotation.z);
    p = abs(p) - s;
    return length(max(p, 0.)) + min(max(p.x, max(p.y, p.z)), 0.);
  }
  float plane(vec3 p, vec3 offset)
  {
    float
    d = p.z;
    return d;
  }
  float GetDist(vec3 p)
  {
    float
    d = plane(p, vec3(0.0, 0.0, 0.0));
    return d;
  }
  float RayMarch(vec3 ro, vec3 rd)
  {
    float
    dO = 0.;
    for (int i = 0;
    i < MAX_STEPS + MAX_STEPS_LIMIT;
    i++
  )
    {
      vec3
      p = ro + rd * dO;
      float
      dS = GetDist(p);
      dO += dS;
      if (dO > MAX_DIST + MAX_DIST_LIMIT || abs(dS) < SURF_DIST + SURF_DIST_LIMIT) break;
    }
    return dO;
  }
  vec3 GetNormal(vec3 p)
  {
    float
    d = GetDist(p);
    vec2
    e = vec2(.001, 0.0);
    vec3
    n = d - vec3(GetDist(p - e.xyy), GetDist(p - e.yxy), GetDist(p - e.yyx));
    return normalize(n);
  }
  vec3 GetRayDir(vec2 uv, vec3 p, vec3 l, float z)
  {
    vec3
    f = normalize(l - p),
    r = normalize(cross(vec3(0.0, 1.0, 0.0), f)),
    u = cross(f, r),
    c = f * z,
    i = c + uv.x * r + uv.y * u,
    d = normalize(i);
    return d;
  }
  vec2 repeat(vec2 uv)
  {
    return vec2(abs(mod(uv.x, 1.0)), abs(mod(uv.y, 1.0)));
  }
  void main() // this shader is pain
  {
    vec2
    center = vec2(0.5, 0.5);
    vec2
    uv = openfl_TextureCoordv.xy - center;
    uv.x = 0 - uv.x;
    vec3
    ro = vec3(0.0, 0.0, zoom);
    ro = ro * rotateX(rotation.x) * rotateY(rotation.y) * rotateZ(rotation.z);
    // ro.yz *= Rot(ShaderPointShit.y); //rotation shit
    // ro.xz *= Rot(ShaderPointShit.x);
    vec3
    rd = GetRayDir(uv, ro, vec3(0.0, 0., 0.0), 1.0);
    vec4
    col = vec4(0.0);
    float
    d = RayMarch(ro, rd);
    if (d < MAX_DIST + MAX_DIST_LIMIT)
    {
      vec3
      p = ro + rd * d;
      uv = vec2(p.x, p.y) * 0.5;
      uv += center; // move coords from top left to center
      col = flixel_texture2D(bitmap, repeat(uv)); // shadertoy to haxe bullshit i barely understand
    }
    gl_FragColor = col;
  }
