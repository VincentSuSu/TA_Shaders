Shader "Unlit/UnlitColorMask"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	_Mask("ColorMask (Red = Prim Green = Sec Blue = Ter)", 2D) = "white" {} // mask texture
	_ColorPrim("Primary Color", Color) = (0.5,0.5,0.5,1) // primary color, replaces the red masked area
		_Value1("Primary: Blend Main Texture", Range(0,1)) = 0.5 // blend value with the original texture
		_ColorSec("Secondary Color", Color) = (0.5,0.5,0.5,1) // secondary color, replaces green masked area
		_Value2("Secondary: Blend Main Texture", Range(0,1)) = 0.5// blend value with the original texture
		_ColorTert("Tertiary Color", Color) = (0.5,0.5,0.5,1)// tertiary color, replaces blue masked area
		_Value3("Tertiary: Blend Main Texture", Range(0,1)) = 0.5// blend value with the original texture
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex, _Mask;
			float4 _MainTex_ST;
			float4 _ColorPrim, _ColorSec, _ColorTert;
			float _Value1, _Value2, _Value3;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 c = tex2D(_MainTex, i.uv);
				fixed4 m = tex2D(_Mask, i.uv);
				// apply fog
				float4 PrimaryColor = _ColorPrim * m.r + ((c * _Value1) * m.r); // the 3 custom colours multiplied by the mask , so it only affects the masked areas,
				float4 SecondaryColor = _ColorSec * m.g + ((c * _Value2) * m.g); // also multiplied by the original texture based on a blend value slider
				float4 TertiaryColor = _ColorTert * m.b + ((c * _Value3) * m.b);
				float4 NonMasked = c * (1 - m.r - m.g - m.b); // the part of the model thats not affected by the colour customisation

				 
				float4 col = NonMasked + PrimaryColor + SecondaryColor + TertiaryColor; // all parts added together form the new look for the model
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
