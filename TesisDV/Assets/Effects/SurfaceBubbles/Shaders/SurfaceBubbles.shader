// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EdShaders/SurfaceBubbles"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_OutwardPushAmount("Outward Push Amount", Float) = 5
		_UpPushAmount("Up Push Amount", Float) = 5
		_noisescale("noise scale", Float) = 1
		_Shading("Shading", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _tex4coord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
			float4 uv_tex4coord;
			float2 uv2_texcoord2;
			float3 worldNormal;
		};

		uniform float _UpPushAmount;
		uniform float _OutwardPushAmount;
		uniform float _noisescale;
		uniform float _Shading;
		uniform float _Cutoff = 0.5;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float pop84 = ( 1.0 - v.color.a );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float dotResult4 = dot( float3(0,-1,0) , ase_worldNormal );
			float UpFacing139 = dotResult4;
			float temp_output_10_0 = saturate( -UpFacing139 );
			float4 appendResult21 = (float4(0.0 , -( ( (( pop84 * pop84 )*2.0 + -1.0) * _UpPushAmount * pop84 ) * temp_output_10_0 ) , 0.0 , 0.0));
			float3 worldToObjDir29 = mul( unity_WorldToObject, float4( appendResult21.xyz, 0 ) ).xyz;
			float temp_output_50_0 = ( 1.0 - pop84 );
			float3 worldToObjDir28 = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) ).xyz;
			v.vertex.xyz += ( ( worldToObjDir29 + ( ( _OutwardPushAmount * ( 1.0 - ( temp_output_50_0 * temp_output_50_0 ) ) ) * ( (UpFacing139*0.5 + 0.5) * temp_output_10_0 ) * worldToObjDir28 ) ) * ( 1.0 - step( temp_output_10_0 , 0.0 ) ) * v.texcoord.z );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float pop84 = ( 1.0 - i.vertexColor.a );
			float3 appendResult157 = (float3(i.uv_tex4coord.w , i.uv2_texcoord2));
			float3 break159 = appendResult157;
			float2 appendResult116 = (float2(break159.x , break159.z));
			float simplePerlin2D86 = snoise( ( i.uv_texcoord + appendResult116 )*_noisescale );
			simplePerlin2D86 = simplePerlin2D86*0.5 + 0.5;
			float3 ase_worldNormal = i.worldNormal;
			float dotResult4 = dot( float3(0,-1,0) , ase_worldNormal );
			float UpFacing139 = dotResult4;
			float Shading143 = ( saturate( ( ( 1.0 - pop84 ) + ( simplePerlin2D86 * simplePerlin2D86 ) ) ) * saturate( -UpFacing139 ) );
			o.Albedo = ( (i.vertexColor).rgb * saturate( ( Shading143 + ( 1.0 - _Shading ) ) ) );
			o.Alpha = 1;
			float OpacityClip145 = step( pop84 , saturate( ( ( (UpFacing139*0.5 + 0.5) + simplePerlin2D86 ) * ( 1.0 - abs( UpFacing139 ) ) ) ) );
			clip( OpacityClip145 - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

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
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 customPack1 : TEXCOORD1;
				float4 customPack2 : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				float3 worldNormal : TEXCOORD4;
				half4 color : COLOR0;
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
				o.customPack2.xyzw = customInputData.uv_tex4coord;
				o.customPack2.xyzw = v.texcoord;
				o.customPack1.zw = customInputData.uv2_texcoord2;
				o.customPack1.zw = v.texcoord1;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
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
				surfIN.uv_tex4coord = IN.customPack2.xyzw;
				surfIN.uv2_texcoord2 = IN.customPack1.zw;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldNormal = IN.worldNormal;
				surfIN.vertexColor = IN.color;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18600
2560;209;1920;1029;-43.38;-813.9885;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;160;-1714.601,1388.049;Inherit;False;737.6473;427.726;;3;156;155;157;Custom Vertex Stream (Particle Position xyz);1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;156;-1664.601,1656.775;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;155;-1661.797,1438.049;Inherit;False;0;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;154;-871.875,1234.68;Inherit;False;1052.699;408.2502;;7;116;89;99;90;86;159;101;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;157;-1408.019,1537.597;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;159;-817.7397,1450.667;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CommentaryNode;142;-2015.011,-172.0204;Inherit;False;650.8121;347.4;;4;1;84;130;129;Pop amount;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;129;-1965.011,-122.0204;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;137;-2009.506,344.7925;Inherit;False;637.5356;429.1272;;4;5;4;3;139;Up Facing;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;116;-553.9945,1443.35;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;89;-627.2156,1284.68;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;5;-1959.506,577.8583;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;90;-262.3434,1526.93;Inherit;False;Property;_noisescale;noise scale;4;0;Create;True;0;0;False;0;False;1;11.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;3;-1953.304,394.7925;Inherit;False;Constant;_Vector0;Vector 0;1;0;Create;True;0;0;False;0;False;0,-1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;130;-1771.074,-45.19543;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;-241.327,1406.622;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;86;-34.17566,1448.497;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;152;432.1714,1580.797;Inherit;False;1349.862;404.1542;;11;125;128;126;117;124;118;127;123;143;141;166;Shading;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;-1600.346,-48.59848;Inherit;False;pop;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;38;-1082.67,-526.4024;Inherit;False;1917.657;439.0906;;9;35;29;21;23;22;18;17;147;149;up down movement;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;4;-1701.232,462.8896;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;166;682.533,1775.188;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;-1041.682,-261.39;Inherit;False;84;pop;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;139;-1574.316,457.9442;Inherit;False;UpFacing;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;125;670.6782,1646.736;Inherit;False;84;pop;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;140;-571.5374,85.37172;Inherit;False;139;UpFacing;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;153;509.489,1089.654;Inherit;False;1687.479;336.1028;;13;93;85;97;83;145;109;108;110;111;151;91;164;161;Opacity Clip;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;126;899.7333,1630.797;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;909.1619,1742.06;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;141;701.4414,1868.951;Inherit;False;139;UpFacing;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-876.2838,-398.6696;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;39;-969.492,329.4048;Inherit;False;1678.784;485.2946;;9;50;52;13;36;28;138;8;148;150;Outward movement;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;637.8854,1222.734;Inherit;False;139;UpFacing;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;12;-321.1595,146.3508;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;150;-948.6091,380.2504;Inherit;False;84;pop;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;117;963.6384,1863.869;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;124;1078.089,1718.146;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-658.0982,-302.3145;Inherit;False;Property;_UpPushAmount;Up Push Amount;3;0;Create;True;0;0;False;0;False;5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;17;-689.9601,-453.1659;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;161;745.0587,1129.627;Inherit;False;139;UpFacing;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;164;1025.953,1141.049;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;50;-830.36,480.6831;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-262.7653,-308.3842;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;10;-146.5224,147.2775;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;118;1184.638,1855.056;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;127;1202.407,1725.269;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;108;1050.299,1329.184;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;109;1225.993,1325.718;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;1404.2,1783.145;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-663.0011,437.9639;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-5.376002,-308.3842;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;91;1246.522,1159.619;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;7;-327.6049,11.19721;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;1405.022,1246.625;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;23;146.5555,-367.3693;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;52;-470.1834,491.9185;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-446.6748,402.8947;Inherit;False;Property;_OutwardPushAmount;Outward Push Amount;2;0;Create;True;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;143;1562.464,1748.956;Inherit;False;Shading;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;197;1722.554,247.9404;Inherit;False;Property;_Shading;Shading;6;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;138;-298.659,598.6186;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;136;1636.536,655.5952;Inherit;False;440.4998;257.0001;;2;134;135;Custom Vertex Stream (SCALE.x);1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;144;1784.998,161.6366;Inherit;False;143;Shading;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;68.03223,30.21463;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;199;1915.554,320.9404;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;97;1569.468,1240.495;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-214.5377,401.8222;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;28;10.79404,588.1554;Inherit;False;World;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;21;366.4086,-415.6299;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;1584.927,1139.654;Inherit;False;84;pop;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;29;596.9877,-453.1659;Inherit;False;World;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;548.5602,434.3466;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StepOpNode;98;93.75008,146.5887;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;83;1800.019,1206.712;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;134;1655.102,713.9772;Inherit;False;0;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;167;1896.554,-9.059601;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;198;2086.554,242.9404;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;168;2114.554,16.9404;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;200;2217.554,282.9404;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;1139.648,144.6585;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;135;1902.479,752.9282;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;145;1972.968,1204.107;Inherit;False;OpacityClip;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;107;1744.755,507.6176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;110;880.7499,1300.518;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;564.4252,1324.565;Inherit;False;Property;_Bottomerosion;Bottom erosion;5;0;Create;True;0;0;False;0;False;0.3;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-1904.638,61.23404;Inherit;False;Property;_pop;pop;1;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;169;2257.554,145.9404;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;146;2168.553,373.8446;Inherit;False;145;OpacityClip;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;101;-838.7001,1290.902;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;2169.458,486.7281;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2614.993,186.0018;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;EdShaders/SurfaceBubbles;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;157;0;155;4
WireConnection;157;1;156;0
WireConnection;159;0;157;0
WireConnection;116;0;159;0
WireConnection;116;1;159;2
WireConnection;130;0;129;4
WireConnection;99;0;89;0
WireConnection;99;1;116;0
WireConnection;86;0;99;0
WireConnection;86;1;90;0
WireConnection;84;0;130;0
WireConnection;4;0;3;0
WireConnection;4;1;5;0
WireConnection;166;0;86;0
WireConnection;139;0;4;0
WireConnection;126;0;125;0
WireConnection;128;0;166;0
WireConnection;128;1;166;0
WireConnection;147;0;149;0
WireConnection;147;1;149;0
WireConnection;12;0;140;0
WireConnection;117;0;141;0
WireConnection;124;0;126;0
WireConnection;124;1;128;0
WireConnection;17;0;147;0
WireConnection;164;0;161;0
WireConnection;50;0;150;0
WireConnection;18;0;17;0
WireConnection;18;1;35;0
WireConnection;18;2;149;0
WireConnection;10;0;12;0
WireConnection;118;0;117;0
WireConnection;127;0;124;0
WireConnection;108;0;151;0
WireConnection;109;0;108;0
WireConnection;123;0;127;0
WireConnection;123;1;118;0
WireConnection;148;0;50;0
WireConnection;148;1;50;0
WireConnection;22;0;18;0
WireConnection;22;1;10;0
WireConnection;91;0;164;0
WireConnection;91;1;86;0
WireConnection;7;0;140;0
WireConnection;93;0;91;0
WireConnection;93;1;109;0
WireConnection;23;0;22;0
WireConnection;52;0;148;0
WireConnection;143;0;123;0
WireConnection;11;0;7;0
WireConnection;11;1;10;0
WireConnection;199;0;197;0
WireConnection;97;0;93;0
WireConnection;36;0;13;0
WireConnection;36;1;52;0
WireConnection;28;0;138;0
WireConnection;21;1;23;0
WireConnection;29;0;21;0
WireConnection;8;0;36;0
WireConnection;8;1;11;0
WireConnection;8;2;28;0
WireConnection;98;0;10;0
WireConnection;83;0;85;0
WireConnection;83;1;97;0
WireConnection;198;0;144;0
WireConnection;198;1;199;0
WireConnection;168;0;167;0
WireConnection;200;0;198;0
WireConnection;15;0;29;0
WireConnection;15;1;8;0
WireConnection;135;0;134;3
WireConnection;145;0;83;0
WireConnection;107;0;98;0
WireConnection;110;0;151;0
WireConnection;110;1;111;0
WireConnection;169;0;168;0
WireConnection;169;1;200;0
WireConnection;94;0;15;0
WireConnection;94;1;107;0
WireConnection;94;2;135;0
WireConnection;0;0;169;0
WireConnection;0;10;146;0
WireConnection;0;11;94;0
ASEEND*/
//CHKSM=BEBE4AEBD9B732594459487ED80C72226D49BCEF