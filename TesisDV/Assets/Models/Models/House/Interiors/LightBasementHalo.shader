// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LightBasementHalo"
{
	Properties
	{
		_LightHaloTint("LightHaloTint", Color) = (0,0,0,0)
		_MinY("MinY", Range( 0 , 1)) = 0
		_MinY1("MinY", Range( 0 , 1)) = 0
		_MaxY("MaxY", Range( 0 , 1)) = 0
		_MaxY1("MaxY", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _LightHaloTint;
		uniform float _MinY1;
		uniform float _MaxY1;
		uniform float _MinY;
		uniform float _MaxY;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Emission = _LightHaloTint.rgb;
			float temp_output_18_0 = min( _MinY1 , _MaxY1 );
			float temp_output_19_0 = max( _MinY1 , _MaxY1 );
			float smoothstepResult20 = smoothstep( temp_output_18_0 , temp_output_19_0 , ( 1.0 - i.uv_texcoord.x ));
			float smoothstepResult21 = smoothstep( temp_output_18_0 , temp_output_19_0 , i.uv_texcoord.x);
			float temp_output_5_0 = min( _MinY , _MaxY );
			float temp_output_6_0 = max( _MinY , _MaxY );
			float smoothstepResult9 = smoothstep( temp_output_5_0 , temp_output_6_0 , ( 1.0 - i.uv_texcoord.y ));
			float smoothstepResult7 = smoothstep( temp_output_5_0 , temp_output_6_0 , i.uv_texcoord.y);
			o.Alpha = ( ( saturate( smoothstepResult20 ) * saturate( smoothstepResult21 ) ) * ( saturate( smoothstepResult9 ) * saturate( smoothstepResult7 ) ) );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows exclude_path:deferred 

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
363;400;1307;619;2720.09;100.7242;2.331015;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;14;-1867.421,101.3831;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1759.704,635.4492;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;3;-1733.38,956.476;Inherit;False;Property;_MinY;MinY;1;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-1735.38,1024.493;Inherit;False;Property;_MaxY;MaxY;3;0;Create;True;0;0;False;0;0;0.067;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1841.097,422.4099;Inherit;False;Property;_MinY1;MinY;2;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1843.097,490.4269;Inherit;False;Property;_MaxY1;MaxY;4;0;Create;True;0;0;False;0;0;0.456;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;4;-1438.448,622.9141;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;5;-1382.381,912.476;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;6;-1380.381,1005.476;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;19;-1488.098,471.4098;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;18;-1490.098,378.4099;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;17;-1546.165,88.84801;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;21;-1135.05,376.9291;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;9;-1003.962,650.3642;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;7;-1027.333,910.9951;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;20;-1111.679,116.2981;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;10;-745.5028,627.7652;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;8;-751.6639,897.3857;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;22;-853.2198,93.69908;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;23;-859.381,363.3196;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-569.0566,751.6493;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-597.6675,299.0865;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;-589.3261,-36.26899;Inherit;False;Property;_LightHaloTint;LightHaloTint;0;0;Create;True;0;0;False;0;0,0,0,0;1,0.9687811,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-170.1506,469.2112;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;165.2593,-137.3931;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;LightBasementHalo;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;5;True;True;0;False;Transparent;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.3;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;11;2
WireConnection;5;0;3;0
WireConnection;5;1;2;0
WireConnection;6;0;3;0
WireConnection;6;1;2;0
WireConnection;19;0;15;0
WireConnection;19;1;16;0
WireConnection;18;0;15;0
WireConnection;18;1;16;0
WireConnection;17;0;14;1
WireConnection;21;0;14;1
WireConnection;21;1;18;0
WireConnection;21;2;19;0
WireConnection;9;0;4;0
WireConnection;9;1;5;0
WireConnection;9;2;6;0
WireConnection;7;0;11;2
WireConnection;7;1;5;0
WireConnection;7;2;6;0
WireConnection;20;0;17;0
WireConnection;20;1;18;0
WireConnection;20;2;19;0
WireConnection;10;0;9;0
WireConnection;8;0;7;0
WireConnection;22;0;20;0
WireConnection;23;0;21;0
WireConnection;12;0;10;0
WireConnection;12;1;8;0
WireConnection;24;0;22;0
WireConnection;24;1;23;0
WireConnection;25;0;24;0
WireConnection;25;1;12;0
WireConnection;0;2;1;0
WireConnection;0;9;25;0
ASEEND*/
//CHKSM=4D917C7B372134A86897206159DF9FA3FDD87340