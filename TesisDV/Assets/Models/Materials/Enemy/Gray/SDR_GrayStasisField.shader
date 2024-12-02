// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SDR_GrayStasisField"
{
	Properties
	{
		_ColorTint("ColorTint", Color) = (0,0.9802117,1,0)
		_Scale("Scale", Range( 0 , 1)) = 1
		_ScaleX("ScaleX", Float) = 0
		_Power("Power", Float) = 8.39
		_ScaleY("ScaleY", Float) = 0
		_Bias("Bias", Range( 0 , 1)) = 1
		_LerpingVal("LerpingVal", Float) = 0.98
		_GradientScale("GradientScale", Float) = 0.24
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha noshadow exclude_path:deferred 
		struct Input
		{
			float3 worldPos;
			float3 viewDir;
			float3 worldNormal;
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
		uniform float _Bias;
		uniform float _Scale;
		uniform float _Power;


		float2 voronoihash12( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi12( float2 v, float time, inout float2 id, float smoothness )
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
			 		float2 o = voronoihash12( n + g );
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


		float2 voronoihash14( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi14( float2 v, float time, inout float2 id, float smoothness )
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
			 		float2 o = voronoihash14( n + g );
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
			float mulTime3 = _Time.y * 0.3;
			float time12 = mulTime3;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float2 temp_cast_1 = (( ase_vertex3Pos.y + mulTime3 )).xx;
			float2 coords12 = temp_cast_1 * _ScaleX;
			float2 id12 = 0;
			float voroi12 = voronoi12( coords12, time12,id12, 0 );
			float mulTime4 = _Time.y * -0.3;
			float time14 = mulTime4;
			float2 temp_cast_2 = (( ase_vertex3Pos.y + mulTime4 )).xx;
			float2 coords14 = temp_cast_2 * _ScaleY;
			float2 id14 = 0;
			float voroi14 = voronoi14( coords14, time14,id14, 0 );
			float lerpResult18 = lerp( voroi12 , _LerpingVal , voroi14);
			float4 color7 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
			float4 color8 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			float4 lerpResult17 = lerp( ( color7 + color8 + ase_vertex3Pos.y ) , color7 , _GradientScale);
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV25 = dot( ase_worldNormal, i.viewDir );
			float fresnelNode25 = ( _Bias + _Scale * pow( 1.0 - fresnelNdotV25, _Power ) );
			c.rgb = 0;
			c.a = ( ( lerpResult18 * lerpResult17 ) * fresnelNode25 ).r;
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
686;685;1195;500;737.4617;408.6303;1.371506;True;False
Node;AmplifyShaderEditor.PosVertexDataNode;1;-2023.628,-22.74203;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;2;-2004.08,-802.5873;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;3;-1948.49,-519.8453;Inherit;False;1;0;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;4;-1982.26,274.2225;Inherit;False;1;0;FLOAT;-0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1796.761,-303.0297;Inherit;False;Property;_ScaleX;ScaleX;2;0;Create;True;0;0;False;0;0;3.74;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-1733.11,-802.157;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1778.955,387.3227;Inherit;False;Property;_ScaleY;ScaleY;4;0;Create;True;0;0;False;0;0;13.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;7;-1186.562,346.8448;Inherit;False;Constant;_Color0;Color 0;5;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;9;-1182.123,780.5465;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-1768.976,-44.55603;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;8;-1168.928,527.9534;Inherit;False;Constant;_Color1;Color 1;5;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-921.6479,418.011;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.VoronoiNode;12;-1462.248,-447.5042;Inherit;True;0;0;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.RangedFloatNode;13;-1331.758,-98.58481;Inherit;False;Property;_LerpingVal;LerpingVal;6;0;Create;True;0;0;False;0;0.98;4.06;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-789.0092,738.2175;Inherit;False;Property;_GradientScale;GradientScale;7;0;Create;True;0;0;False;0;0.24;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;14;-1431.537,57.23898;Inherit;True;0;0;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.LerpOp;17;-631.3572,249.7867;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;18;-896.234,-231.3059;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-0.02;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-1102.41,-990.5991;Inherit;False;Property;_Power;Power;3;0;Create;True;0;0;False;0;8.39;1.29;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;22;-1217.047,-1430.206;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;23;-1324.324,-1136.416;Inherit;False;Property;_Scale;Scale;1;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1369.748,-1255.678;Inherit;False;Property;_Bias;Bias;5;0;Create;True;0;0;False;0;1;0.2626204;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;25;-437.4965,-917.19;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;2;False;2;FLOAT;2.75;False;3;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-354.204,-99.04694;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;19;-483.579,-461.3289;Inherit;False;Property;_ColorTint;ColorTint;0;0;Create;True;0;0;False;0;0,0.9802117,1,0;0,0.9802117,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;36.59596,-263.9973;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;419.9641,-479.1744;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;SDR_GrayStasisField;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;5;True;False;0;False;Transparent;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;2;2
WireConnection;6;1;3;0
WireConnection;10;0;1;2
WireConnection;10;1;4;0
WireConnection;15;0;7;0
WireConnection;15;1;8;0
WireConnection;15;2;9;2
WireConnection;12;0;6;0
WireConnection;12;1;3;0
WireConnection;12;2;5;0
WireConnection;14;0;10;0
WireConnection;14;1;4;0
WireConnection;14;2;11;0
WireConnection;17;0;15;0
WireConnection;17;1;7;0
WireConnection;17;2;16;0
WireConnection;18;0;12;0
WireConnection;18;1;13;0
WireConnection;18;2;14;0
WireConnection;25;4;22;0
WireConnection;25;1;24;0
WireConnection;25;2;23;0
WireConnection;25;3;21;0
WireConnection;20;0;18;0
WireConnection;20;1;17;0
WireConnection;27;0;20;0
WireConnection;27;1;25;0
WireConnection;0;2;19;0
WireConnection;0;9;27;0
ASEEND*/
//CHKSM=2ECCDC3D38F4878E8EE229D572041590506FCB91