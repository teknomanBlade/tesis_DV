// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TankGray_SDR"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.75
		_FirstPosition("First Position", Float) = 0
		_SecondPosition("Second Position", Float) = 0
		_NoiseDirection("NoiseDirection", Vector) = (0,1,0,0)
		_NoiseScrollspeed("NoiseScrollspeed", Float) = 1
		_SecondPositionIntensity("Second Position Intensity", Float) = 0
		_ShadowIntensity("Shadow Intensity", Float) = 0
		_NoiseScale("NoiseScale", Vector) = (2,2,0,0)
		_MainTexture("Main Texture", 2D) = "white" {}
		_EdgeThickness("EdgeThickness", Range( 0 , 0.3)) = 0
		[HDR]_EdgeColor("EdgeColor", Color) = (0,0,0,0)
		[Toggle]_VertexPosition("VertexPosition", Float) = 1
		_DissolveDirection("DissolveDirection", Vector) = (0,1,0,0)
		_UpperLimit("UpperLimit", Float) = -5
		_LowerLimit("LowerLimit", Float) = 5
		_ScaleDissolveGray("ScaleDissolveGray", Range( 0 , 1)) = 0.4301261
		_ElectricityEffect("ElectricityEffect", Range( 0 , 0.4)) = 0
		_PaintStains("Paint Stains", 2D) = "white" {}
		_LerpStains("LerpStains", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
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

		uniform float4 _EdgeColor;
		uniform float _VertexPosition;
		uniform float3 _DissolveDirection;
		uniform float _ScaleDissolveGray;
		uniform float _UpperLimit;
		uniform float _LowerLimit;
		uniform float3 _NoiseDirection;
		uniform float _NoiseScrollspeed;
		uniform float2 _NoiseScale;
		uniform float _EdgeThickness;
		uniform float _ElectricityEffect;
		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform sampler2D _PaintStains;
		uniform float4 _PaintStains_ST;
		uniform float _LerpStains;
		uniform float _FirstPosition;
		uniform float _SecondPosition;
		uniform float _SecondPositionIntensity;
		uniform float _ShadowIntensity;
		uniform float _Cutoff = 0.75;


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
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
			float3 ase_worldPos = i.worldPos;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 normalizeResult30 = normalize( (( _VertexPosition )?( ase_vertex3Pos ):( ase_worldPos )) );
			float3 normalizeResult32 = normalize( _DissolveDirection );
			float dotResult37 = dot( normalizeResult30 , normalizeResult32 );
			float Fade47 = ( dotResult37 + (-_UpperLimit + (_ScaleDissolveGray - 0.0) * (-_LowerLimit - -_UpperLimit) / (1.0 - 0.0)) );
			float3 normalizeResult22 = normalize( _NoiseDirection );
			float simplePerlin3D48 = snoise( ( ase_vertex3Pos + ( ( normalizeResult22 * _NoiseScrollspeed ) * _Time.y ) )*_NoiseScale.x );
			simplePerlin3D48 = simplePerlin3D48*0.5 + 0.5;
			float Noise53 = simplePerlin3D48;
			float temp_output_58_0 = ( ( 1.0 - Fade47 ) * Noise53 );
			float temp_output_66_0 = ( temp_output_58_0 - Fade47 );
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float4 tex2DNode67 = tex2D( _MainTexture, uv_MainTexture );
			float2 uv_PaintStains = i.uv_texcoord * _PaintStains_ST.xy + _PaintStains_ST.zw;
			float4 tex2DNode84 = tex2D( _PaintStains, uv_PaintStains );
			float4 lerpResult96 = lerp( tex2DNode67 , ( tex2DNode67 + ( ( tex2DNode67 * tex2DNode84.a ) * tex2DNode84 ) ) , _LerpStains);
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldNormal = i.worldNormal;
			float dotResult4 = dot( ase_worldlightDir , ase_worldNormal );
			float temp_output_13_0 = ( ( dotResult4 + 1.0 ) * ase_lightAtten );
			float temp_output_49_0 = ( saturate( ( 1.0 - step( temp_output_13_0 , _FirstPosition ) ) ) + saturate( ( ( 1.0 - step( temp_output_13_0 , _SecondPosition ) ) - _SecondPositionIntensity ) ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			c.rgb = saturate( ( lerpResult96 * ( ( temp_output_49_0 + ( ( 1.0 - temp_output_49_0 ) * _ShadowIntensity ) ) * ase_lightColor * ( 1.0 - step( ase_lightAtten , 0.0 ) ) ) ) ).rgb;
			c.a = 1;
			clip( temp_output_66_0 - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float3 ase_worldPos = i.worldPos;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 normalizeResult30 = normalize( (( _VertexPosition )?( ase_vertex3Pos ):( ase_worldPos )) );
			float3 normalizeResult32 = normalize( _DissolveDirection );
			float dotResult37 = dot( normalizeResult30 , normalizeResult32 );
			float Fade47 = ( dotResult37 + (-_UpperLimit + (_ScaleDissolveGray - 0.0) * (-_LowerLimit - -_UpperLimit) / (1.0 - 0.0)) );
			float3 normalizeResult22 = normalize( _NoiseDirection );
			float simplePerlin3D48 = snoise( ( ase_vertex3Pos + ( ( normalizeResult22 * _NoiseScrollspeed ) * _Time.y ) )*_NoiseScale.x );
			simplePerlin3D48 = simplePerlin3D48*0.5 + 0.5;
			float Noise53 = simplePerlin3D48;
			float temp_output_58_0 = ( ( 1.0 - Fade47 ) * Noise53 );
			float temp_output_66_0 = ( temp_output_58_0 - Fade47 );
			float4 color80 = IsGammaSpace() ? float4(0,1,0.9999998,0) : float4(0,1,0.9999997,0);
			float4 lerpResult83 = lerp( ( _EdgeColor * step( temp_output_66_0 , ( _EdgeThickness + (0.0 + (0.0 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) ) ) ) , ( temp_output_58_0 * color80 ) , _ElectricityEffect);
			o.Emission = lerpResult83.rgb;
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
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
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
130;442;1195;530;1322.256;-339.1098;1.70881;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-3463.403,995.3022;Inherit;False;2894.373;778.0368;Main Light;19;63;62;56;51;50;49;44;42;40;34;20;13;9;6;5;4;3;2;77;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;2;-3387.324,1172.424;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;3;-3409.603,1033.547;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;4;-3110.198,1068.384;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;7;-2988.597,-638.3013;Inherit;False;1738.878;722.5874;Comment;14;47;46;39;37;35;33;32;30;23;21;19;18;11;10;Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;8;-3132.597,-1950.302;Inherit;False;1987.844;732.4697;Comment;11;53;48;45;43;41;38;31;29;24;22;12;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-2875.491,1064.032;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;5;-2897.129,1225.38;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;11;-2908.597,-398.3013;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;10;-2908.597,-542.3013;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;12;-3084.597,-1678.301;Inherit;False;Property;_NoiseDirection;NoiseDirection;3;0;Create;True;0;0;False;0;0,1,0;0,0,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;22;-2892.597,-1614.301;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;19;-2636.597,-558.3013;Inherit;False;Property;_VertexPosition;VertexPosition;11;0;Create;True;0;0;False;0;1;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;21;-2604.597,-318.3013;Inherit;False;Property;_DissolveDirection;DissolveDirection;12;0;Create;True;0;0;False;0;0,1,0;0,0,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;18;-2972.597,-110.3011;Inherit;False;Property;_LowerLimit;LowerLimit;14;0;Create;True;0;0;False;0;5;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-3020.597,-1468.651;Inherit;False;Property;_NoiseScrollspeed;NoiseScrollspeed;4;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-2956.597,-222.3011;Inherit;False;Property;_UpperLimit;UpperLimit;13;0;Create;True;0;0;False;0;-5;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-2412.43,1396.611;Inherit;False;Property;_SecondPosition;Second Position;2;0;Create;True;0;0;False;0;0;0.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-2730.523,1078.84;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;30;-2348.597,-526.3013;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-2700.597,-1598.301;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-2513.64,1194.27;Inherit;False;Property;_FirstPosition;First Position;1;0;Create;True;0;0;False;0;0;0.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;35;-2780.597,-206.3011;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;33;-2780.597,-110.3011;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-2742.038,265.6738;Inherit;False;Property;_ScaleDissolveGray;ScaleDissolveGray;15;0;Create;True;0;0;False;0;0.4301261;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;31;-3020.597,-1374.301;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;78;-2534.152,1645.089;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;32;-2380.597,-302.3013;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-2087.667,1641.722;Inherit;False;Property;_SecondPositionIntensity;Second Position Intensity;5;0;Create;True;0;0;False;0;0;0.65;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;38;-3036.597,-1870.302;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;79;-2283.152,1640.089;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-2636.597,-1486.301;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StepOpNode;77;-2294.882,836.8563;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;37;-2124.597,-302.3013;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;39;-2140.597,-30.30115;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-2460.597,-1758.302;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-1820.597,-270.3011;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;76;-2043.882,831.8563;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;-1836.222,1435.037;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;43;-2268.597,-1502.301;Inherit;False;Property;_NoiseScale;NoiseScale;7;0;Create;True;0;0;False;0;2,2;5,5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SaturateNode;42;-1733.593,1253.695;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;44;-1616.285,1430.066;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-1532.597,-270.3011;Inherit;True;Fade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;48;-2044.597,-1774.302;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;84;-995.6245,691.866;Inherit;True;Property;_PaintStains;Paint Stains;17;0;Create;True;0;0;False;0;-1;None;396f2e04959cc10499a12c955885d792;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;-1372.597,-1646.301;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-1436.107,1327.392;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-990.7139,-1102.301;Inherit;True;47;Fade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;67;-947.0412,485.4675;Inherit;True;Property;_MainTexture;Main Texture;8;0;Create;True;0;0;False;0;-1;None;51ca35c7ff1e93948b6714aa30370361;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;57;-956.5967,-910.3013;Inherit;True;53;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;50;-1152.341,1402.839;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1195.319,1626.637;Inherit;False;Property;_ShadowIntensity;Shadow Intensity;6;0;Create;True;0;0;False;0;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;55;-652.5967,-286.3013;Inherit;False;820.2998;637.5504;GLow;5;71;70;65;61;59;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LightAttenuation;64;-860.3408,1825.63;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;54;-714.1758,-1166.278;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-576.8063,613.0247;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-852.4355,1433.637;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-652.5967,-110.3011;Inherit;False;Property;_EdgeThickness;EdgeThickness;9;0;Create;True;0;0;False;0;0;0.3;0;0.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;74;-609.3823,1803.856;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-465.0459,-1095.171;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;-940.5967,-670.3013;Inherit;True;47;Fade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;61;-604.5967,17.69885;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-349.4197,663.9146;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;66;-254.1306,-850.7871;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;75;-502.3823,1729.856;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-412.5967,1.698853;Inherit;True;2;2;0;FLOAT;0.01;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-150.0737,877.2728;Inherit;False;Property;_LerpStains;LerpStains;18;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;63;-707.5337,1606.457;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;95;-109.3595,460.2444;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;-721.0317,1340.217;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;80;123.2956,-723.735;Inherit;False;Constant;_Color0;Color 0;21;0;Create;True;0;0;False;0;0,1,0.9999998,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-466.1387,1422.085;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;70;-172.5967,-158.3011;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;71;-172.5967,145.6989;Inherit;False;Property;_EdgeColor;EdgeColor;10;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0.7137255,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;96;213.5756,494.2673;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;392.4685,-894.9039;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;82;391.2156,-519.5309;Inherit;False;Property;_ElectricityEffect;ElectricityEffect;16;0;Create;True;0;0;False;0;0;0;0;0.4;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;291.4033,-30.30115;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;329.4848,990.79;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;83;769.3475,-665.5228;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;72;502.9815,971.5158;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1412.649,34.87128;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;TankGray_SDR;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.75;True;True;0;True;Transparent;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;3;0
WireConnection;4;1;2;0
WireConnection;6;0;4;0
WireConnection;22;0;12;0
WireConnection;19;0;10;0
WireConnection;19;1;11;0
WireConnection;13;0;6;0
WireConnection;13;1;5;0
WireConnection;30;0;19;0
WireConnection;29;0;22;0
WireConnection;29;1;24;0
WireConnection;35;0;23;0
WireConnection;33;0;18;0
WireConnection;78;0;13;0
WireConnection;78;1;9;0
WireConnection;32;0;21;0
WireConnection;79;0;78;0
WireConnection;41;0;29;0
WireConnection;41;1;31;2
WireConnection;77;0;13;0
WireConnection;77;1;20;0
WireConnection;37;0;30;0
WireConnection;37;1;32;0
WireConnection;39;0;28;0
WireConnection;39;3;35;0
WireConnection;39;4;33;0
WireConnection;45;0;38;0
WireConnection;45;1;41;0
WireConnection;46;0;37;0
WireConnection;46;1;39;0
WireConnection;76;0;77;0
WireConnection;40;0;79;0
WireConnection;40;1;34;0
WireConnection;42;0;76;0
WireConnection;44;0;40;0
WireConnection;47;0;46;0
WireConnection;48;0;45;0
WireConnection;48;1;43;0
WireConnection;53;0;48;0
WireConnection;49;0;42;0
WireConnection;49;1;44;0
WireConnection;50;0;49;0
WireConnection;54;0;52;0
WireConnection;92;0;67;0
WireConnection;92;1;84;4
WireConnection;56;0;50;0
WireConnection;56;1;51;0
WireConnection;74;0;64;0
WireConnection;58;0;54;0
WireConnection;58;1;57;0
WireConnection;94;0;92;0
WireConnection;94;1;84;0
WireConnection;66;0;58;0
WireConnection;66;1;60;0
WireConnection;75;0;74;0
WireConnection;65;0;59;0
WireConnection;65;1;61;0
WireConnection;95;0;67;0
WireConnection;95;1;94;0
WireConnection;62;0;49;0
WireConnection;62;1;56;0
WireConnection;68;0;62;0
WireConnection;68;1;63;0
WireConnection;68;2;75;0
WireConnection;70;0;66;0
WireConnection;70;1;65;0
WireConnection;96;0;67;0
WireConnection;96;1;95;0
WireConnection;96;2;89;0
WireConnection;81;0;58;0
WireConnection;81;1;80;0
WireConnection;73;0;71;0
WireConnection;73;1;70;0
WireConnection;69;0;96;0
WireConnection;69;1;68;0
WireConnection;83;0;73;0
WireConnection;83;1;81;0
WireConnection;83;2;82;0
WireConnection;72;0;69;0
WireConnection;0;2;83;0
WireConnection;0;10;66;0
WireConnection;0;13;72;0
ASEEND*/
//CHKSM=04ED24AC0AE2905708D3B53EE3AE0E8EBF85E100