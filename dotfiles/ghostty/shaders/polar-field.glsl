void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 source = texture(iChannel0, uv);
    float luma = dot(source.rgb, vec3(0.2126, 0.7152, 0.0722));
    float dark = 1.0 - smoothstep(0.20, 0.62, luma);
    float focusAmount = iFocus > 0 ? 1.0 : 0.0;
    float time = iTime * 0.055;

    vec2 scale = vec2(iResolution.x / iResolution.y, 1.0);
    vec2 point = uv * scale;
    vec2 north = vec2((0.68 + 0.08 * sin(time)) * scale.x,
                      0.92 + 0.04 * cos(time * 0.73));
    vec2 south = vec2((0.12 + 0.06 * cos(time * 0.61)) * scale.x,
                      0.03 + 0.05 * sin(time * 0.47));
    float northGlow = exp(-3.2 * dot(point - north, point - north));
    float southGlow = exp(-3.6 * dot(point - south, point - south));
    float horizonY = 0.75 + 0.028 * sin(uv.x * 5.0 + time * 0.75);
    float horizon = exp(-320.0 * pow(uv.y - horizonY, 2.0));
    horizon *= smoothstep(0.04, 0.36, uv.x) * (1.0 - smoothstep(0.68, 1.0, uv.x));

    vec3 color = source.rgb;
    color += dark * focusAmount * (northGlow * iPalette[6] * 0.075
                                 + southGlow * iPalette[13] * 0.070
                                 + horizon * iPalette[6] * 0.042);

    float scanline = 0.5 + 0.5 * sin(fragCoord.y * 1.5707963);
    color *= 1.0 - dark * focusAmount * scanline * 0.011;

    float vignette = clamp(16.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y),
                           0.0, 1.0);
    color *= mix(0.965, 1.0,
                 pow(vignette, 0.22) * focusAmount + (1.0 - focusAmount));

    fragColor = vec4(color, source.a);
}
