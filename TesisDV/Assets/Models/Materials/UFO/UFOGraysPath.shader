// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "UFOGraysPath"
{
	Properties
	{
		_TextureArrows("TextureArrows", 2D) = "white" {}
		_Min("Min", Float) = 0
		_Min1("Min", Float) = 0
		_Tiling("Tiling", Vector) = (0.25,0.65,0,0)
		_Max("Max", Float) = 0
		_Max1("Max", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _TextureArrows;
		uniform float2 _Tiling;
		uniform float _Min;
		uniform float _Max;
		uniform float _Min1;
		uniform float _Max1;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_TexCoord27 = i.uv_texcoord * _Tiling + float2( 0,0.15 );
			float4 tex2DNode22 = tex2D( _TextureArrows, uv_TexCoord27 );
			float4 temp_output_46_0 = saturate( tex2DNode22 );
			o.Albedo = temp_output_46_0.rgb;
			o.Emission = temp_output_46_0.rgb;
			float temp_output_51_0 = min( _Min , _Max );
			float temp_output_52_0 = max( _Min , _Max );
			float smoothstepResult55 = smoothstep( temp_output_51_0 , temp_output_52_0 , ( 1.0 - i.uv_texcoord.x ));
			float smoothstepResult54 = smoothstep( temp_output_51_0 , temp_output_52_0 , i.uv_texcoord.x);
			float temp_output_66_0 = min( _Min1 , _Max1 );
			float temp_output_64_0 = max( _Min1 , _Max1 );
			float smoothstepResult68 = smoothstep( temp_output_66_0 , temp_output_64_0 , ( 1.0 - i.uv_texcoord.y ));
			float smoothstepResult67 = smoothstep( temp_output_66_0 , temp_output_64_0 , i.uv_texcoord.y);
			float lerpResult60 = lerp( 0.0 , ( ( saturate( smoothstepResult55 ) * saturate( smoothstepResult54 ) ) * ( saturate( smoothstepResult68 ) * saturate( smoothstepResult67 ) ) ) , tex2DNode22.a);
			o.Alpha = lerpResult60;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

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
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
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
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
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
789;280;1137;548;365.7534;644.9877;2.059375;False;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;50;-139.656,203.9584;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;61;-123.4074,770.8391;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;62;-97.08335,1091.866;Inherit;False;Property;_Min1;Min;2;0;Create;True;0;0;False;0;0;0.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-99.08335,1161.866;Inherit;False;Property;_Max1;Max;5;0;Create;True;0;0;False;0;0;0.43;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-113.332,524.9857;Inherit;False;Property;_Min;Min;1;0;Create;True;0;0;False;0;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-115.332,594.9857;Inherit;False;Property;_Max;Max;4;0;Create;True;0;0;False;0;0;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;52;239.6668,573.9857;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;53;181.5999,191.4235;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;64;255.9154,1140.866;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;65;197.8486,758.3042;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;66;253.9154,1047.866;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;51;237.6668,480.9857;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;68;632.3336,785.7544;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;67;608.9629,1046.385;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;55;616.0848,218.8736;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;54;592.7141,479.5048;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;69;864.2263,1028.241;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;56;906.9921,201.2663;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;57;847.9774,461.3602;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;70;890.7929,763.155;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;47;-203.5012,-158.0255;Inherit;False;Property;_Tiling;Tiling;3;0;Create;True;0;0;False;0;0.25,0.65;18.86,6.78;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;1064.588,799.9238;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;27;21.11431,-147.5654;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0.15;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;1085.779,380.3079;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;22;674.3221,-104.7658;Inherit;True;Property;_TextureArrows;TextureArrows;0;0;Create;True;0;0;False;0;-1;None;1510e9b5391b8fa42a0153dfbba3369a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;1242.889,598.1025;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;46;1295.214,-250.2679;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;60;1315.071,140.7014;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1731.892,-258.2746;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;UFOGraysPath;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;52;0;48;0
WireConnection;52;1;49;0
WireConnection;53;0;50;1
WireConnection;64;0;62;0
WireConnection;64;1;63;0
WireConnection;65;0;61;2
WireConnection;66;0;62;0
WireConnection;66;1;63;0
WireConnection;51;0;48;0
WireConnection;51;1;49;0
WireConnection;68;0;65;0
WireConnection;68;1;66;0
WireConnection;68;2;64;0
WireConnection;67;0;61;2
WireConnection;67;1;66;0
WireConnection;67;2;64;0
WireConnection;55;0;53;0
WireConnection;55;1;51;0
WireConnection;55;2;52;0
WireConnection;54;0;50;1
WireConnection;54;1;51;0
WireConnection;54;2;52;0
WireConnection;69;0;67;0
WireConnection;56;0;55;0
WireConnection;57;0;54;0
WireConnection;70;0;68;0
WireConnection;71;0;70;0
WireConnection;71;1;69;0
WireConnection;27;0;47;0
WireConnection;58;0;56;0
WireConnection;58;1;57;0
WireConnection;22;1;27;0
WireConnection;72;0;58;0
WireConnection;72;1;71;0
WireConnection;46;0;22;0
WireConnection;60;1;72;0
WireConnection;60;2;22;4
WireConnection;0;0;46;0
WireConnection;0;2;46;0
WireConnection;0;9;60;0
ASEEND*/
//CHKSM=D1A9DA6F3C1462DA32CD40875B91D5CA579E53FA