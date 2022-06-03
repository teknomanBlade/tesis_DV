// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DirectionalDissolve"
{
	Properties
	{
		_Albedo("Albedo", 2D) = "white" {}
		_Tint("Tint", Color) = (1,1,1,1)
		_NoiseDirection("NoiseDirection", Vector) = (0,1,0,0)
		_NoiseScrollspeed("NoiseScrollspeed", Float) = 1
		_NoiseScale("NoiseScale", Vector) = (2,2,0,0)
		_EdgeThickness("EdgeThickness", Range( 0 , 0.3)) = 0
		[HDR]_EdgeColor("EdgeColor", Color) = (0,0,0,0)
		[Toggle]_VertexPosition("VertexPosition", Float) = 1
		_Cutoff( "Mask Clip Value", Float ) = 0.75
		_Glossiness1("Glossiness", 2D) = "white" {}
		_DissolveDirection("DissolveDirection", Vector) = (0,1,0,0)
		_UpperLimit("UpperLimit", Float) = -5
		_LowerLimit("LowerLimit", Float) = 5
		_ScaleDissolve("ScaleDissolve", Range( 0 , 1)) = 0.4301261
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
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
		uniform float _ScaleDissolve;
		uniform float _UpperLimit;
		uniform float _LowerLimit;
		uniform float3 _NoiseDirection;
		uniform float _NoiseScrollspeed;
		uniform float2 _NoiseScale;
		uniform float _EdgeThickness;
		uniform float4 _Tint;
		uniform sampler2D _Albedo;
		uniform sampler2D _Glossiness1;
		uniform float4 _Glossiness1_ST;
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
			float3 ase_worldPos = i.worldPos;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 normalizeResult154 = normalize( (( _VertexPosition )?( ase_vertex3Pos ):( ase_worldPos )) );
			float3 normalizeResult131 = normalize( _DissolveDirection );
			float dotResult130 = dot( normalizeResult154 , normalizeResult131 );
			float Fade29 = ( dotResult130 + (-_UpperLimit + (_ScaleDissolve - 0.0) * (-_LowerLimit - -_UpperLimit) / (1.0 - 0.0)) );
			float3 normalizeResult153 = normalize( _NoiseDirection );
			float simplePerlin3D62 = snoise( ( ase_vertex3Pos + ( ( normalizeResult153 * _NoiseScrollspeed ) * _Time.y ) )*_NoiseScale.x );
			simplePerlin3D62 = simplePerlin3D62*0.5 + 0.5;
			float Noise69 = simplePerlin3D62;
			float temp_output_60_0 = ( ( ( 1.0 - Fade29 ) * Noise69 ) - Fade29 );
			float2 uv_Glossiness1 = i.uv_texcoord * _Glossiness1_ST.xy + _Glossiness1_ST.zw;
			c.rgb = ( _Tint * tex2D( _Albedo, i.uv_texcoord ) * tex2D( _Glossiness1, uv_Glossiness1 ) ).rgb;
			c.a = 1;
			clip( temp_output_60_0 - _Cutoff );
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
			float3 normalizeResult154 = normalize( (( _VertexPosition )?( ase_vertex3Pos ):( ase_worldPos )) );
			float3 normalizeResult131 = normalize( _DissolveDirection );
			float dotResult130 = dot( normalizeResult154 , normalizeResult131 );
			float Fade29 = ( dotResult130 + (-_UpperLimit + (_ScaleDissolve - 0.0) * (-_LowerLimit - -_UpperLimit) / (1.0 - 0.0)) );
			float3 normalizeResult153 = normalize( _NoiseDirection );
			float simplePerlin3D62 = snoise( ( ase_vertex3Pos + ( ( normalizeResult153 * _NoiseScrollspeed ) * _Time.y ) )*_NoiseScale.x );
			simplePerlin3D62 = simplePerlin3D62*0.5 + 0.5;
			float Noise69 = simplePerlin3D62;
			float temp_output_60_0 = ( ( ( 1.0 - Fade29 ) * Noise69 ) - Fade29 );
			o.Emission = ( _EdgeColor * step( temp_output_60_0 , ( _EdgeThickness + (0.0 + (0.0 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) ) ) ).rgb;
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
				surfIN.worldPos = worldPos;
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
195;171;1307;486;2377.693;-261.5823;1.52606;True;False
Node;AmplifyShaderEditor.CommentaryNode;30;-3440,802;Inherit;False;1738.878;722.5874;Comment;14;29;18;53;130;145;131;146;51;52;122;101;149;147;154;Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;100;-3584,-510;Inherit;False;1987.844;732.4697;Comment;11;94;62;69;96;89;93;95;92;151;152;153;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;149;-3360,1042;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;151;-3536,-238;Inherit;False;Property;_NoiseDirection;NoiseDirection;2;0;Create;True;0;0;False;0;0,1,0;0,0,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;101;-3360,898;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;52;-3424,1330;Inherit;False;Property;_LowerLimit;LowerLimit;12;0;Create;True;0;0;False;0;5;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-3472,-30;Inherit;False;Property;_NoiseScrollspeed;NoiseScrollspeed;3;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-3408,1218;Inherit;False;Property;_UpperLimit;UpperLimit;11;0;Create;True;0;0;False;0;-5;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;147;-3088,882;Inherit;False;Property;_VertexPosition;VertexPosition;7;0;Create;True;0;0;False;0;1;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;153;-3344,-174;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;122;-3056,1122;Inherit;False;Property;_DissolveDirection;DissolveDirection;10;0;Create;True;0;0;False;0;0,1,0;0,0,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;131;-2832,1138;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;173;-3296,1778;Inherit;False;Property;_ScaleDissolve;ScaleDissolve;13;0;Create;True;0;0;False;0;0.4301261;0.01786518;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;154;-2800,914;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;146;-3232,1330;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;145;-3232,1234;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;-3152,-158;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TimeNode;89;-3472,66;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-3088,-46;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;130;-2576,1138;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;93;-3488,-430;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;53;-2592,1410;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;92;-2912,-318;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;94;-2720,-62;Inherit;False;Property;_NoiseScale;NoiseScale;4;0;Create;True;0;0;False;0;2,2;5,5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-2272,1170;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;62;-2496,-334;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-1984,1170;Inherit;True;Fade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-1824,-206;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-1440,338;Inherit;True;29;Fade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;32;-1120,322;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;54;-1104,1154;Inherit;False;820.2998;637.5504;GLow;5;45;47;46;44;49;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-1408,530;Inherit;True;69;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-1104,1330;Inherit;False;Property;_EdgeThickness;EdgeThickness;5;0;Create;True;0;0;False;0;0;0.3;0;0.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;74;-1392,770;Inherit;True;29;Fade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-848,338;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;45;-1056,1458;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;60;-576,578;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;85;-1056,2;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-864,1442;Inherit;True;2;2;0;FLOAT;0.01;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;43;-800,-94;Inherit;True;Property;_Albedo;Albedo;0;0;Create;True;0;0;False;0;-1;None;58e4b22313f014c408a7a87146bcf8b5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;44;-624,1282;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;177;-800,98;Inherit;True;Property;_Glossiness1;Glossiness;9;0;Create;True;0;0;False;0;-1;ab611d0bba8a0334ca5fac9eaaf7419f;ab611d0bba8a0334ca5fac9eaaf7419f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;49;-624,1586;Inherit;False;Property;_EdgeColor;EdgeColor;6;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0.7125139,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;83;-768,-286;Inherit;False;Property;_Tint;Tint;1;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-336,-190;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;176;-3200,1618;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;172;-3072,1570;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;175;-3392,1618;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;171;-3664,1602;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-160,1410;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;698.5323,14.72532;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;DirectionalDissolve;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.75;True;True;0;False;TransparentCutout;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;8;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;147;0;101;0
WireConnection;147;1;149;0
WireConnection;153;0;151;0
WireConnection;131;0;122;0
WireConnection;154;0;147;0
WireConnection;146;0;52;0
WireConnection;145;0;51;0
WireConnection;152;0;153;0
WireConnection;152;1;96;0
WireConnection;95;0;152;0
WireConnection;95;1;89;2
WireConnection;130;0;154;0
WireConnection;130;1;131;0
WireConnection;53;0;173;0
WireConnection;53;3;145;0
WireConnection;53;4;146;0
WireConnection;92;0;93;0
WireConnection;92;1;95;0
WireConnection;18;0;130;0
WireConnection;18;1;53;0
WireConnection;62;0;92;0
WireConnection;62;1;94;0
WireConnection;29;0;18;0
WireConnection;69;0;62;0
WireConnection;32;0;31;0
WireConnection;57;0;32;0
WireConnection;57;1;70;0
WireConnection;60;0;57;0
WireConnection;60;1;74;0
WireConnection;46;0;47;0
WireConnection;46;1;45;0
WireConnection;43;1;85;0
WireConnection;44;0;60;0
WireConnection;44;1;46;0
WireConnection;84;0;83;0
WireConnection;84;1;43;0
WireConnection;84;2;177;0
WireConnection;176;0;175;0
WireConnection;175;0;171;4
WireConnection;50;0;49;0
WireConnection;50;1;44;0
WireConnection;0;2;50;0
WireConnection;0;10;60;0
WireConnection;0;13;84;0
ASEEND*/
//CHKSM=F7448194FA51A68246BAF065E828259E3D7522F1