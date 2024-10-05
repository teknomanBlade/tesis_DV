// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SDR_UIInteractions"
{
	Properties
	{
		_DamageColor("DamageColor", Color) = (1,0,0,0)
		_FadeColor("FadeColor", Color) = (1,0,0,0)
		_TransitionColorVal("TransitionColorVal", Range( 0 , 1)) = 0
		_AlphaTransitionVal("AlphaTransitionVal", Range( 0 , 1)) = 0
		_MainTexture("MainTexture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform float4 _DamageColor;
		uniform float _TransitionColorVal;
		uniform float4 _FadeColor;
		uniform float _AlphaTransitionVal;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float4 tex2DNode9 = tex2D( _MainTexture, uv_MainTexture );
			float4 lerpResult3 = lerp( _DamageColor , tex2DNode9 , _TransitionColorVal);
			o.Emission = ( tex2DNode9 * lerpResult3 ).rgb;
			float4 temp_cast_1 = (tex2DNode9.a).xxxx;
			float4 lerpResult6 = lerp( temp_cast_1 , _FadeColor , _AlphaTransitionVal);
			o.Alpha = ( tex2DNode9.a * lerpResult6 ).r;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
269;513;1195;506;1253.196;297.0984;1.002987;True;False
Node;AmplifyShaderEditor.RangedFloatNode;4;-696.095,222.4311;Inherit;False;Property;_TransitionColorVal;TransitionColorVal;3;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;-726.9745,-8.934072;Inherit;False;Property;_DamageColor;DamageColor;1;0;Create;True;0;0;False;0;1,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;9;-889.7581,-456.0865;Inherit;True;Property;_MainTexture;MainTexture;5;0;Create;True;0;0;False;0;-1;None;132809d820192eb4e98eed71d6765e46;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;8;-717.3301,348.9319;Inherit;False;Property;_FadeColor;FadeColor;2;0;Create;True;0;0;False;0;1,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-764.5714,549.5182;Inherit;False;Property;_AlphaTransitionVal;AlphaTransitionVal;4;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;3;-370.1423,-61.09795;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;6;-265.2579,294.9562;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-123.7266,-350.5224;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;133.966,50.2051;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;597.1849,-372.0339;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;SDR_UIInteractions;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;1;0
WireConnection;3;1;9;0
WireConnection;3;2;4;0
WireConnection;6;0;9;4
WireConnection;6;1;8;0
WireConnection;6;2;5;0
WireConnection;12;0;9;0
WireConnection;12;1;3;0
WireConnection;13;0;9;4
WireConnection;13;1;6;0
WireConnection;0;2;12;0
WireConnection;0;9;13;0
ASEEND*/
//CHKSM=9103C43050378039A7D915F66FF84BDCF4EA7F4B