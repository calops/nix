#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 rect1;
    vec4 rect2;
    vec4 rect3;
    float radius1;
    float radius2;
    float radius3;
    float smoothness;
    vec4 bubbleColor;
    float uWidth;
    float uHeight;
};

float sdRoundRect(vec2 p, vec2 b, float r) {
    vec2 d = abs(p) - b + vec2(r);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - r;
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

void main() {
    vec2 p = qt_TexCoord0 * vec2(uWidth, uHeight);

    // Rect 1 (Icon)
    vec2 center1 = rect1.xy + rect1.zw * 0.5;
    vec2 halfSize1 = rect1.zw * 0.5;
    float d1 = sdRoundRect(p - center1, halfSize1, radius1);

    float d = d1;

    // Rect 2 (Menu)
    if (rect2.z > 0.0) {
        vec2 center2 = rect2.xy + rect2.zw * 0.5;
        vec2 halfSize2 = rect2.zw * 0.5;
        float d2 = sdRoundRect(p - center2, halfSize2, radius2);
        d = smin(d, d2, smoothness);

        vec2 min12 = min(rect1.xy, rect2.xy);
        vec2 max12 = max(rect1.xy + rect1.zw, rect2.xy + rect2.zw);
        vec2 center12 = (min12 + max12) * 0.5;
        vec2 half12 = (max12 - min12) * 0.5;
        float dbb12 = sdRoundRect(p - center12, half12, 0.0);
        d = max(d, dbb12);

        // Rect 3 (Sub-Menu)
        if (rect3.z > 0.0) {
            vec2 center3 = rect3.xy + rect3.zw * 0.5;
            vec2 halfSize3 = rect3.zw * 0.5;
            float d3 = sdRoundRect(p - center3, halfSize3, radius3);
            d = smin(d, d3, smoothness);
            
            vec2 min123 = min(min12, rect3.xy);
            vec2 max123 = max(max12, rect3.xy + rect3.zw);
            vec2 center123 = (min123 + max123) * 0.5;
            vec2 half123 = (max123 - min123) * 0.5;
            float dbb123 = sdRoundRect(p - center123, half123, 0.0);
            d = max(d, dbb123);
        }
    }

    float alpha = 1.0 - smoothstep(-1.0, 1.0, d);
    // Subtle shadow
    float shadow = 1.0 - smoothstep(-5.0, 10.0, d);
    vec4 color = mix(vec4(0.0, 0.0, 0.0, 0.1) * shadow, bubbleColor, alpha);

    fragColor = color * alpha * qt_Opacity;
}
