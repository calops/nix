#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float uTime;
    vec4 baseColor;
    vec4 accentColor;  // Teal
    vec4 accentColor2; // Mauve
    vec4 accentColor3; // Sapphire
    vec4 accentColor4; // Peach
    vec4 accentColor5; // Yellow
    vec4 accentColor6; // Red
    vec2 uWidth;
    vec2 uHeight;
} ubuf;

// Wire function: optimized for thickness and amplitude
float wire(vec2 uv, float speed, float freq, float phase, float offset, float amplitude, float width, float glow) {
    float t = ubuf.uTime * speed;
    // Multi-octave sine for organic flow
    float y = sin(uv.x * freq + t + phase) * amplitude;
    y += sin(uv.x * (freq * 1.6) + t * 0.7 + phase * 2.0) * (amplitude * 0.3);
    y += offset;
    
    float d = abs(uv.y - y);
    return smoothstep(width + glow, width, d);
}

// Function to get a color from the 6-accent cycle based on a 0-1 phase
vec3 getCycleColor(float t) {
    float m = mod(t, 6.0);
    int i = int(floor(m));
    float f = fract(m);
    float f_smooth = f * f * (3.0 - 2.0 * f);
    
    vec3 c[6];
    c[0] = ubuf.accentColor.rgb;  // Teal
    c[1] = ubuf.accentColor2.rgb; // Mauve
    c[2] = ubuf.accentColor3.rgb; // Sapphire
    c[3] = ubuf.accentColor4.rgb; // Peach
    c[4] = ubuf.accentColor5.rgb; // Yellow
    c[5] = ubuf.accentColor6.rgb; // Red
    
    return mix(c[i], c[int(mod(i + 1, 6))], f_smooth);
}

void main() {
    vec2 uv = qt_TexCoord0;
    vec3 color = ubuf.baseColor.rgb;
    
    float cycleSpeed = 0.12;
    float t = ubuf.uTime * cycleSpeed;
    
    // Increased line count to 6 for more density
    // Increased amplitude to 0.25+
    // Slightly thicker lines (0.0006 vs 0.0002)
    
    for (int i = 0; i < 6; i++) {
        float fi = float(i);
        float phase = fi * 1.047; // Offset phases
        float speed = 0.2 + fi * 0.1;
        if (mod(fi, 2.0) > 0.5) speed *= -1.2; // Alternate directions
        
        float offset = 0.4 + fi * 0.04;
        float amp = 0.22 + sin(t * 0.5 + fi) * 0.05;
        
        float w = wire(uv, speed, 1.5 + fi * 0.3, phase, offset, amp, 0.0006, 0.003);
        vec3 c = getCycleColor(t + fi * 1.2);
        
        color = mix(color, c, w * (0.6 + fi * 0.05));
        
        // Add a brighter core for each
        float core = wire(uv, speed, 1.5 + fi * 0.3, phase, offset, amp, 0.0001, 0.0005);
        color += mix(c, vec3(1.0), 0.4) * core * 0.5;
    }

    // Subtle vignette
    float vig = 1.0 - length(uv - 0.5) * 0.4;
    color *= vig;
    
    fragColor = vec4(color, 1.0) * ubuf.qt_Opacity;
}
