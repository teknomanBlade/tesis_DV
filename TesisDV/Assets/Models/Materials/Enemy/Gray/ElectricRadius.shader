// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ElectricRadius"
{
	Properties
	{
		_Scale("Scale", Range( 0 , 1)) = 1
		_Power("Power", Float) = 8.39
		_Bias("Bias", Range( 0 , 1)) = 1
		_Speed1("Speed", Vector) = (0.4,0,0,0)
		_NoiseDirection("NoiseDirection", Vector) = (0,1,0,0)
		_NoiseScale("NoiseScale", Vector) = (2,2,0,0)
		_NoiseScrollspeed("NoiseScrollspeed", Float) = 1
		_EdgeThickness("EdgeThickness", Range( 0 , 0.3)) = 0
		[HDR]_EdgeColor("EdgeColor", Color) = (0,0,0,0)
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard alpha:fade keepalpha noshadow 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float3 viewDir;
			float3 worldNormal;
		};

		uniform float3 _NoiseDirection;
		uniform float _NoiseScrollspeed;
		uniform float2 _NoiseScale;
		uniform sampler2D _TextureSample0;
		uniform float2 _Speed1;
		uniform float _Bias;
		uniform float _Scale;
		uniform float _Power;
		uniform float4 _EdgeColor;
		uniform float _EdgeThickness;


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


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 normalizeResult4 = normalize( _NoiseDirection );
			float simplePerlin3D11 = snoise( ( ase_vertex3Pos + ( ( normalizeResult4 * _NoiseScrollspeed ) * _Time.y ) )*_NoiseScale.x );
			simplePerlin3D11 = simplePerlin3D11*0.5 + 0.5;
			float2 uv_TexCoord34 = i.uv_texcoord * float2( 25,25 ) + float2( 1,1 );
			float2 panner44 = ( 1.73 * _Time.y * _Speed1 + uv_TexCoord34);
			float Noise17 = ( simplePerlin3D11 + tex2D( _TextureSample0, panner44 ).a );
			float4 color21 = IsGammaSpace() ? float4(0,0.9657865,1,0) : float4(0,0.9239276,1,0);
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV22 = dot( ase_worldNormal, i.viewDir );
			float fresnelNode22 = ( _Bias + _Scale * pow( 1.0 - fresnelNdotV22, _Power ) );
			float4 temp_output_25_0 = ( Noise17 * color21 * fresnelNode22 );
			o.Albedo = saturate( temp_output_25_0 ).rgb;
			float4 temp_cast_2 = (( _EdgeThickness + (0.0 + (5.0 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) )).xxxx;
			o.Emission = ( _EdgeColor * step( temp_output_25_0 , temp_cast_2 ) ).rgb;
			o.Alpha = saturate( fresnelNode22 );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
97;478;1354;468;1622.761;-58.63538;2.450265;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-2800.25,-551.2334;Inherit;False;1987.844;732.4697;Comment;13;17;13;11;10;9;8;7;6;5;4;3;2;43;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;2;-2752.249,-279.2333;Inherit;False;Property;_NoiseDirection;NoiseDirection;4;0;Create;True;0;0;False;0;0,1,0;0,0,-1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;3;-2688.249,-69.58249;Inherit;False;Property;_NoiseScrollspeed;NoiseScrollspeed;6;0;Create;True;0;0;False;0;1;17.83;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;4;-2560.249,-215.2329;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TimeNode;6;-2688.249,24.7673;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-2368.249,-199.2329;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-2193.592,-98.52411;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;8;-2704.249,-471.2334;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;45;-2078.04,-643.0729;Inherit;False;Property;_Speed1;Speed;3;0;Create;True;0;0;False;0;0.4,0;2,2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;34;-2212.29,-902.4034;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;25,25;False;1;FLOAT2;1,1;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;9;-1936.249,-103.2328;Inherit;False;Property;_NoiseScale;NoiseScale;5;0;Create;True;0;0;False;0;2,2;5,15;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;44;-1943.918,-805.0317;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1.73;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-2128.249,-359.2334;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;11;-1743.11,-315.7224;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;43;-1761.455,-599.4055;Inherit;True;Property;_TextureSample0;Texture Sample 0;9;0;Create;True;0;0;False;0;-1;None;407fc663a9e538845b3edbe8c35049f2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-1417.351,-306.172;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;16;59.76306,995.7459;Inherit;False;820.2998;637.5504;GLow;5;28;27;26;24;23;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-505.4349,659.8555;Inherit;False;Property;_Scale;Scale;0;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-283.5209,805.6727;Inherit;False;Property;_Power;Power;1;0;Create;True;0;0;False;0;8.39;8.41;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;15;-398.1578,366.066;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;19;-550.8589,540.5933;Inherit;False;Property;_Bias;Bias;2;0;Create;True;0;0;False;0;1;0.303;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-1040.249,-247.2329;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;22;-1.918823,451.1125;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;2;False;2;FLOAT;2.75;False;3;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;23;107.7631,1299.746;Inherit;False;5;0;FLOAT;5;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;21;175.7631,55.47071;Inherit;False;Constant;_Color0;Color 0;4;0;Create;True;0;0;False;0;0,0.9657865,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;20;-33.21191,251.7354;Inherit;False;17;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;118.9551,1124.823;Inherit;False;Property;_EdgeThickness;EdgeThickness;7;0;Create;True;0;0;False;0;0;0.3;0;0.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;567.4861,282.1151;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;299.7631,1283.746;Inherit;True;2;2;0;FLOAT;0.01;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;27;539.7628,1427.746;Inherit;False;Property;_EdgeColor;EdgeColor;8;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0.7125139,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;28;539.7628,1123.746;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;31;814.4673,666.1281;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;1069.228,1184.435;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;29;1202.697,260.2091;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1451.234,304.2911;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;ElectricRadius;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;2;0
WireConnection;5;0;4;0
WireConnection;5;1;3;0
WireConnection;7;0;5;0
WireConnection;7;1;6;2
WireConnection;44;0;34;0
WireConnection;44;2;45;0
WireConnection;10;0;8;0
WireConnection;10;1;7;0
WireConnection;11;0;10;0
WireConnection;11;1;9;0
WireConnection;43;1;44;0
WireConnection;13;0;11;0
WireConnection;13;1;43;4
WireConnection;17;0;13;0
WireConnection;22;4;15;0
WireConnection;22;1;19;0
WireConnection;22;2;18;0
WireConnection;22;3;14;0
WireConnection;25;0;20;0
WireConnection;25;1;21;0
WireConnection;25;2;22;0
WireConnection;26;0;24;0
WireConnection;26;1;23;0
WireConnection;28;0;25;0
WireConnection;28;1;26;0
WireConnection;31;0;22;0
WireConnection;30;0;27;0
WireConnection;30;1;28;0
WireConnection;29;0;25;0
WireConnection;0;0;29;0
WireConnection;0;2;30;0
WireConnection;0;9;31;0
ASEEND*/
//CHKSM=51B7B59CF3BB8C1FD1A913856863DBC34BFF0DDD