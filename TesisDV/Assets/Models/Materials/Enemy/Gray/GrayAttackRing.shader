// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "GrayAttackRing"
{
	Properties
	{
		_Scale("Scale", Range( 0 , 1)) = 1
		_Power("Power", Float) = 8.39
		_Bias("Bias", Range( 0 , 1)) = 1
		_NoiseDirection("NoiseDirection", Vector) = (0,1,0,0)
		_NoiseDirection3("NoiseDirection", Vector) = (0,1,0,0)
		_NoiseDirection4("NoiseDirection", Vector) = (0,1,0,0)
		_NoiseScale("NoiseScale", Vector) = (2,2,0,0)
		_NoiseScale3("NoiseScale", Vector) = (2,2,0,0)
		_NoiseScale4("NoiseScale", Vector) = (2,2,0,0)
		_ColorTint("ColorTint", Color) = (0,0.9657865,1,0)
		_NoiseScrollspeed("NoiseScrollspeed", Float) = 1
		_NoiseScrollspeed3("NoiseScrollspeed", Float) = 1
		_NoiseScrollspeed4("NoiseScrollspeed", Float) = 1
		_LerpNoisesXZ("LerpNoisesXZ", Range( 0 , 1)) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float3 viewDir;
			float3 worldNormal;
		};

		uniform float3 _NoiseDirection3;
		uniform float _NoiseScrollspeed3;
		uniform float2 _NoiseScale3;
		uniform float3 _NoiseDirection4;
		uniform float _NoiseScrollspeed4;
		uniform float2 _NoiseScale4;
		uniform float _LerpNoisesXZ;
		uniform float4 _ColorTint;
		uniform float _Bias;
		uniform float _Scale;
		uniform float _Power;
		uniform float3 _NoiseDirection;
		uniform float _NoiseScrollspeed;
		uniform float2 _NoiseScale;


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


		float2 voronoihash51( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi51( float2 v, float time, inout float2 id, float smoothness )
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
			 		float2 o = voronoihash51( n + g );
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


		float2 voronoihash66( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi66( float2 v, float time, inout float2 id, float smoothness )
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
			 		float2 o = voronoihash66( n + g );
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


		float2 voronoihash19( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi19( float2 v, float time, inout float2 id, float smoothness )
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
			 		float2 o = voronoihash19( n + g );
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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 normalizeResult44 = normalize( _NoiseDirection3 );
			float3 temp_output_50_0 = ( ase_vertex3Pos.y + ( ( normalizeResult44 * _NoiseScrollspeed3 ) * _Time.y ) );
			float simplePerlin3D52 = snoise( temp_output_50_0*_NoiseScale3.x );
			simplePerlin3D52 = simplePerlin3D52*0.5 + 0.5;
			float time51 = 0.0;
			float2 coords51 = temp_output_50_0.xy * _NoiseScale3.x;
			float2 id51 = 0;
			float voroi51 = voronoi51( coords51, time51,id51, 0 );
			float NoiseY54 = ( simplePerlin3D52 + voroi51 );
			float3 normalizeResult58 = normalize( _NoiseDirection4 );
			float3 temp_output_65_0 = ( ase_vertex3Pos.z + ( ( normalizeResult58 * _NoiseScrollspeed4 ) * _Time.y ) );
			float simplePerlin3D67 = snoise( temp_output_65_0*_NoiseScale4.x );
			simplePerlin3D67 = simplePerlin3D67*0.5 + 0.5;
			float time66 = 0.0;
			float2 coords66 = temp_output_65_0.xy * _NoiseScale4.x;
			float2 id66 = 0;
			float voroi66 = voronoi66( coords66, time66,id66, 0 );
			float NoiseZ69 = ( simplePerlin3D67 + voroi66 );
			float lerpResult71 = lerp( NoiseY54 , NoiseZ69 , _LerpNoisesXZ);
			float3 temp_cast_6 = (lerpResult71).xxx;
			v.vertex.xyz += temp_cast_6;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV5 = dot( ase_worldNormal, i.viewDir );
			float fresnelNode5 = ( _Bias + _Scale * pow( 1.0 - fresnelNdotV5, _Power ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 normalizeResult11 = normalize( _NoiseDirection );
			float3 temp_output_18_0 = ( ase_vertex3Pos.z + ( ( normalizeResult11 * _NoiseScrollspeed ) * _Time.y ) );
			float simplePerlin3D20 = snoise( temp_output_18_0*_NoiseScale.x );
			simplePerlin3D20 = simplePerlin3D20*0.5 + 0.5;
			float time19 = 0.0;
			float2 coords19 = temp_output_18_0.xy * _NoiseScale.x;
			float2 id19 = 0;
			float voroi19 = voronoi19( coords19, time19,id19, 0 );
			float Noise22 = ( simplePerlin3D20 + voroi19 );
			float4 temp_output_7_0 = ( _ColorTint * fresnelNode5 * Noise22 );
			o.Emission = temp_output_7_0.rgb;
			o.Alpha = temp_output_7_0.b;
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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
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
181;200;1354;546;1460.672;362.5115;1.3;True;False
Node;AmplifyShaderEditor.CommentaryNode;9;-3847.433,-1433.978;Inherit;False;1987.844;732.4697;Comment;13;22;21;20;19;18;17;16;15;14;13;12;11;10;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;10;-3799.432,-1161.978;Inherit;False;Property;_NoiseDirection;NoiseDirection;4;0;Create;True;0;0;False;0;0,1,0;0,0,-1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;41;-4014.032,-195.8446;Inherit;False;1987.844;732.4697;Comment;13;54;53;52;51;50;49;48;47;46;45;44;43;42;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;56;-4019.838,631.4219;Inherit;False;1987.844;732.4697;Comment;13;69;68;67;66;65;64;63;62;61;60;59;58;57;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.NormalizeNode;11;-3607.432,-1097.978;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-3735.432,-952.3275;Inherit;False;Property;_NoiseScrollspeed;NoiseScrollspeed;11;0;Create;True;0;0;False;0;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;42;-3966.03,76.15539;Inherit;False;Property;_NoiseDirection3;NoiseDirection;5;0;Create;True;0;0;False;0;0,1,0;0,-1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;57;-3971.836,903.4219;Inherit;False;Property;_NoiseDirection4;NoiseDirection;6;0;Create;True;0;0;False;0;0,1,0;0,-1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-3415.432,-1081.978;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TimeNode;14;-3735.432,-857.9778;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;59;-3907.836,1113.072;Inherit;False;Property;_NoiseScrollspeed4;NoiseScrollspeed;13;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;58;-3779.837,967.4219;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;44;-3774.031,140.1554;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-3902.03,285.8059;Inherit;False;Property;_NoiseScrollspeed3;NoiseScrollspeed;12;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;16;-3751.432,-1353.978;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-3240.775,-981.2691;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-3582.031,156.1554;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TimeNode;46;-3902.03,380.1557;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TimeNode;61;-3907.836,1207.422;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-3587.837,983.4219;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-3413.18,1084.131;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-3175.432,-1241.978;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;63;-3923.836,711.4219;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-3407.374,256.8643;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;48;-3918.03,-115.8446;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;17;-2983.432,-985.9778;Inherit;False;Property;_NoiseScale;NoiseScale;7;0;Create;True;0;0;False;0;2,2;-3,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.NoiseGeneratorNode;20;-2797.595,-1245.927;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-3347.837,823.4219;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;64;-3155.837,1079.422;Inherit;False;Property;_NoiseScale4;NoiseScale;9;0;Create;True;0;0;False;0;2,2;-3,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;49;-3150.031,252.1557;Inherit;False;Property;_NoiseScale3;NoiseScale;8;0;Create;True;0;0;False;0;2,2;-3,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-3342.031,-3.844602;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VoronoiNode;19;-2856.213,-1385.76;Inherit;False;0;0;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.VoronoiNode;51;-3022.812,-147.6266;Inherit;False;0;0;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.NoiseGeneratorNode;52;-2964.194,-7.793576;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;66;-3028.618,679.64;Inherit;False;0;0;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-2464.534,-1188.917;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;67;-2970,819.4729;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;2;-1355.989,-86.36119;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;68;-2636.939,876.4829;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-2087.432,-1129.978;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1463.266,207.4283;Inherit;False;Property;_Scale;Scale;1;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-2631.133,49.21643;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1508.69,88.16607;Inherit;False;Property;_Bias;Bias;3;0;Create;True;0;0;False;0;1;0.083;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-1329.469,318.3311;Inherit;False;Property;_Power;Power;2;0;Create;True;0;0;False;0;8.39;0.58;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;5;-1082.781,-36.22902;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;2;False;2;FLOAT;2.75;False;3;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-976.152,-219.6994;Inherit;False;22;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-2259.837,931.8747;Inherit;False;NoiseZ;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-2254.031,104.6082;Inherit;False;NoiseY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;6;-937.638,-486.8479;Inherit;False;Property;_ColorTint;ColorTint;10;0;Create;True;0;0;False;0;0,0.9657865,1,0;0,0.9657865,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;70;-755.4915,323.6586;Inherit;False;69;NoiseZ;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-750.0804,216.772;Inherit;False;54;NoiseY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-792.0723,425.9816;Inherit;False;Property;_LerpNoisesXZ;LerpNoisesXZ;14;0;Create;True;0;0;False;0;0;0.631;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-731.0994,-252.0566;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;71;-497.4658,232.5907;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.79;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;25;-467.792,-103.571;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-4,-155;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;GrayAttackRing;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;5;True;True;0;True;Transparent;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;11;0;10;0
WireConnection;13;0;11;0
WireConnection;13;1;12;0
WireConnection;58;0;57;0
WireConnection;44;0;42;0
WireConnection;15;0;13;0
WireConnection;15;1;14;2
WireConnection;45;0;44;0
WireConnection;45;1;43;0
WireConnection;60;0;58;0
WireConnection;60;1;59;0
WireConnection;62;0;60;0
WireConnection;62;1;61;2
WireConnection;18;0;16;3
WireConnection;18;1;15;0
WireConnection;47;0;45;0
WireConnection;47;1;46;2
WireConnection;20;0;18;0
WireConnection;20;1;17;0
WireConnection;65;0;63;3
WireConnection;65;1;62;0
WireConnection;50;0;48;2
WireConnection;50;1;47;0
WireConnection;19;0;18;0
WireConnection;19;2;17;0
WireConnection;51;0;50;0
WireConnection;51;2;49;0
WireConnection;52;0;50;0
WireConnection;52;1;49;0
WireConnection;66;0;65;0
WireConnection;66;2;64;0
WireConnection;21;0;20;0
WireConnection;21;1;19;0
WireConnection;67;0;65;0
WireConnection;67;1;64;0
WireConnection;68;0;67;0
WireConnection;68;1;66;0
WireConnection;22;0;21;0
WireConnection;53;0;52;0
WireConnection;53;1;51;0
WireConnection;5;4;2;0
WireConnection;5;1;3;0
WireConnection;5;2;4;0
WireConnection;5;3;1;0
WireConnection;69;0;68;0
WireConnection;54;0;53;0
WireConnection;7;0;6;0
WireConnection;7;1;5;0
WireConnection;7;2;23;0
WireConnection;71;0;55;0
WireConnection;71;1;70;0
WireConnection;71;2;72;0
WireConnection;25;0;7;0
WireConnection;0;2;7;0
WireConnection;0;9;25;2
WireConnection;0;11;71;0
ASEEND*/
//CHKSM=685EB88131502D87C6DFC289704008A6CD211320