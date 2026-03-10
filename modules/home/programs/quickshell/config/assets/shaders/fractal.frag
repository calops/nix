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

// 2D Rotation matrix
mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

// Function to get a color from the 6-accent cycle
vec3 getCycleColor(float t) {
    float m = mod(t, 6.0);
    int i = int(floor(m));
    float f = fract(m);
    float f_smooth = f * f * (3.0 - 2.0 * f);
    
    vec3 c[6];
    c[0] = ubuf.accentColor.rgb;
    c[1] = ubuf.accentColor2.rgb;
    c[2] = ubuf.accentColor3.rgb;
    c[3] = ubuf.accentColor4.rgb;
    c[4] = ubuf.accentColor5.rgb;
    c[5] = ubuf.accentColor6.rgb;
    
    return mix(c[i], c[(i + 1) % 6], f_smooth);
}

void main() {
    // Correct aspect ratio and center
    vec2 uv = (qt_TexCoord0 - 0.5) * 2.5; // Slightly zoomed out for more coverage
    uv.x *= ubuf.uWidth.x / ubuf.uHeight.x;
    
    float t = ubuf.uTime * 0.07; // Increased from 0.04 for slightly faster movement
    
    // Global rotation
    uv *= rot(t * 0.05);
    
    vec3 col = ubuf.baseColor.rgb;
    vec2 p = uv;
    
    float d = 1e10;
    float iters = 0.0;
    
    // Deep KIFS
    for(int i = 0; i < 8; i++) {
        p = abs(p) - 0.6; // Wider fold for edge-to-edge
        p *= rot(t * 0.15 + float(i) * 0.3);
        p *= 1.4; 
        p -= 0.05 * sin(t + float(i));
        
        float dist = length(p.x * p.y);
        d = min(d, dist);
        
        if (dist < 0.15) {
            iters += (0.15 - dist) * pow(0.75, float(i));
        }
    }
    
    // Color mapping - more muted
    vec3 accentColor = getCycleColor(t + length(uv) * 0.3);
    vec3 secondaryColor = getCycleColor(t * 1.2 + iters);
    
    // The "fractal" structure - lowered opacity
    float lines = smoothstep(0.02, 0.0, d);
    col = mix(col, accentColor, lines * 0.4); // Lowered from 0.8
    
    // Glow - significantly dimmed for lower brightness
    float glow = 0.003 / (d + 0.008);
    col += secondaryColor * glow * 0.6; // Lowered from 1.2
    
    // Highlights - less white, more palette
    float hits = smoothstep(0.0015, 0.0, d);
    col += accentColor * hits * 0.3; // Much dimmer
    
    // Background texture - slightly higher for more detail in dark areas
    col += accentColor * iters * 0.05; // Increased from 0.04
    
    // Softer darkening of the background outside the fractal
    // Raising the target to baseColor * 1.1 to lift shadows
    col = mix(ubuf.baseColor.rgb * 1.1, col, smoothstep(-0.8, 1.2, iters + glow));
    
    // Removed the aggressive vignette for edge-to-edge coverage
    // Just a very subtle fade at the extreme corners to avoid hard cutoffs
    col *= smoothstep(3.5, 1.5, length(uv));
    
    fragColor = vec4(col, 1.0) * ubuf.qt_Opacity;
}
