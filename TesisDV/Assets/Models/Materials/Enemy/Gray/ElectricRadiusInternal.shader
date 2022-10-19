// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ElectricRadiusInternal"
{
	Properties
	{
		_Scale1("Scale", Range( 0 , 1)) = 1
		_Power1("Power", Float) = 8.39
		_Bias1("Bias", Range( 0 , 1)) = 1
		_Speed1("Speed", Vector) = (0.4,0,0,0)
		_NoiseDirection1("NoiseDirection", Vector) = (0,1,0,0)
		_NoiseScale1("NoiseScale", Vector) = (2,2,0,0)
		_NoiseScrollspeed1("NoiseScrollspeed", Float) = 1
		_TextureSample1("Texture Sample 0", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
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

		uniform float3 _NoiseDirection1;
		uniform float _NoiseScrollspeed1;
		uniform float2 _NoiseScale1;
		uniform sampler2D _TextureSample1;
		uniform float2 _Speed1;
		uniform float _Bias1;
		uniform float _Scale1;
		uniform float _Power1;


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
			float3 normalizeResult41 = normalize( _NoiseDirection1 );
			float simplePerlin3D52 = snoise( ( ase_vertex3Pos + ( ( normalizeResult41 * _NoiseScrollspeed1 ) * _Time.y ) )*_NoiseScale1.x );
			simplePerlin3D52 = simplePerlin3D52*0.5 + 0.5;
			float2 uv_TexCoord46 = i.uv_texcoord * float2( 25,25 ) + float2( 1,1 );
			float2 panner49 = ( 1.73 * _Time.y * _Speed1 + uv_TexCoord46);
			float Noise54 = ( simplePerlin3D52 + tex2D( _TextureSample1, panner49 ).a );
			float4 color63 = IsGammaSpace() ? float4(0,0.9657865,1,0) : float4(0,0.9239276,1,0);
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV60 = dot( ase_worldNormal, i.viewDir );
			float fresnelNode60 = ( _Bias1 + _Scale1 * pow( 1.0 - fresnelNdotV60, _Power1 ) );
			float4 temp_output_65_0 = ( Noise54 * color63 * fresnelNode60 );
			o.Emission = saturate( temp_output_65_0 ).rgb;
			o.Alpha = saturate( fresnelNode60 );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
104;459;1137;590;670.2407;167.2746;2.221191;True;False
Node;AmplifyShaderEditor.CommentaryNode;38;-3074.704,-842.5598;Inherit;False;1987.844;732.4697;Comment;12;54;53;52;50;48;45;44;43;42;41;40;39;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;39;-3026.703,-570.5598;Inherit;False;Property;_NoiseDirection1;NoiseDirection;4;0;Create;True;0;0;False;0;0,1,0;-1,-1,-1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;41;-2834.703,-506.5594;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-2962.703,-360.9089;Inherit;False;Property;_NoiseScrollspeed1;NoiseScrollspeed;6;0;Create;True;0;0;False;0;1;1.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;42;-2962.703,-266.5591;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-2642.703,-490.5594;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-2468.046,-389.8506;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;46;-2486.744,-1193.73;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;25,25;False;1;FLOAT2;1,1;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;45;-2978.703,-762.5598;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;47;-2352.494,-934.3991;Inherit;False;Property;_Speed1;Speed;3;0;Create;True;0;0;False;0;0.4,0;2,2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;49;-2218.372,-1096.358;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1.73;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-2402.703,-650.5599;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;48;-2210.703,-394.5592;Inherit;False;Property;_NoiseScale1;NoiseScale;5;0;Create;True;0;0;False;0;2,2;5,15;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;51;-2035.909,-890.7319;Inherit;True;Property;_TextureSample1;Texture Sample 0;9;0;Create;True;0;0;False;0;-1;None;407fc663a9e538845b3edbe8c35049f2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;52;-2017.564,-607.0489;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-1691.805,-597.4985;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-557.9757,514.3462;Inherit;False;Property;_Power1;Power;1;0;Create;True;0;0;False;0;8.39;6.85;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;58;-672.6124,74.73937;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;57;-825.3136,249.2666;Inherit;False;Property;_Bias1;Bias;2;0;Create;True;0;0;False;0;1;0.242;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-779.8895,368.5289;Inherit;False;Property;_Scale1;Scale;0;0;Create;True;0;0;False;0;1;0.017;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-1314.703,-538.5594;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;63;-98.69121,-235.8558;Inherit;False;Constant;_Color1;Color 0;4;0;Create;True;0;0;False;0;0,0.9657865,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;60;-276.3733,159.7858;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;2;False;2;FLOAT;2.75;False;3;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;-307.6665,-39.59119;Inherit;False;54;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;293.0317,-9.211496;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;56;-214.6916,704.4193;Inherit;False;820.2998;637.5504;GLow;5;68;67;66;64;61;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;68;265.3084,1136.419;Inherit;False;Property;_EdgeColor1;EdgeColor;8;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0.7215686,1.003922,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;71;928.2427,-31.11744;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;69;540.0129,374.8015;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-155.4994,833.4963;Inherit;False;Property;_EdgeThickness1;EdgeThickness;7;0;Create;True;0;0;False;0;0;0;0;0.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;64;-166.6913,1008.419;Inherit;False;5;0;FLOAT;5;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;794.7737,893.1084;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;25.30867,992.4194;Inherit;True;2;2;0;FLOAT;0.01;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;67;265.3084,832.4193;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1340.159,38.34179;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;ElectricRadiusInternal;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.22;True;False;0;True;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;41;0;39;0
WireConnection;43;0;41;0
WireConnection;43;1;40;0
WireConnection;44;0;43;0
WireConnection;44;1;42;2
WireConnection;49;0;46;0
WireConnection;49;2;47;0
WireConnection;50;0;45;0
WireConnection;50;1;44;0
WireConnection;51;1;49;0
WireConnection;52;0;50;0
WireConnection;52;1;48;0
WireConnection;53;0;52;0
WireConnection;53;1;51;4
WireConnection;54;0;53;0
WireConnection;60;4;58;0
WireConnection;60;1;57;0
WireConnection;60;2;59;0
WireConnection;60;3;55;0
WireConnection;65;0;62;0
WireConnection;65;1;63;0
WireConnection;65;2;60;0
WireConnection;71;0;65;0
WireConnection;69;0;60;0
WireConnection;70;0;68;0
WireConnection;70;1;67;0
WireConnection;66;0;61;0
WireConnection;66;1;64;0
WireConnection;67;0;65;0
WireConnection;67;1;66;0
WireConnection;0;2;71;0
WireConnection;0;9;69;0
ASEEND*/
//CHKSM=CB6E0A7DFEF5D15AC7CC66EFD59DB3DF774737FF