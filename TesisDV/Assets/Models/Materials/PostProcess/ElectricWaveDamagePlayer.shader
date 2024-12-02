// Made with Amplify Shader Editor v1.9.1.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ElectricWaveDamagePlayer"
{
	Properties
	{
		_MinX1("MinX", Float) = 0.37
		_ElectricDamageIntensity("ElectricDamageIntensity", Range( 0 , 1)) = 1
		_MaxX1("MaxX", Float) = 0.96
		_TimeScale("TimeScale", Float) = 2
		_Tiling("Tiling", Float) = 1.5
		_Offset("Offset", Float) = 2
		_ElectricRaysTexture("ElectricRaysTexture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		Cull Off
		ZWrite Off
		ZTest Always
		
		Pass
		{
			CGPROGRAM

			

			#pragma vertex Vert
			#pragma fragment Frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"

		
			struct ASEAttributesDefault
			{
				float3 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				
			};

			struct ASEVaryingsDefault
			{
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				float2 texcoordStereo : TEXCOORD1;
			#if STEREO_INSTANCING_ENABLED
				uint stereoTargetEyeIndex : SV_RenderTargetArrayIndex;
			#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform sampler2D _ElectricRaysTexture;
			uniform float4 _ElectricRaysTexture_ST;
			uniform float _Tiling;
			uniform float _Offset;
			uniform float _TimeScale;
			uniform float _MinX1;
			uniform float _MaxX1;
			uniform float _ElectricDamageIntensity;


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
			

			float2 TransformTriangleVertexToUV (float2 vertex)
			{
				float2 uv = (vertex + 1.0) * 0.5;
				return uv;
			}

			ASEVaryingsDefault Vert( ASEAttributesDefault v  )
			{
				ASEVaryingsDefault o;
				o.vertex = float4(v.vertex.xy, 0.0, 1.0);
				o.texcoord = TransformTriangleVertexToUV (v.vertex.xy);
#if UNITY_UV_STARTS_AT_TOP
				o.texcoord = o.texcoord * float2(1.0, -1.0) + float2(0.0, 1.0);
#endif
				o.texcoordStereo = TransformStereoScreenSpaceTex (o.texcoord, 1.0);

				v.texcoord = o.texcoordStereo;
				float4 ase_ppsScreenPosVertexNorm = float4(o.texcoordStereo,0,1);

				

				return o;
			}

			float4 Frag (ASEVaryingsDefault i  ) : SV_Target
			{
				float4 ase_ppsScreenPosFragNorm = float4(i.texcoordStereo,0,1);

				float2 uv_MainTex = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 uv_ElectricRaysTexture = i.texcoord.xy * _ElectricRaysTexture_ST.xy + _ElectricRaysTexture_ST.zw;
				float4 color26 = IsGammaSpace() ? float4(0,0.8783557,1,0) : float4(0,0.7452592,1,0);
				float2 temp_cast_0 = (_Tiling).xx;
				float2 temp_cast_1 = (_Offset).xx;
				float2 texCoord18 = i.texcoord.xy * temp_cast_0 + temp_cast_1;
				float2 temp_cast_2 = (texCoord18.y).xx;
				float mulTime19 = _Time.y * _TimeScale;
				float simplePerlin2D17 = snoise( temp_cast_2*mulTime19 );
				simplePerlin2D17 = simplePerlin2D17*0.5 + 0.5;
				float2 texCoord7 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float smoothstepResult11 = smoothstep( min( _MinX1 , _MaxX1 ) , max( _MinX1 , _MaxX1 ) , distance( texCoord7 , float2( 0.5,0.5 ) ));
				float4 lerpResult21 = lerp( tex2D( _MainTex, uv_MainTex ) , ( tex2D( _ElectricRaysTexture, uv_ElectricRaysTexture ) + ( color26 * simplePerlin2D17 ) ) , saturate( ( smoothstepResult11 * _ElectricDamageIntensity ) ));
				

				float4 color = lerpResult21;
				
				return color;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19103
Node;AmplifyShaderEditor.RangedFloatNode;23;-2039.22,-737.4163;Inherit;False;Property;_Offset;Offset;5;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1996.195,-598.894;Inherit;False;Property;_TimeScale;TimeScale;3;0;Create;True;0;0;0;False;0;False;2;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-2094.508,-874.9931;Inherit;False;Property;_Tiling;Tiling;4;0;Create;True;0;0;0;False;0;False;1.5;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-2156.983,490.2457;Inherit;False;Property;_MaxX1;MaxX;2;0;Create;True;0;0;0;False;0;False;0.96;0.96;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-2178.75,31.59192;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;5;-2075.218,165.7031;Inherit;False;Constant;_DistanceCoordinates;DistanceCoordinates;3;0;Create;True;0;0;0;False;0;False;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;6;-2147.135,420.2457;Inherit;False;Property;_MinX1;MinX;0;0;Create;True;0;0;0;False;0;False;0.37;0.37;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;10;-1830.087,16.12576;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;8;-1801.986,469.2457;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;9;-1803.986,376.2457;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;18;-1817.012,-845.9928;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.5,0.5;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;19;-1723.507,-688.0835;Inherit;True;1;0;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;26;-1452.911,-975.4301;Inherit;False;Constant;_Color0;Color 0;7;0;Create;True;0;0;0;False;0;False;0,0.8783557,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;17;-1473.546,-787.1085;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;11;-1534.218,8.972134;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1447.51,404.264;Inherit;False;Property;_ElectricDamageIntensity;ElectricDamageIntensity;1;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;25;-1217.352,-1275.772;Inherit;True;Property;_ElectricRaysTexture;ElectricRaysTexture;6;0;Create;True;0;0;0;False;0;False;-1;283a7f737a1a2394599309c328a10d42;283a7f737a1a2394599309c328a10d42;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1127.918,-724.7684;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1113.635,85.54036;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-1644.286,-360.6919;Inherit;True;Property;_TextureSample1;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-849.9132,-761.9252;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;31;-871.2143,108.0312;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;21;-486.0908,-205.1267;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;2;-2003.036,-333.3005;Inherit;False;0;0;_MainTex;Pass;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;33;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;5;ElectricWaveDamagePlayer;32139be9c1eb75640a847f011acf3bcf;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;True;7;False;;False;False;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;10;0;7;0
WireConnection;10;1;5;0
WireConnection;8;0;6;0
WireConnection;8;1;4;0
WireConnection;9;0;6;0
WireConnection;9;1;4;0
WireConnection;18;0;22;0
WireConnection;18;1;23;0
WireConnection;19;0;20;0
WireConnection;17;0;18;2
WireConnection;17;1;19;0
WireConnection;11;0;10;0
WireConnection;11;1;9;0
WireConnection;11;2;8;0
WireConnection;27;0;26;0
WireConnection;27;1;17;0
WireConnection;29;0;11;0
WireConnection;29;1;30;0
WireConnection;3;0;2;0
WireConnection;28;0;25;0
WireConnection;28;1;27;0
WireConnection;31;0;29;0
WireConnection;21;0;3;0
WireConnection;21;1;28;0
WireConnection;21;2;31;0
WireConnection;33;0;21;0
ASEEND*/
//CHKSM=524B06718DD65526BBD8F23B9DC79192DF0FB8D1