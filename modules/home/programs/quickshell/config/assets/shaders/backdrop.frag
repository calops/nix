#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float uTime;
    vec4 baseColor;
    vec4 accentColor;
    float uWidth;
    float uHeight;
};

void main() {
    vec2 uv = qt_TexCoord0;
    
    // Slow, breathing pulse effect
    float pulse = sin(uTime * 0.2) * 0.5 + 0.5;
    
    // Moving radial gradients
    vec2 pos1 = vec2(0.5 + 0.2 * cos(uTime * 0.1), 0.5 + 0.2 * sin(uTime * 0.12));
    vec2 pos2 = vec2(0.5 + 0.3 * sin(uTime * 0.08), 0.5 + 0.3 * cos(uTime * 0.15));
    
    // Adjust aspect ratio for circular gradients
    vec2 aspect = vec2(uWidth / uHeight, 1.0);
    float dist1 = length((uv - pos1) * aspect);
    float dist2 = length((uv - pos2) * aspect);
    
    float grad1 = smoothstep(0.8, 0.0, dist1);
    float grad2 = smoothstep(1.0, 0.0, dist2);
    
    // Mix colors based on gradients
    vec4 color = baseColor;
    
    // Convert accent color to premultiplied alpha before mixing to avoid dark halos
    vec4 premultAccent = vec4(accentColor.rgb * accentColor.a, accentColor.a);
    
    color = mix(color, premultAccent, grad1 * 0.3 * pulse);
    color = mix(color, vec4(premultAccent.rgb, 0.8), grad2 * 0.2);
    
    // Add a very subtle noise/grain
    float noise = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    color.rgb += vec3((noise - 0.5) * 0.03) * color.a;
    
    fragColor = color * qt_Opacity;
}
