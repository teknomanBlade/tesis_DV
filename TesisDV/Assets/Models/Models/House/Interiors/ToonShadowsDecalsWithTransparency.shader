// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ToonShadowsDecalsWithTransparency"
{
	Properties
	{
		_MainTexture("Main Texture", 2D) = "white" {}
		_SecondExperimentColumn("SecondExperimentColumn", Float) = 0
		_FirstPosition("FirstPosition", Float) = 0
		_FourthFifthExperimentRow("FourthFifthExperimentRow", Float) = 0
		_FirstExperimentColumn("FirstExperimentColumn", Float) = 0
		_Min("Min", Float) = 0
		_Max("Max", Float) = 0
		_SecondPosition("SecondPosition", Float) = 0
		_SecondPositionIntensity("SecondPositionIntensity", Float) = 0
		_ShadowIntensity("ShadowIntensity", Float) = 0
		_Color_Decals("Color_Decals", Color) = (0,0,0,0)
		_ColorTint("ColorTint", Color) = (0,0,0,0)
		_OutlineWidth("OutlineWidth", Float) = 0
		_OutlineAlpha("OutlineAlpha", Range( 0 , 2)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0"}
		Cull Off
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog alpha:fade  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float outlineVar = _OutlineWidth;
			v.vertex.xyz += ( v.normal * outlineVar );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Emission = _ColorTint.rgb;
			o.Alpha = _OutlineAlpha;
		}
		ENDCG
		

		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
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

		uniform float _SecondExperimentColumn;
		uniform float _FirstExperimentColumn;
		uniform float _FourthFifthExperimentRow;
		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform float4 _Color_Decals;
		uniform float _Min;
		uniform float _Max;
		uniform float _FirstPosition;
		uniform float _SecondPosition;
		uniform float _SecondPositionIntensity;
		uniform float _ShadowIntensity;
		uniform float _OutlineWidth;
		uniform float4 _ColorTint;
		uniform float _OutlineAlpha;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += 0;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float smoothstepResult233 = smoothstep( min( _SecondExperimentColumn , _SecondExperimentColumn ) , max( _SecondExperimentColumn , _SecondExperimentColumn ) , ( 1.0 - i.uv_texcoord.x ));
			float4 temp_cast_0 = (smoothstepResult233).xxxx;
			float div240=256.0/float(256);
			float4 posterize240 = ( floor( temp_cast_0 * div240 ) / div240 );
			float smoothstepResult221 = smoothstep( min( _FirstExperimentColumn , _FirstExperimentColumn ) , max( _FirstExperimentColumn , _FirstExperimentColumn ) , i.uv_texcoord.y);
			float4 temp_cast_1 = (smoothstepResult221).xxxx;
			float div239=256.0/float(200);
			float4 posterize239 = ( floor( temp_cast_1 * div239 ) / div239 );
			float smoothstepResult246 = smoothstep( min( _FourthFifthExperimentRow , _FourthFifthExperimentRow ) , max( _FourthFifthExperimentRow , _FourthFifthExperimentRow ) , i.uv_texcoord.y);
			float4 temp_cast_2 = (smoothstepResult246).xxxx;
			float div247=256.0/float(200);
			float4 posterize247 = ( floor( temp_cast_2 * div247 ) / div247 );
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float4 tex2DNode45 = tex2D( _MainTexture, uv_MainTexture );
			float4 lerpResult238 = lerp( float4( 0,0,0,0 ) , ( ( saturate( posterize240 ) * saturate( posterize239 ) ) + saturate( posterize247 ) ) , tex2DNode45.a);
			float temp_output_64_0 = min( _Min , _Max );
			float temp_output_65_0 = max( _Max , _Min );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldNormal = i.worldNormal;
			float dotResult56 = dot( ase_worldlightDir , ase_worldNormal );
			float temp_output_58_0 = ( ( dotResult56 + 1.0 ) * 0.5 );
			float smoothstepResult61 = smoothstep( temp_output_64_0 , temp_output_65_0 , ( temp_output_58_0 - _FirstPosition ));
			float smoothstepResult68 = smoothstep( temp_output_64_0 , temp_output_65_0 , ( temp_output_58_0 - _SecondPosition ));
			float temp_output_74_0 = ( saturate( smoothstepResult61 ) + saturate( ( smoothstepResult68 - _SecondPositionIntensity ) ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			c.rgb = saturate( ( ( tex2DNode45 * _Color_Decals ) * ( ( temp_output_74_0 + ( ( 1.0 - temp_output_74_0 ) * _ShadowIntensity ) ) * ase_lightColor ) ) ).rgb;
			c.a = lerpResult238.r;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
263;555;1195;586;-1303.849;990.8597;1.19531;True;False
Node;AmplifyShaderEditor.WorldNormalVector;55;-2624,-400;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;54;-2624,-576;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;56;-2336,-496;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;-2128,-464;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2032,-176;Inherit;False;Property;_Min;Min;5;0;Create;True;0;0;False;0;0;1.89;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-1936,-512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-1568,-176;Inherit;False;Property;_SecondPosition;SecondPosition;7;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-2032,-48;Inherit;False;Property;_Max;Max;6;0;Create;True;0;0;False;0;0;1.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;65;-1760,-48;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-1872,-336;Inherit;False;Property;_FirstPosition;FirstPosition;2;0;Create;True;0;0;False;0;0;1.22;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;64;-1760,-176;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;67;-1360,-240;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;68;-1200,-224;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-1184,32;Inherit;False;Property;_SecondPositionIntensity;SecondPositionIntensity;8;0;Create;True;0;0;False;0;0;2.22;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;59;-1712,-464;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;61;-1216,-528;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;70;-912,-224;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;228;248.9396,698.7893;Inherit;False;Property;_SecondExperimentColumn;SecondExperimentColumn;1;0;Create;True;0;0;False;0;0;0.65;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;69;-704,-432;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;226;308.847,416.8619;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;73;-704,-176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;217;255.6036,1278.811;Inherit;False;Property;_FirstExperimentColumn;FirstExperimentColumn;4;0;Create;True;0;0;False;0;0;0.37;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;231;630.1028,402.3269;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;229;656.5693,601.347;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;219;638.515,1178.89;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;242;555.9238,1845.663;Inherit;False;Property;_FourthFifthExperimentRow;FourthFifthExperimentRow;3;0;Create;True;0;0;False;0;0;0.54;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;218;652.497,1335.794;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;230;669.0164,725.688;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;74;-512,-352;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;215;325.096,981.7426;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;221;863.4961,1063.149;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;243;531.8961,1530.635;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMinOpNode;245;877.2664,1759.735;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-240,80;Inherit;False;Property;_ShadowIntensity;ShadowIntensity;9;0;Create;True;0;0;False;0;0;1.68;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;244;883.2604,1880.693;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;233;885.7397,442.0885;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;75;-208,-176;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;48,-80;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;246;1066.301,1616.036;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosterizeNode;239;1168.487,1028.269;Inherit;True;200;2;1;COLOR;0,0,0,0;False;0;INT;200;False;1;COLOR;0
Node;AmplifyShaderEditor.PosterizeNode;240;1166.877,470.5142;Inherit;True;256;2;1;COLOR;0,0,0,0;False;0;INT;256;False;1;COLOR;0
Node;AmplifyShaderEditor.PosterizeNode;247;1343.335,1545.21;Inherit;True;200;2;1;COLOR;0,0,0,0;False;0;INT;200;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;224;1504.303,1059.111;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;45;55.36771,-1224.442;Inherit;True;Property;_MainTexture;Main Texture;0;0;Create;True;0;0;False;0;-1;None;112c18993e8d8e042b6083c1dd5c45d9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;80;128,192;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SaturateNode;235;1476.594,481.4;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;240,-320;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;83;303.6369,-948.8177;Inherit;False;Property;_Color_Decals;Color_Decals;10;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;702.3867,-1035.302;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;592.3793,-424.2421;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;237;1805.357,724.0733;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;248;1681.446,1438.208;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;250;1782.884,-709.503;Inherit;False;Property;_OutlineWidth;OutlineWidth;12;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;251;1782.183,-1096.808;Inherit;False;Property;_ColorTint;ColorTint;11;0;Create;True;0;0;False;0;0,0,0,0;0.167352,1,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;249;2129.526,730.5776;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;1255.429,-764.0844;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;253;1736.182,-847.1005;Inherit;False;Property;_OutlineAlpha;OutlineAlpha;13;0;Create;True;0;0;False;0;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;238;2319.203,-130.817;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OutlineNode;252;2169.382,-916.5258;Inherit;False;0;True;Transparent;0;0;Off;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;50;1566.141,-547.5917;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2732.427,-686.5903;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;ToonShadowsDecalsWithTransparency;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-0.2;0.3835547,1,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;56;0;54;0
WireConnection;56;1;55;0
WireConnection;57;0;56;0
WireConnection;58;0;57;0
WireConnection;65;0;63;0
WireConnection;65;1;62;0
WireConnection;64;0;62;0
WireConnection;64;1;63;0
WireConnection;67;0;58;0
WireConnection;67;1;66;0
WireConnection;68;0;67;0
WireConnection;68;1;64;0
WireConnection;68;2;65;0
WireConnection;59;0;58;0
WireConnection;59;1;60;0
WireConnection;61;0;59;0
WireConnection;61;1;64;0
WireConnection;61;2;65;0
WireConnection;70;0;68;0
WireConnection;70;1;71;0
WireConnection;69;0;61;0
WireConnection;73;0;70;0
WireConnection;231;0;226;1
WireConnection;229;0;228;0
WireConnection;229;1;228;0
WireConnection;219;0;217;0
WireConnection;219;1;217;0
WireConnection;218;0;217;0
WireConnection;218;1;217;0
WireConnection;230;0;228;0
WireConnection;230;1;228;0
WireConnection;74;0;69;0
WireConnection;74;1;73;0
WireConnection;221;0;215;2
WireConnection;221;1;219;0
WireConnection;221;2;218;0
WireConnection;245;0;242;0
WireConnection;245;1;242;0
WireConnection;244;0;242;0
WireConnection;244;1;242;0
WireConnection;233;0;231;0
WireConnection;233;1;229;0
WireConnection;233;2;230;0
WireConnection;75;0;74;0
WireConnection;77;0;75;0
WireConnection;77;1;78;0
WireConnection;246;0;243;2
WireConnection;246;1;245;0
WireConnection;246;2;244;0
WireConnection;239;1;221;0
WireConnection;240;1;233;0
WireConnection;247;1;246;0
WireConnection;224;0;239;0
WireConnection;235;0;240;0
WireConnection;76;0;74;0
WireConnection;76;1;77;0
WireConnection;84;0;45;0
WireConnection;84;1;83;0
WireConnection;79;0;76;0
WireConnection;79;1;80;0
WireConnection;237;0;235;0
WireConnection;237;1;224;0
WireConnection;248;0;247;0
WireConnection;249;0;237;0
WireConnection;249;1;248;0
WireConnection;82;0;84;0
WireConnection;82;1;79;0
WireConnection;238;1;249;0
WireConnection;238;2;45;4
WireConnection;252;0;251;0
WireConnection;252;2;253;0
WireConnection;252;1;250;0
WireConnection;50;0;82;0
WireConnection;0;9;238;0
WireConnection;0;13;50;0
WireConnection;0;11;252;0
ASEEND*/
//CHKSM=260841908595450F1B3666FE08EB475A4465A7E0