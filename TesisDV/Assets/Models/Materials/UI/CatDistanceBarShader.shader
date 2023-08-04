// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "CatDistanceBarShader"
{
	Properties
	{
		_TextureArrows("TextureArrows", 2D) = "white" {}
		_Speed("Speed", Vector) = (0.4,0,0,0)
		_Tiling("Tiling", Vector) = (0,0,0,0)
		_Min("Min", Float) = 0
		_Float0("Float 0", Float) = 0
		_Max("Max", Float) = 0
		_Float1("Float 1", Float) = 0
		_Offset("Offset", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _TextureArrows;
		uniform float2 _Speed;
		uniform float2 _Tiling;
		uniform float2 _Offset;
		uniform float _Min;
		uniform float _Max;
		uniform float _Float0;
		uniform float _Float1;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_TexCoord35 = i.uv_texcoord * _Tiling + _Offset;
			float2 panner50 = ( 0.2 * _Time.y * _Speed + uv_TexCoord35);
			float4 tex2DNode21 = tex2D( _TextureArrows, ( 1.0 - panner50 ) );
			o.Emission = tex2DNode21.rgb;
			float temp_output_81_0 = min( _Min , _Max );
			float temp_output_83_0 = max( _Min , _Max );
			float smoothstepResult84 = smoothstep( temp_output_81_0 , temp_output_83_0 , ( 1.0 - i.uv_texcoord.x ));
			float smoothstepResult85 = smoothstep( temp_output_81_0 , temp_output_83_0 , i.uv_texcoord.x);
			float temp_output_94_0 = min( _Float0 , _Float1 );
			float temp_output_95_0 = max( _Float0 , _Float1 );
			float smoothstepResult98 = smoothstep( temp_output_94_0 , temp_output_95_0 , ( 1.0 - i.uv_texcoord.y ));
			float smoothstepResult97 = smoothstep( temp_output_94_0 , temp_output_95_0 , i.uv_texcoord.y);
			float lerpResult89 = lerp( 0.0 , ( ( saturate( smoothstepResult84 ) * saturate( smoothstepResult85 ) ) * ( saturate( smoothstepResult98 ) * saturate( smoothstepResult97 ) ) ) , tex2DNode21.a);
			o.Alpha = lerpResult89;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

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
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
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
522;520;1137;567;1861.155;2031.662;2.598229;True;False
Node;AmplifyShaderEditor.RangedFloatNode;92;-1159.484,-72.66212;Inherit;False;Property;_Float0;Float 0;5;0;Create;True;0;0;False;0;0;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;93;-1185.808,-393.6894;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;91;-1166.388,5.511567;Inherit;False;Property;_Float1;Float 1;7;0;Create;True;0;0;False;0;0;0.53;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;78;-1185.012,-944.2591;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;79;-1158.688,-623.2318;Inherit;False;Property;_Min;Min;4;0;Create;True;0;0;False;0;0;0.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-1160.688,-553.2317;Inherit;False;Property;_Max;Max;6;0;Create;True;0;0;False;0;0;0.61;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;105;-924.6085,-1234.975;Inherit;False;Property;_Offset;Offset;8;0;Create;True;0;0;False;0;0,0;0.5,0.87;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;73;-932.149,-1479.315;Inherit;False;Property;_Tiling;Tiling;3;0;Create;True;0;0;False;0;0,0;10.55,3.23;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMinOpNode;94;-808.4859,-116.6621;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;82;-863.7569,-956.794;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;81;-807.6899,-667.2318;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;96;-864.5529,-406.2243;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;95;-806.4859,-23.6621;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;83;-805.6899,-574.2318;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;85;-452.6426,-668.7127;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;98;-430.068,-378.7741;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;97;-453.4387,-118.143;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-690.6868,-1420.179;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0.5;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;51;-647.757,-1227.832;Inherit;False;Property;_Speed;Speed;2;0;Create;True;0;0;False;0;0.4,0;0.3,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SmoothstepOpNode;84;-429.2719,-929.3439;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;100;-139.1605,-396.3814;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;99;-198.1752,-136.2875;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;86;-197.3792,-686.8572;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;50;-452.9739,-1385.183;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;0.2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;87;-205.3292,-934.3953;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-16.80992,-801.1887;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;-2.364597,-331.9359;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;90;-261.8485,-1416.158;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;156.6612,-707.7629;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;21;-74.4173,-1465.067;Inherit;True;Property;_TextureArrows;TextureArrows;0;0;Create;True;0;0;False;0;-1;None;1510e9b5391b8fa42a0153dfbba3369a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;89;363.9189,-959.663;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;76;752.3682,-1245.262;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;CatDistanceBarShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.9;True;True;0;True;Transparent;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;94;0;92;0
WireConnection;94;1;91;0
WireConnection;82;0;78;1
WireConnection;81;0;79;0
WireConnection;81;1;80;0
WireConnection;96;0;93;2
WireConnection;95;0;92;0
WireConnection;95;1;91;0
WireConnection;83;0;79;0
WireConnection;83;1;80;0
WireConnection;85;0;78;1
WireConnection;85;1;81;0
WireConnection;85;2;83;0
WireConnection;98;0;96;0
WireConnection;98;1;94;0
WireConnection;98;2;95;0
WireConnection;97;0;93;2
WireConnection;97;1;94;0
WireConnection;97;2;95;0
WireConnection;35;0;73;0
WireConnection;35;1;105;0
WireConnection;84;0;82;0
WireConnection;84;1;81;0
WireConnection;84;2;83;0
WireConnection;100;0;98;0
WireConnection;99;0;97;0
WireConnection;86;0;85;0
WireConnection;50;0;35;0
WireConnection;50;2;51;0
WireConnection;87;0;84;0
WireConnection;88;0;87;0
WireConnection;88;1;86;0
WireConnection;101;0;100;0
WireConnection;101;1;99;0
WireConnection;90;0;50;0
WireConnection;103;0;88;0
WireConnection;103;1;101;0
WireConnection;21;1;90;0
WireConnection;89;1;103;0
WireConnection;89;2;21;4
WireConnection;76;2;21;0
WireConnection;76;9;89;0
ASEEND*/
//CHKSM=3E3808DEC14A53F0F43016BAFD02D48B21DC885B