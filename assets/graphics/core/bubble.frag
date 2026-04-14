#include <flutter/runtime_effect.glsl>

// We'll support up to 3 bubbles
uniform vec2  uCenter0; uniform float uRadius0; uniform vec2 uDeform0; uniform float uPop0;
uniform vec2  uCenter1; uniform float uRadius1; uniform vec2 uDeform1; uniform float uPop1;
uniform vec2  uCenter2; uniform float uRadius2; uniform vec2 uDeform2; uniform float uPop2;

uniform float uTime;          
uniform vec2  uResolution;    
uniform sampler2D uTexture;   

out vec4 fragColor;

vec4 calculateBubble(vec2 fragCoord, vec2 center, float radius, vec2 deform, float pop, vec4 currentBg) {
    if (pop >= 1.0) return currentBg;

    vec2  rawUv       = fragCoord - center;
    float speed       = length(deform);
    vec2  moveDir     = speed > 0.001 ? deform / speed : vec2(0.0, 1.0);
    float paraLen     = dot(rawUv, moveDir);
    vec2  perpVec     = rawUv - moveDir * paraLen;
    float stretch     = 1.0 + speed;
    float squash      = 1.0 / sqrt(stretch);
    vec2  deformedUv  = moveDir * (paraLen / stretch) + perpVec * squash;

    float dist        = length(deformedUv);
    float activeR     = radius * (1.0 + pop * 1.5);

    if (dist < activeR) {
        vec2  nUv    = deformedUv / activeR;
        float distSq = dot(nUv, nUv);
        float z      = sqrt(max(0.0, 1.0 - distSq));
        float NdotV  = max(0.0, z);

        // Refraction
        float lensDeform = (1.0 - z) * 0.85 * (1.0 - pop);
        vec2 refR = (fragCoord - nUv * activeR * lensDeform * 0.82) / uResolution;
        vec2 refG = (fragCoord - nUv * activeR * lensDeform * 1.00) / uResolution;
        vec2 refB = (fragCoord - nUv * activeR * lensDeform * 1.18) / uResolution;
        
        refR = clamp(refR, 0.001, 0.999);
        refG = clamp(refG, 0.001, 0.999);
        refB = clamp(refB, 0.001, 0.999);

        vec3 scene = vec3(
            texture(uTexture, refR).r,
            texture(uTexture, refG).g,
            texture(uTexture, refB).b
        );

        // Thin-Film
        float n_film = 1.33;
        float R0 = 0.08; 
        float fresnel = R0 + (1.0 - R0) * pow(1.0 - NdotV, 4.0); 
        float cosTI = sqrt(max(0.0, 1.0 - (1.0 - NdotV * NdotV) / (n_film * n_film)));
        float opd = 2.0 * n_film * (350.0 + nUv.y * 150.0 + sin(uTime * 0.5) * 50.0) * cosTI;
        
        vec3 interference = 0.5 + 0.5 * cos(6.28318 * opd / vec3(650.0, 532.0, 450.0));
        vec3 filmColor = mix(vec3(fresnel * 0.5), interference * fresnel * 2.5, smoothstep(0.0, 0.25, NdotV));

        // Specular
        vec3 normal = normalize(vec3(nUv, z));
        vec3 reflDir = reflect(vec3(0.0, 0.0, -1.0), normal);
        float spec1 = pow(max(0.0, dot(reflDir, normalize(vec3(0.6, 0.7, 0.8)))), 250.0) * 3.5;
        float spec2 = pow(max(0.0, dot(reflDir, normalize(vec3(-0.5, -0.4, 0.6)))), 40.0) * 1.5;
        
        vec3 col = scene * (1.0 - fresnel * 0.6) + filmColor * 1.2 + (spec1 + spec2) * 1.3;
        return vec4(col, 1.0 - pow(pop, 0.5));
    }
    return currentBg;
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uvNorm    = fragCoord / uResolution;
    vec4 bg        = texture(uTexture, uvNorm);

    vec4 color = bg;
    
    // Sequence through bubbles (if they overlap, the last one wins in the simple logic)
    // For refraction to work correctly between bubbles, this would be much more complex.
    // For 2-3 small random bubbles, sequential is fine.
    color = calculateBubble(fragCoord, uCenter0, uRadius0, uDeform0, uPop0, color);
    color = calculateBubble(fragCoord, uCenter1, uRadius1, uDeform1, uPop1, color);
    color = calculateBubble(fragCoord, uCenter2, uRadius2, uDeform2, uPop2, color);

    fragColor = color;
}
