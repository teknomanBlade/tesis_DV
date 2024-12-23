// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TallGray_Melee"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.75
		_FirstPosition1("First Position", Float) = 0
		_SecondPosition1("Second Position", Float) = 0
		_NoiseDirection("NoiseDirection", Vector) = (0,1,0,0)
		_NoiseScrollspeed("NoiseScrollspeed", Float) = 1
		_SecondPositionIntensity1("Second Position Intensity", Float) = 0
		_ShadowIntensity1("Shadow Intensity", Float) = 0
		_NoiseScale("NoiseScale", Vector) = (2,2,0,0)
		_MainTexture("Main Texture", 2D) = "white" {}
		_PaintStains("PaintStains", 2D) = "white" {}
		_EdgeThickness("EdgeThickness", Range( 0 , 0.3)) = 0
		[HDR]_EdgeColor("EdgeColor", Color) = (0,0,0,0)
		[Toggle]_VertexPosition("VertexPosition", Float) = 1
		_DissolveDirection("DissolveDirection", Vector) = (0,1,0,0)
		_UpperLimit("UpperLimit", Float) = -5
		_LowerLimit("LowerLimit", Float) = 5
		_ScaleDissolveGray("ScaleDissolveGray", Range( 0 , 1)) = 0.4301261
		_ElectricityEffect1("ElectricityEffect", Range( 0 , 0.4)) = 0
		_LerpStains("LerpStains", Range( 0 , 0.7)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
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
		uniform float _ElectricityEffect1;
		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform sampler2D _PaintStains;
		uniform float4 _PaintStains_ST;
		uniform float _LerpStains;
		uniform float _FirstPosition1;
		uniform float _SecondPosition1;
		uniform float _SecondPositionIntensity1;
		uniform float _ShadowIntensity1;
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
			float3 normalizeResult80 = normalize( (( _VertexPosition )?( ase_vertex3Pos ):( ase_worldPos )) );
			float3 normalizeResult76 = normalize( _DissolveDirection );
			float dotResult84 = dot( normalizeResult80 , normalizeResult76 );
			float Fade87 = ( dotResult84 + (-_UpperLimit + (_ScaleDissolveGray - 0.0) * (-_LowerLimit - -_UpperLimit) / (1.0 - 0.0)) );
			float3 normalizeResult54 = normalize( _NoiseDirection );
			float simplePerlin3D57 = snoise( ( ase_vertex3Pos + ( ( normalizeResult54 * _NoiseScrollspeed ) * _Time.y ) )*_NoiseScale.x );
			simplePerlin3D57 = simplePerlin3D57*0.5 + 0.5;
			float Noise58 = simplePerlin3D57;
			float temp_output_60_0 = ( ( 1.0 - Fade87 ) * Noise58 );
			float temp_output_63_0 = ( temp_output_60_0 - Fade87 );
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float4 tex2DNode45 = tex2D( _MainTexture, uv_MainTexture );
			float2 uv_PaintStains = i.uv_texcoord * _PaintStains_ST.xy + _PaintStains_ST.zw;
			float4 lerpResult133 = lerp( tex2DNode45 , ( tex2DNode45 + tex2D( _PaintStains, uv_PaintStains ) ) , _LerpStains);
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldNormal = i.worldNormal;
			float dotResult95 = dot( ase_worldlightDir , ase_worldNormal );
			float temp_output_101_0 = ( ( dotResult95 + 1.0 ) * ase_lightAtten );
			float temp_output_113_0 = ( saturate( ( 1.0 - step( temp_output_101_0 , _FirstPosition1 ) ) ) + saturate( ( ( 1.0 - step( temp_output_101_0 , _SecondPosition1 ) ) - _SecondPositionIntensity1 ) ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			c.rgb = saturate( ( lerpResult133 * ( ( temp_output_113_0 + ( ( 1.0 - temp_output_113_0 ) * _ShadowIntensity1 ) ) * ase_lightColor * ( 1.0 - step( ase_lightAtten , 0.0 ) ) ) ) ).rgb;
			c.a = 1;
			clip( temp_output_63_0 - _Cutoff );
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
			float3 normalizeResult80 = normalize( (( _VertexPosition )?( ase_vertex3Pos ):( ase_worldPos )) );
			float3 normalizeResult76 = normalize( _DissolveDirection );
			float dotResult84 = dot( normalizeResult80 , normalizeResult76 );
			float Fade87 = ( dotResult84 + (-_UpperLimit + (_ScaleDissolveGray - 0.0) * (-_LowerLimit - -_UpperLimit) / (1.0 - 0.0)) );
			float3 normalizeResult54 = normalize( _NoiseDirection );
			float simplePerlin3D57 = snoise( ( ase_vertex3Pos + ( ( normalizeResult54 * _NoiseScrollspeed ) * _Time.y ) )*_NoiseScale.x );
			simplePerlin3D57 = simplePerlin3D57*0.5 + 0.5;
			float Noise58 = simplePerlin3D57;
			float temp_output_60_0 = ( ( 1.0 - Fade87 ) * Noise58 );
			float temp_output_63_0 = ( temp_output_60_0 - Fade87 );
			float4 color127 = IsGammaSpace() ? float4(0,1,0.9999998,0) : float4(0,1,0.9999997,0);
			float4 lerpResult130 = lerp( ( _EdgeColor * step( temp_output_63_0 , ( _EdgeThickness + (0.0 + (0.0 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) ) ) ) , ( temp_output_60_0 * color127 ) , _ElectricityEffect1);
			o.Emission = lerpResult130.rgb;
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
189;495;1195;524;5827.71;1623.407;2.401281;True;False
Node;AmplifyShaderEditor.CommentaryNode;92;-7261.579,-776.4856;Inherit;False;2894.373;778.0368;Main Light;22;118;117;116;115;114;113;112;111;109;107;103;101;98;97;96;95;94;93;125;126;123;124;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;93;-7207.779,-738.2413;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;94;-7185.5,-599.364;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;95;-6908.374,-703.4039;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;51;-6930.773,-3722.09;Inherit;False;1987.844;732.4697;Comment;11;86;82;81;77;71;70;58;57;56;55;54;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;52;-6786.773,-2410.089;Inherit;False;1738.878;722.5874;Comment;14;87;85;84;83;80;79;78;76;75;74;73;72;69;68;Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;-6673.667,-707.7556;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;96;-6695.305,-546.408;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;69;-6706.773,-2170.089;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;68;-6706.773,-2314.089;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;70;-6882.773,-3450.089;Inherit;False;Property;_NoiseDirection;NoiseDirection;3;0;Create;True;0;0;False;0;0,1,0;0,0,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;98;-6495.617,-185.1682;Inherit;False;Property;_SecondPosition1;Second Position;2;0;Create;True;0;0;False;0;0;0.17;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-6818.773,-3240.439;Inherit;False;Property;_NoiseScrollspeed;NoiseScrollspeed;4;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;-6528.699,-692.9479;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;72;-6434.773,-2330.089;Inherit;False;Property;_VertexPosition;VertexPosition;12;0;Create;True;0;0;False;0;1;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;54;-6690.773,-3386.089;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;75;-6402.773,-2090.089;Inherit;False;Property;_DissolveDirection;DissolveDirection;13;0;Create;True;0;0;False;0;0,1,0;0,0,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;73;-6754.773,-1994.089;Inherit;False;Property;_UpperLimit;UpperLimit;14;0;Create;True;0;0;False;0;-5;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-6770.773,-1882.089;Inherit;False;Property;_LowerLimit;LowerLimit;15;0;Create;True;0;0;False;0;5;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;79;-6578.773,-1882.089;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;76;-6178.773,-2074.089;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-6540.214,-1506.114;Inherit;False;Property;_ScaleDissolveGray;ScaleDissolveGray;16;0;Create;True;0;0;False;0;0.4301261;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-6498.773,-3370.089;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-6382.302,-592.8411;Inherit;False;Property;_FirstPosition1;First Position;1;0;Create;True;0;0;False;0;0;0.07;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;77;-6818.773,-3146.089;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;80;-6146.773,-2298.089;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;78;-6578.773,-1978.089;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;125;-6258.347,-424.9352;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;84;-5922.773,-2074.089;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-6434.773,-3258.089;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;126;-6010.411,-399.2887;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;83;-5938.773,-1802.089;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-5885.843,-130.0659;Inherit;False;Property;_SecondPositionIntensity1;Second Position Intensity;5;0;Create;True;0;0;False;0;0;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;123;-6151.633,-754.7568;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;55;-6834.773,-3642.09;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;86;-6066.773,-3274.089;Inherit;False;Property;_NoiseScale;NoiseScale;7;0;Create;True;0;0;False;0;2,2;5,5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;85;-5618.773,-2042.089;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;124;-5842.404,-680.0759;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;-6258.773,-3530.09;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;109;-5634.398,-336.7509;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;57;-5842.773,-3546.09;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;-5330.773,-2042.089;Inherit;True;Fade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;111;-5531.769,-518.0933;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;112;-5414.461,-341.7214;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-4788.89,-2874.089;Inherit;True;87;Fade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;113;-5234.283,-444.3958;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;-5170.773,-3418.089;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;119;-4691.311,112.938;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;89;-4512.352,-2938.066;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-4754.773,-2682.089;Inherit;True;58;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;53;-4450.773,-2058.089;Inherit;False;820.2998;637.5504;GLow;5;66;65;64;62;61;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-4993.495,-145.1509;Inherit;False;Property;_ShadowIntensity1;Shadow Intensity;6;0;Create;True;0;0;False;0;0;0.41;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;114;-4950.517,-368.949;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;131;-4688.961,-1001.532;Inherit;True;Property;_PaintStains;PaintStains;9;0;Create;True;0;0;False;0;-1;None;474aef83df6327b4a9e37d03a9fae319;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;61;-4450.773,-1882.089;Inherit;False;Property;_EdgeThickness;EdgeThickness;10;0;Create;True;0;0;False;0;0;0.3;0;0.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;121;-4473.18,16.47061;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-4738.773,-2442.089;Inherit;True;87;Fade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;62;-4402.773,-1754.089;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;-4650.612,-338.1508;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-4263.222,-2866.959;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;45;-4688.961,-1209.532;Inherit;True;Property;_MainTexture;Main Texture;8;0;Create;True;0;0;False;0;-1;None;e33be6dc7500e1d49a28c13edcb4a882;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;64;-4210.773,-1770.089;Inherit;True;2;2;0;FLOAT;0.01;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-4386.272,-860.9647;Inherit;False;Property;_LerpStains;LerpStains;18;0;Create;True;0;0;False;0;0;0.7;0;0.7;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;117;-4519.208,-431.5712;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;132;-4316.046,-1070.914;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;122;-4222.18,11.4706;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;118;-4505.71,-165.3308;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;63;-4052.307,-2622.575;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;133;-4045.292,-1200.418;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;127;-3470.139,-2181.226;Inherit;False;Constant;_Color1;Color 0;21;0;Create;True;0;0;False;0;0,1,0.9999998,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;-4264.315,-349.7026;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;65;-3970.773,-1626.089;Inherit;False;Property;_EdgeColor;EdgeColor;11;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0.7125139,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;66;-3970.773,-1930.089;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-3202.219,-1740.346;Inherit;False;Property;_ElectricityEffect1;ElectricityEffect;17;0;Create;True;0;0;False;0;0;0;0;0.4;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;-3200.966,-2352.395;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-3856.44,-694.6898;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-3506.773,-1802.089;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;47;-3570.705,-741.9908;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;130;-2824.087,-2123.013;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-2515.185,-1020.855;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;TallGray_Melee;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.75;True;True;0;False;TransparentCutout;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;95;0;93;0
WireConnection;95;1;94;0
WireConnection;97;0;95;0
WireConnection;101;0;97;0
WireConnection;101;1;96;0
WireConnection;72;0;68;0
WireConnection;72;1;69;0
WireConnection;54;0;70;0
WireConnection;79;0;74;0
WireConnection;76;0;75;0
WireConnection;81;0;54;0
WireConnection;81;1;71;0
WireConnection;80;0;72;0
WireConnection;78;0;73;0
WireConnection;125;0;101;0
WireConnection;125;1;98;0
WireConnection;84;0;80;0
WireConnection;84;1;76;0
WireConnection;82;0;81;0
WireConnection;82;1;77;2
WireConnection;126;0;125;0
WireConnection;83;0;59;0
WireConnection;83;3;78;0
WireConnection;83;4;79;0
WireConnection;123;0;101;0
WireConnection;123;1;103;0
WireConnection;85;0;84;0
WireConnection;85;1;83;0
WireConnection;124;0;123;0
WireConnection;56;0;55;0
WireConnection;56;1;82;0
WireConnection;109;0;126;0
WireConnection;109;1;107;0
WireConnection;57;0;56;0
WireConnection;57;1;86;0
WireConnection;87;0;85;0
WireConnection;111;0;124;0
WireConnection;112;0;109;0
WireConnection;113;0;111;0
WireConnection;113;1;112;0
WireConnection;58;0;57;0
WireConnection;89;0;88;0
WireConnection;114;0;113;0
WireConnection;121;0;119;0
WireConnection;116;0;114;0
WireConnection;116;1;115;0
WireConnection;60;0;89;0
WireConnection;60;1;90;0
WireConnection;64;0;61;0
WireConnection;64;1;62;0
WireConnection;117;0;113;0
WireConnection;117;1;116;0
WireConnection;132;0;45;0
WireConnection;132;1;131;0
WireConnection;122;0;121;0
WireConnection;63;0;60;0
WireConnection;63;1;91;0
WireConnection;133;0;45;0
WireConnection;133;1;132;0
WireConnection;133;2;134;0
WireConnection;120;0;117;0
WireConnection;120;1;118;0
WireConnection;120;2;122;0
WireConnection;66;0;63;0
WireConnection;66;1;64;0
WireConnection;128;0;60;0
WireConnection;128;1;127;0
WireConnection;46;0;133;0
WireConnection;46;1;120;0
WireConnection;67;0;65;0
WireConnection;67;1;66;0
WireConnection;47;0;46;0
WireConnection;130;0;67;0
WireConnection;130;1;128;0
WireConnection;130;2;129;0
WireConnection;0;2;130;0
WireConnection;0;10;63;0
WireConnection;0;13;47;0
ASEEND*/
//CHKSM=76712375739559EF38B27F365938A56DA9D7CBCC