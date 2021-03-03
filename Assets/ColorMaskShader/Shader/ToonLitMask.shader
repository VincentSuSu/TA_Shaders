Shader "Toon/Lit ColorMask" {
	Properties {
		_Color ("Main Color", Color) = (0.5,0.5,0.5,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
	_Mask("ColorMask (Red = Prim Green = Sec Blue = Ter)", 2D) = "white" {} // mask texture
		_Ramp ("Toon Ramp (RGB)", 2D) = "gray" {} 
		_ColorPrim("Primary Color", Color) = (0.5,0.5,0.5,1) // primary color, replaces the red masked area
			[Toggle] _Emis1("Primary: Emissive?", Float) = 0 // sets the color as emissive if toggled
			_Value1("Primary: Blend Main Texture", Range(0,1)) = 0.5 // blend value with the original texture
			_ColorSec("Secondary Color", Color) = (0.5,0.5,0.5,1) // secondary color, replaces green masked area
			[Toggle] _Emis2("Secondary: Emissive?", Float) = 0// sets the color as emissive if toggled
			_Value2("Secondary: Blend Main Texture", Range(0,1)) = 0.5// blend value with the original texture
			_ColorTert("Tertiary Color", Color) = (0.5,0.5,0.5,1)// tertiary color, replaces blue masked area
			[Toggle] _Emis3("Tertiary: Emissive?", Float) = 0// sets the color as emissive if toggled
			_Value3("Tertiary: Blend Main Texture", Range(0,1)) = 0.5// blend value with the original texture
		
	}

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		
CGPROGRAM
#pragma surface surf ToonRamp

sampler2D _Ramp;

// custom lighting function that uses a texture ramp based
// on angle between light direction and normal
#pragma lighting ToonRamp exclude_path:prepass
inline half4 LightingToonRamp (SurfaceOutput s, half3 lightDir, half atten)
{
	#ifndef USING_DIRECTIONAL_LIGHT
	lightDir = normalize(lightDir);
	#endif
	
	half d = dot (s.Normal, lightDir)*0.5 + 0.5;
	half3 ramp = tex2D (_Ramp, float2(d,d)).rgb;
	
	half4 c;
	c.rgb = s.Albedo * _LightColor0.rgb * ramp * (atten * 2);
	c.a = 0;
	return c;
}


sampler2D _MainTex;
sampler2D _Mask; // mask texture
float4 _Color, _ColorPrim, _ColorSec, _ColorTert;// custom colors
float _Emis1, _Emis2, _Emis3; // emission toggles
float _Value1, _Value2, _Value3;// original texture blend values

struct Input {
	float2 uv_MainTex : TEXCOORD0;
};

void surf (Input IN, inout SurfaceOutput o) {
	half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	half4 m = tex2D(_Mask, IN.uv_MainTex); // mask based on the uvs
	float3 PrimaryColor = _ColorPrim * m.r + ((c.rgb * _Value1) * m.r); // the 3 custom colours multiplied by the mask , so it only affects the masked areas,
	float3 SecondaryColor = _ColorSec * m.g + ((c.rgb * _Value2) * m.g); // also multiplied by the original texture based on a blend value slider
	float3 TertiaryColor = _ColorTert * m.b + ((c.rgb * _Value3) * m.b);
	float3 NonMasked = c.rgb * (1 - m.r - m.g - m.b); // the part of the model thats not affected by the colour customisation

	o.Albedo = NonMasked  + PrimaryColor + SecondaryColor + TertiaryColor; // all parts added together form the new look for the model
	o.Emission = PrimaryColor * _Emis1 + SecondaryColor * _Emis2 + TertiaryColor * _Emis3; // emissive only shows up when the toggles for their colours are toggled
	o.Alpha = c.a;
}
ENDCG

	} 

	Fallback "Diffuse"
}
