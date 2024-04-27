// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "UFOBeam"
{
	Properties
	{
		_ColorTint("ColorTint", Color) = (0,0.9802117,1,0)
		_ScaleX("ScaleX", Float) = 0
		_ScaleY("ScaleY", Float) = 0
		_LerpingVal("LerpingVal", Float) = 0.98
		_GradientScale("GradientScale", Float) = 0.24
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha noshadow exclude_path:deferred 
		struct Input
		{
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _ColorTint;
		uniform float _ScaleX;
		uniform float _LerpingVal;
		uniform float _ScaleY;
		uniform float _GradientScale;


		float2 voronoihash13( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi13( float2 v, float time, inout float2 id, float smoothness )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mr = 0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash13( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = g - f + o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			 		}
			 	}
			}
			return F1;
		}


		float2 voronoihash25( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi25( float2 v, float time, inout float2 id, float smoothness )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mr = 0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash25( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = g - f + o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			 		}
			 	}
			}
			return F1;
		}


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float mulTime16 = _Time.y * 0.3;
			float time13 = mulTime16;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float2 temp_cast_1 = (( ase_vertex3Pos.y + mulTime16 )).xx;
			float2 coords13 = temp_cast_1 * _ScaleX;
			float2 id13 = 0;
			float voroi13 = voronoi13( coords13, time13,id13, 0 );
			float mulTime22 = _Time.y * -0.3;
			float time25 = mulTime22;
			float2 temp_cast_2 = (( ase_vertex3Pos.y + mulTime22 )).xx;
			float2 coords25 = temp_cast_2 * _ScaleY;
			float2 id25 = 0;
			float voroi25 = voronoi25( coords25, time25,id25, 0 );
			float lerpResult26 = lerp( voroi13 , _LerpingVal , voroi25);
			float4 color32 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
			float4 color33 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			float4 lerpResult43 = lerp( ( color32 + color33 + ase_vertex3Pos.y ) , color32 , _GradientScale);
			c.rgb = 0;
			c.a = ( lerpResult26 * lerpResult43 ).r;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Emission = _ColorTint.rgb;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
401;477;1195;598;2742.363;781.4389;1.66789;True;False
Node;AmplifyShaderEditor.PosVertexDataNode;21;-2171.482,333.2375;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;10;-2151.934,-446.6078;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;16;-2096.344,-163.8658;Inherit;False;1;0;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;22;-2130.114,630.202;Inherit;False;1;0;FLOAT;-0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1944.615,52.94979;Inherit;False;Property;_ScaleX;ScaleX;1;0;Create;True;0;0;False;0;0;3.74;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-1880.964,-446.1775;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;33;-1316.782,883.9329;Inherit;False;Constant;_Color1;Color 1;5;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;23;-1926.809,743.3022;Inherit;False;Property;_ScaleY;ScaleY;2;0;Create;True;0;0;False;0;0;3.92;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;29;-1329.977,1136.526;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-1916.83,311.4235;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;32;-1334.416,702.8243;Inherit;False;Constant;_Color0;Color 0;5;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VoronoiNode;13;-1610.102,-91.52467;Inherit;True;0;0;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.RangedFloatNode;27;-1479.612,257.3947;Inherit;False;Property;_LerpingVal;LerpingVal;3;0;Create;True;0;0;False;0;0.98;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;25;-1579.391,413.2185;Inherit;True;0;0;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-1069.502,773.9905;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-936.8632,1094.197;Inherit;False;Property;_GradientScale;GradientScale;4;0;Create;True;0;0;False;0;0.24;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;43;-779.2112,605.7662;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;26;-1044.088,124.6736;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-0.02;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-502.058,256.9326;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;1;-631.433,-105.3494;Inherit;False;Property;_ColorTint;ColorTint;0;0;Create;True;0;0;False;0;0,0.9802117,1,0;0,0.9802117,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;UFOBeam;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;11;0;10;2
WireConnection;11;1;16;0
WireConnection;24;0;21;2
WireConnection;24;1;22;0
WireConnection;13;0;11;0
WireConnection;13;1;16;0
WireConnection;13;2;15;0
WireConnection;25;0;24;0
WireConnection;25;1;22;0
WireConnection;25;2;23;0
WireConnection;42;0;32;0
WireConnection;42;1;33;0
WireConnection;42;2;29;2
WireConnection;43;0;42;0
WireConnection;43;1;32;0
WireConnection;43;2;35;0
WireConnection;26;0;13;0
WireConnection;26;1;27;0
WireConnection;26;2;25;0
WireConnection;44;0;26;0
WireConnection;44;1;43;0
WireConnection;0;2;1;0
WireConnection;0;9;44;0
ASEEND*/
//CHKSM=3EC25542DD51D504FEE0F3674DE9024CACBC84F8