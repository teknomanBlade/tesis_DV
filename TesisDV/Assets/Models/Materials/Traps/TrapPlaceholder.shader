// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TrapPlaceholder"
{
	Properties
	{
		_Placeholder("Placeholder", 2D) = "white" {}
		_Indicator("Indicator", 2D) = "white" {}
		_Indicator1("Indicator", 2D) = "white" {}
		_Indicator2("Indicator", 2D) = "white" {}
		_Float0("Float 0", Float) = 0
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
			float2 uv_texcoord;
		};

		uniform sampler2D _Indicator2;
		uniform float _Float0;
		uniform sampler2D _Indicator;
		uniform sampler2D _Indicator1;
		uniform sampler2D _Placeholder;
		uniform float4 _Placeholder_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 color27 = IsGammaSpace() ? float4(0.093871,1,0,0) : float4(0.009097841,1,0,0);
			float mulTime8 = _Time.y * _Float0;
			float DopplerEffect39 = ( distance( i.uv_texcoord , float2( 0.5,0.5 ) ) + sin( mulTime8 ) );
			float2 temp_cast_0 = (DopplerEffect39).xx;
			float4 tex2DNode49 = tex2D( _Indicator2, temp_cast_0 );
			float2 temp_cast_1 = (DopplerEffect39).xx;
			float4 tex2DNode3 = tex2D( _Indicator, temp_cast_1 );
			float2 temp_cast_2 = (DopplerEffect39).xx;
			float4 tex2DNode47 = tex2D( _Indicator1, temp_cast_2 );
			float2 uv_Placeholder = i.uv_texcoord * _Placeholder_ST.xy + _Placeholder_ST.zw;
			float4 tex2DNode2 = tex2D( _Placeholder, uv_Placeholder );
			float4 temp_output_29_0 = saturate( ( color27 * ( ( tex2DNode49 + tex2DNode3 + tex2DNode47 ) + tex2DNode2 ) ) );
			o.Albedo = temp_output_29_0.rgb;
			o.Emission = temp_output_29_0.rgb;
			o.Alpha = ( tex2DNode49.a + tex2DNode3.a + tex2DNode47.a + tex2DNode2.a );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
312;472;1137;628;1499.277;586.6524;2.022778;True;False
Node;AmplifyShaderEditor.RangedFloatNode;45;-3948.772,-76.36526;Inherit;False;Property;_Float0;Float 0;4;0;Create;True;0;0;False;0;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;34;-3918.681,267.9464;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;8;-3659.252,-73.3474;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;35;-3764.944,417.4091;Inherit;False;Constant;_Vector0;Vector 0;2;0;Create;True;0;0;False;0;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SinOpNode;6;-3457.827,-40.5219;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;36;-3516.007,245.3736;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-3236.772,164.6347;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-3012.447,223.1728;Inherit;False;DopplerEffect;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-2369.733,-718.27;Inherit;False;39;DopplerEffect;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-2355.243,-421.5974;Inherit;False;39;DopplerEffect;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-2389.658,-146.4281;Inherit;False;39;DopplerEffect;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;47;-2045.83,-161.3026;Inherit;True;Property;_Indicator1;Indicator;2;0;Create;True;0;0;False;0;-1;None;44f905cfbf13fbe48991001d36170daf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-2011.415,-436.472;Inherit;True;Property;_Indicator;Indicator;1;0;Create;True;0;0;False;0;-1;None;44f905cfbf13fbe48991001d36170daf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;49;-2025.905,-737.1867;Inherit;True;Property;_Indicator2;Indicator;3;0;Create;True;0;0;False;0;-1;None;44f905cfbf13fbe48991001d36170daf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-1534.195,-286.3784;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;-1620.869,146.856;Inherit;True;Property;_Placeholder;Placeholder;0;0;Create;True;0;0;False;0;-1;None;bdd2e906e0f111f4f9ed48a619b22c30;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;27;-1252.977,-666.1109;Inherit;False;Constant;_Color0;Color 0;4;0;Create;True;0;0;False;0;0.093871,1,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;62;-1256.544,-271.0991;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-952.9717,-333.8256;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-900.058,43.26435;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;29;-338.4923,-127.4858;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;TrapPlaceholder;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;8;0;45;0
WireConnection;6;0;8;0
WireConnection;36;0;34;0
WireConnection;36;1;35;0
WireConnection;44;0;36;0
WireConnection;44;1;6;0
WireConnection;39;0;44;0
WireConnection;47;1;48;0
WireConnection;3;1;40;0
WireConnection;49;1;50;0
WireConnection;61;0;49;0
WireConnection;61;1;3;0
WireConnection;61;2;47;0
WireConnection;62;0;61;0
WireConnection;62;1;2;0
WireConnection;57;0;27;0
WireConnection;57;1;62;0
WireConnection;30;0;49;4
WireConnection;30;1;3;4
WireConnection;30;2;47;4
WireConnection;30;3;2;4
WireConnection;29;0;57;0
WireConnection;0;0;29;0
WireConnection;0;2;29;0
WireConnection;0;9;30;0
ASEEND*/
//CHKSM=3A4046E66F995B557DFBA1CDA3FA3BEBE8F41819