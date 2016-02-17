#version 120

#if @diffuseMap
uniform sampler2D diffuseMap;
varying vec2 diffuseMapUV;
#endif

#if @darkMap
uniform sampler2D darkMap;
varying vec2 darkMapUV;
#endif

#if @detailMap
uniform sampler2D detailMap;
varying vec2 detailMapUV;
#endif

#if @emissiveMap
uniform sampler2D emissiveMap;
varying vec2 emissiveMapUV;
#endif

#if @normalMap
uniform sampler2D normalMap;
varying vec2 normalMapUV;
varying vec3 viewTangent;
#endif

varying float depth;

#define PER_PIXEL_LIGHTING @normalMap

#if !PER_PIXEL_LIGHTING
varying vec4 lighting;
#else
varying vec3 passViewPos;
varying vec3 passViewNormal;
varying vec4 passColour;
#endif

#include "lighting.glsl"

void main()
{
#if @diffuseMap
    gl_FragData[0] = texture2D(diffuseMap, diffuseMapUV);
#else
    gl_FragData[0] = vec4(1.0, 1.0, 1.0, 1.0);
#endif

#if @detailMap
    gl_FragData[0].xyz *= texture2D(detailMap, detailMapUV).xyz * 2.0;
#endif

#if @darkMap
    gl_FragData[0].xyz *= texture2D(darkMap, darkMapUV).xyz;
#endif

#if @normalMap
    vec3 viewNormal = passViewNormal;
    vec3 normalTex = texture2D(normalMap, normalMapUV).xyz;

    vec3 viewBinormal = cross(viewTangent, viewNormal);
    mat3 tbn = mat3(viewTangent, viewBinormal, viewNormal);

    viewNormal = normalize(tbn * (normalTex * 2.0 - 1.0));
#endif


#if !PER_PIXEL_LIGHTING
    gl_FragData[0] *= lighting;
#else
    gl_FragData[0] *= doLighting(passViewPos, normalize(viewNormal), passColour);
#endif

#if @emissiveMap
    gl_FragData[0].xyz += texture2D(emissiveMap, emissiveMapUV).xyz;
#endif

    float fogValue = clamp((depth - gl_Fog.start) * gl_Fog.scale, 0.0, 1.0);
    gl_FragData[0].xyz = mix(gl_FragData[0].xyz, gl_Fog.color.xyz, fogValue);
}
