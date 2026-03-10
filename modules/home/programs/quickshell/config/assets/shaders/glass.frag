#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float radius;
    vec4 baseColor;
    float uWidth;
    float uHeight;
};

float sdRoundRect(vec2 p, vec2 b, float r) {
    vec2 d = abs(p) - b + vec2(r);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - r;
}

void main() {
    float r = max(radius, 0.0);
    vec2 p = qt_TexCoord0 * vec2(uWidth, uHeight);
    vec2 center = vec2(uWidth * 0.5, uHeight * 0.5);
    vec2 halfSize = vec2(uWidth * 0.5, uHeight * 0.5);
    
    float d = sdRoundRect(p - center, halfSize, r);
    
    // Antialiased edge of the shape
    float alphaMask = 1.0 - smoothstep(-1.0, 1.0, d);
    if (alphaMask <= 0.0 || qt_Opacity <= 0.0 || baseColor.a <= 0.0) {
        fragColor = vec4(0.0);
        return;
    }

    vec4 color = baseColor;
    // Assume baseColor is passed as premultiplied RGBA from Qt

    // Inner highlight (Bevel effect)
    // -d represents the distance inside the shape. 0 at boundary, positive inside.
    // Edge profile is 1.0 at the very edge, fading to 0.0 at 2 pixels inside.
    float edgeProfile = smoothstep(2.0, 0.0, -d);
    
    // Simple directional lighting
    // Top-left light
    vec2 pNorm = (p - center) / max(halfSize, vec2(1.0)); // roughly -1 to 1
    // A soft faux normal pointing outwards from the center, bending more near edges
    vec3 normal = normalize(vec3(pNorm * pow(clamp(-d/halfSize.x, 0.0, 1.0), 0.5), 0.5));
    // light dir from top-left
    vec3 lightDir = normalize(vec3(-1.0, -1.0, 1.0));
    
    // We can also just use the SDF gradient for accurate normals at the edge:
    vec2 eps = vec2(1.0, 0.0);
    float dx = sdRoundRect(p - center + eps.xy, halfSize, r) - sdRoundRect(p - center - eps.xy, halfSize, r);
    float dy = sdRoundRect(p - center + eps.yx, halfSize, r) - sdRoundRect(p - center - eps.yx, halfSize, r);
    vec3 edgeNormal = normalize(vec3(dx, dy, 0.3));

    // highlight at the edge where the normal faces the light
    float highlight = edgeProfile * max(dot(edgeNormal, lightDir), 0.0);
    // shadow at the opposite edge
    float shadow = edgeProfile * max(dot(edgeNormal, -lightDir), 0.0);
    
    // Volumetric gradient (slightly lighter top-left, slightly darker bottom-right)
    float volGradient = dot(qt_TexCoord0 - vec2(0.5), vec2(-1.0, -1.0)); // range -0.7 to 0.7
    
    // Apply volumetric gradient softly, bounded by alpha to keep premultiplication valid
    color.rgb += vec3(volGradient * 0.1) * color.a;
    
    // Apply shiny edge highlight
    color.rgb += vec3(1.0) * highlight * 0.4 * color.a;
    
    // Apply darker edge shadow, kept softer
    color.rgb -= vec3(1.0) * shadow * 0.15 * color.a;

    // We output the mutated permultiplied color multiplied by our alpha mask and opacity
    fragColor = color * alphaMask * qt_Opacity;
}
