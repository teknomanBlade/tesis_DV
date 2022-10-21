// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Circuit Lines"
{
	Properties
	{
		_TextureSample0("Texture", 2D) = "white" {}
		_Min("Min", Float) = 0
		_Max("Max", Float) = 0
		[HDR]_Color0("Color 0", Color) = (0,0,0,0)
		_Progress("Progress", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _Color0;
		uniform float _Min;
		uniform float _Max;
		uniform sampler2D _TextureSample0;
		uniform float4 _TextureSample0_ST;
		uniform float _Progress;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float temp_output_9_0 = min( _Min , _Max );
			float temp_output_10_0 = max( _Max , _Min );
			float2 uv_TextureSample0 = i.uv_texcoord * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
			float4 tex2DNode2 = tex2D( _TextureSample0, uv_TextureSample0 );
			float temp_output_17_0 = saturate( ( tex2DNode2.r - _Progress ) );
			float smoothstepResult4 = smoothstep( temp_output_9_0 , temp_output_10_0 , temp_output_17_0);
			float smoothstepResult12 = smoothstep( temp_output_9_0 , temp_output_10_0 , ( 1.0 - temp_output_17_0 ));
			o.Emission = ( _Color0 * ( ( smoothstepResult4 * smoothstepResult12 ) * ( 1.0 - tex2DNode2.g ) ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
789;280;1137;548;2434.47;497.0539;2.995845;True;False
Node;AmplifyShaderEditor.RangedFloatNode;16;-1121.822,249.564;Inherit;False;Property;_Progress;Progress;4;0;Create;True;0;0;False;0;0;-0.16;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-1432.328,143.2436;Inherit;True;Property;_TextureSample0;Texture;0;0;Create;True;0;0;False;0;-1;None;5abce3c07b3b47949b515f7c4e4c1364;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;-939.5022,145.4507;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1324.116,607.588;Inherit;False;Property;_Max;Max;2;0;Create;True;0;0;False;0;0;0.383;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1318.116,523.5886;Inherit;False;Property;_Min;Min;1;0;Create;True;0;0;False;0;0;0.215;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;17;-792.6611,156.0339;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;10;-987.115,614.588;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;9;-986.115,511.5886;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;11;-642.3182,323.7615;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;4;-413.8523,295.9261;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;12;-453,580.5;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-156,405.5;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;18;130.3969,481.3841;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;14;-186.1384,29.70761;Inherit;False;Property;_Color0;Color 0;3;1;[HDR];Create;True;0;0;False;0;0,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;328.0615,241.5043;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;138,114.5;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-1826.479,383.4567;Inherit;False;Property;_Speed;Speed;5;0;Create;True;0;0;False;0;0;1.26;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;21;-1685.253,361.5723;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;20;-1590.033,540.4192;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;614.1133,139.0301;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Circuit Lines;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;15;0;2;1
WireConnection;15;1;16;0
WireConnection;17;0;15;0
WireConnection;10;0;8;0
WireConnection;10;1;5;0
WireConnection;9;0;5;0
WireConnection;9;1;8;0
WireConnection;11;0;17;0
WireConnection;4;0;17;0
WireConnection;4;1;9;0
WireConnection;4;2;10;0
WireConnection;12;0;11;0
WireConnection;12;1;9;0
WireConnection;12;2;10;0
WireConnection;13;0;4;0
WireConnection;13;1;12;0
WireConnection;18;0;2;2
WireConnection;19;0;13;0
WireConnection;19;1;18;0
WireConnection;3;0;14;0
WireConnection;3;1;19;0
WireConnection;21;0;22;0
WireConnection;20;0;21;0
WireConnection;0;2;3;0
ASEEND*/
//CHKSM=5789E86E575AB78CD1DA27DE4F78183D5FE530A5