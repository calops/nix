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
    // Multi-shape properties (optional)
    vec4 rect1;
    vec4 rect2;
    vec4 rect3;
    float radius1;
    float radius2;
    float radius3;
    float smoothness;
    float useImage;
    float recessed;
};

layout(binding = 1) uniform sampler2D imageSource;

float sdRoundRect(vec2 p, vec2 b, float r) {
    vec2 d = abs(p) - b + vec2(r);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - r;
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

float getDistance(vec2 pos, float r, vec2 center, vec2 halfSize, vec4 r1, vec4 r2, vec4 r3, float rad1, float rad2, float rad3, float sm) {
    if (r1.z > 0.0) {
        vec2 c1 = r1.xy + r1.zw * 0.5;
        vec2 hs1 = r1.zw * 0.5;
        float d = sdRoundRect(pos - c1, hs1, rad1);
        if (r2.z > 0.0) {
            vec2 c2 = r2.xy + r2.zw * 0.5;
            vec2 hs2 = r2.zw * 0.5;
            float d2 = sdRoundRect(pos - c2, hs2, rad2);
            d = smin(d, d2, sm);
            vec2 min12 = min(r1.xy, r2.xy);
            vec2 max12 = max(r1.xy + r1.zw, r2.xy + r2.zw);
            vec2 c12 = (min12 + max12) * 0.5;
            vec2 h12 = (max12 - min12) * 0.5;
            float dbb12 = sdRoundRect(pos - c12, h12, 0.0);
            d = max(d, dbb12);
            if (r3.z > 0.0) {
                vec2 c3 = r3.xy + r3.zw * 0.5;
                vec2 hs3 = r3.zw * 0.5;
                float d3 = sdRoundRect(pos - c3, hs3, rad3);
                d = smin(d, d3, sm);
                vec2 min123 = min(min12, r3.xy);
                vec2 max123 = max(max12, r3.xy + r3.zw);
                vec2 c123 = (min123 + max123) * 0.5;
                vec2 h123 = (max123 - min123) * 0.5;
                float dbb123 = sdRoundRect(pos - c123, h123, 0.0);
                d = max(d, dbb123);
            }
        }
        return d;
    } else {
        return sdRoundRect(pos - center, halfSize, r);
    }
}

void main() {
    vec2 p = qt_TexCoord0 * vec2(uWidth, uHeight);
    vec2 center = vec2(uWidth * 0.5, uHeight * 0.5);
    vec2 halfSize = vec2(uWidth * 0.5, uHeight * 0.5);
    float r = max(radius, 0.0);

    float d = getDistance(p, r, center, halfSize, rect1, rect2, rect3, radius1, radius2, radius3, smoothness);
    
    // Antialiased edge of the shape
    float alphaMask = 1.0 - smoothstep(-1.0, 1.0, d);
    if (alphaMask <= 0.0 || qt_Opacity <= 0.0 || baseColor.a <= 0.0) {
        fragColor = vec4(0.0);
        return;
    }

    vec4 color = baseColor;
    if (useImage > 0.5) {
        vec4 imgColor = texture(imageSource, qt_TexCoord0);
        // Blend image RGB with base color RGB using image alpha as weight,
        // but strictly preserve the base color's alpha for transparency.
        color.rgb = mix(color.rgb, imgColor.rgb, imgColor.a);
        // We do NOT change color.a here to keep the glassy transparency
    }

    // --- Glass Lighting Effect ---
    
    // Inner profile for highlights (fades inside the shape)
    float edgeProfile = smoothstep(2.0, 0.0, -d);
    
    // Calculate normals via SDF gradient for perfect accuracy
    vec2 eps = vec2(0.5, 0.0);
    float dx = getDistance(p + eps.xy, r, center, halfSize, rect1, rect2, rect3, radius1, radius2, radius3, smoothness) - 
               getDistance(p - eps.xy, r, center, halfSize, rect1, rect2, rect3, radius1, radius2, radius3, smoothness);
    float dy = getDistance(p + eps.yx, r, center, halfSize, rect1, rect2, rect3, radius1, radius2, radius3, smoothness) - 
               getDistance(p - eps.yx, r, center, halfSize, rect1, rect2, rect3, radius1, radius2, radius3, smoothness);
    vec3 edgeNormal = normalize(vec3(dx, dy, 0.3));

    // Light dir from top-left
    vec3 lightDir = normalize(vec3(-1.0, -1.0, 1.0));
    
    // Invert normal for recessed (pressed-in) appearance
    vec3 effectiveNormal = recessed > 0.5 ? -edgeNormal : edgeNormal;

    // High-quality directional highlights/shadows
    float highlight = edgeProfile * max(dot(effectiveNormal, lightDir), 0.0);
    float shadow = edgeProfile * max(dot(effectiveNormal, -lightDir), 0.0);
    
    // Volumetric gradient (global across the whole coord space)
    float volGradient = dot(qt_TexCoord0 - vec2(0.5), vec2(-1.0, -1.0));
    
    // Apply effects at constant strength — independent of baseColor.a so the glass
    // always looks equally "deep" regardless of the tint alpha.
    // Constants are calibrated so a backdrop at baseColor.a ≈ 0.65 looks the same
    // as the previous shader (old_constant × 0.65).
    color.rgb += vec3(volGradient * 0.065);
    color.rgb += vec3(1.0) * highlight * 0.22;
    color.rgb -= vec3(1.0) * shadow * 0.10;

    // Final output
    fragColor = color * alphaMask * qt_Opacity;
}


