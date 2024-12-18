// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "CRT_Television"
{
	Properties
	{
		_Intensity("Intensity", Range( 0 , 0.15)) = 0
		_Levels("Levels", Range( 0 , 100)) = 71
		_MainTexture("Main Texture", 2D) = "white" {}
		_TVScreenEmissionTex("TVScreenEmissionTex", 2D) = "white" {}
		_TVScreenEmissionTurnOff("TVScreenEmissionTurnOff", 2D) = "white" {}
		_Tint("Tint", Color) = (0,0,0,0)
		_LightIntensity("LightIntensity", Range( 0 , 5)) = 0
		_LerpLightDir("LerpLightDir", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
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

		uniform sampler2D _TVScreenEmissionTurnOff;
		uniform float4 _TVScreenEmissionTurnOff_ST;
		uniform float _Intensity;
		uniform sampler2D _TVScreenEmissionTex;
		uniform float4 _TVScreenEmissionTex_ST;
		uniform float4 _Tint;
		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform float _LerpLightDir;
		uniform float _Levels;
		uniform float _LightIntensity;


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


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float4 Albedo137 = ( _Tint * tex2D( _MainTexture, uv_MainTexture ) );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult160 = dot( ase_worldNormal , ase_worldlightDir );
			float3 temp_cast_1 = (ase_worldNormal.x).xxx;
			float dotResult128 = dot( temp_cast_1 , ase_worldlightDir );
			float lerpResult161 = lerp( dotResult160 , dotResult128 , _LerpLightDir);
			float Normal_LightDir132 = lerpResult161;
			float4 temp_cast_3 = (Normal_LightDir132).xxxx;
			float div139=256.0/float((int)(Normal_LightDir132*_Levels + _Levels));
			float4 posterize139 = ( floor( temp_cast_3 * div139 ) / div139 );
			float4 Shadow142 = ( Albedo137 * posterize139 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 LightColor148 = ( Shadow142 * ase_lightColor * _LightIntensity );
			c.rgb = ( LightColor148 * ( 1.0 - step( ase_lightAtten , 0.33 ) ) ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float2 uv_TVScreenEmissionTurnOff = i.uv_texcoord * _TVScreenEmissionTurnOff_ST.xy + _TVScreenEmissionTurnOff_ST.zw;
			float2 uv_TexCoord107 = i.uv_texcoord + float2( -0.296,0.109 );
			float2 uv_TVScreenEmissionTex = i.uv_texcoord * _TVScreenEmissionTex_ST.xy + _TVScreenEmissionTex_ST.zw;
			float2 uv_TexCoord51 = i.uv_texcoord * float2( 5,5 ) + float2( 2,1 );
			float mulTime53 = _Time.y * 60.0;
			float simplePerlin2D55 = snoise( uv_TexCoord51*mulTime53 );
			simplePerlin2D55 = simplePerlin2D55*0.5 + 0.5;
			o.Emission = ( ( tex2D( _TVScreenEmissionTurnOff, uv_TVScreenEmissionTurnOff ) * ( 1.0 - step( _Intensity , distance( uv_TexCoord107 , float2( 0.5,0.5 ) ) ) ) ) * ( tex2D( _TVScreenEmissionTex, uv_TVScreenEmissionTex ) * simplePerlin2D55 ) ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

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
Version=17800
516;269;1307;605;5644.103;3028.628;7.178104;False;False
Node;AmplifyShaderEditor.CommentaryNode;124;-3816.192,-643.9211;Inherit;False;1038.711;763.5355;Normal LightDir;9;132;161;125;126;128;162;158;160;159;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;159;-3764.192,-436.4141;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;158;-3748.192,-596.4142;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;126;-3720.49,-79.14673;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;125;-3707.67,-255.0481;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;128;-3458.228,-286.5525;Inherit;True;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;160;-3524.19,-548.414;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;162;-3466.47,-9.52977;Inherit;False;Property;_LerpLightDir;LerpLightDir;7;0;Create;True;0;0;False;0;0;0.338;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;161;-3167.383,-405.9398;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;-0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;127;-2492.467,-1068.027;Inherit;False;983.5848;609.9885;Albedo;4;137;133;130;47;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;132;-2980.044,-310.7559;Inherit;False;Normal_LightDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;130;-2358.069,-980.3763;Inherit;False;Property;_Tint;Tint;5;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;47;-2428.948,-726.5627;Inherit;True;Property;_MainTexture;Main Texture;2;0;Create;True;0;0;False;0;-1;None;058bf8d416c799e4eaf2e130d94e3959;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;129;-2643.996,-321.3015;Inherit;False;1371.36;494.1964;Shadow;7;142;140;139;138;136;135;134;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-2047.442,-827.9495;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-2579.996,30.69875;Inherit;False;Property;_Levels;Levels;1;0;Create;True;0;0;False;0;71;30;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;135;-2563.996,-177.3012;Inherit;False;132;Normal_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;136;-2291.996,-33.30149;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;137;-1712.825,-647.8388;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosterizeNode;139;-2083.996,-81.30151;Inherit;True;30;2;1;COLOR;0,0,0,0;False;0;INT;30;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;138;-2099.996,-257.3011;Inherit;False;137;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;-1795.996,-177.3012;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;141;-2547.996,366.6986;Inherit;False;1202.176;506.8776;Light Color;5;148;146;145;144;143;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;108;-1737.089,-1921.583;Inherit;False;Constant;_Vector0;Vector 0;2;0;Create;True;0;0;False;0;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;107;-1901.671,-2074.229;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;-0.296,0.109;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;142;-1523.996,-113.3014;Inherit;False;Shadow;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-2515.996,734.6987;Inherit;False;Property;_LightIntensity;LightIntensity;6;0;Create;True;0;0;False;0;0;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;144;-2515.996,574.6987;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;143;-2387.996,446.6986;Inherit;False;142;Shadow;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-1584.355,-2184.976;Inherit;False;Property;_Intensity;Intensity;0;0;Create;True;0;0;False;0;0;0;0;0.15;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;111;-1498.997,-2095.168;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;147;-900.4688,-359.1904;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;-2115.996,558.6987;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;51;-1553.829,-1624.263;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;5,5;False;1;FLOAT2;2,1;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;110;-1256.294,-2114.072;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;53;-1526.171,-1414.731;Inherit;False;1;0;FLOAT;60;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;86;-1128.875,-2379.016;Inherit;True;Property;_TVScreenEmissionTurnOff;TVScreenEmissionTurnOff;4;0;Create;True;0;0;False;0;-1;None;8189b357ec7880a48b71b835c3782c5d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;55;-1188.901,-1501.74;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;50;-1250.648,-1760.082;Inherit;True;Property;_TVScreenEmissionTex;TVScreenEmissionTex;3;0;Create;True;0;0;False;0;-1;None;8189b357ec7880a48b71b835c3782c5d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;112;-1010.395,-2069.551;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;148;-1587.996,526.6987;Inherit;False;LightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;149;-640.9451,-484.945;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.33;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-710.018,-1591.575;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-708.3166,-1880.838;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;151;-3651.998,222.6987;Inherit;False;787.1289;475.5013;Normal ViewDir;4;157;156;154;153;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;150;-446.1534,-812.0279;Inherit;True;148;LightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;152;-398.0116,-521.714;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;-121.1805,-677.014;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;154;-3571.997,478.6986;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;153;-3347.996,318.6987;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;157;-3587.998,286.6987;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;-391.2828,-1655.779;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;156;-3059.996,430.6986;Inherit;False;Normal_ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;83.51207,-940.9026;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;CRT_Television;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;128;0;125;1
WireConnection;128;1;126;0
WireConnection;160;0;158;0
WireConnection;160;1;159;0
WireConnection;161;0;160;0
WireConnection;161;1;128;0
WireConnection;161;2;162;0
WireConnection;132;0;161;0
WireConnection;133;0;130;0
WireConnection;133;1;47;0
WireConnection;136;0;135;0
WireConnection;136;1;134;0
WireConnection;136;2;134;0
WireConnection;137;0;133;0
WireConnection;139;1;135;0
WireConnection;139;0;136;0
WireConnection;140;0;138;0
WireConnection;140;1;139;0
WireConnection;142;0;140;0
WireConnection;111;0;107;0
WireConnection;111;1;108;0
WireConnection;146;0;143;0
WireConnection;146;1;144;0
WireConnection;146;2;145;0
WireConnection;110;0;109;0
WireConnection;110;1;111;0
WireConnection;55;0;51;0
WireConnection;55;1;53;0
WireConnection;112;0;110;0
WireConnection;148;0;146;0
WireConnection;149;0;147;0
WireConnection;54;0;50;0
WireConnection;54;1;55;0
WireConnection;90;0;86;0
WireConnection;90;1;112;0
WireConnection;152;0;149;0
WireConnection;155;0;150;0
WireConnection;155;1;152;0
WireConnection;153;0;157;0
WireConnection;153;1;154;0
WireConnection;116;0;90;0
WireConnection;116;1;54;0
WireConnection;156;0;153;0
WireConnection;0;2;116;0
WireConnection;0;13;155;0
ASEEND*/
//CHKSM=56DDA3A6FDC34125ECC8BF0B610431CEBD79B5D9