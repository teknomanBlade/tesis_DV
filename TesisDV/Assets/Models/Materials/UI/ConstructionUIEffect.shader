// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ConstructionUIEffect"
{
	Properties
	{
		_Frequency("Frequency", Float) = 0
		_FrecuencySecondary("FrecuencySecondary", Float) = 0
		_ColorPrimary("ColorPrimary", Color) = (0.06627893,1,0,0)
		_ColorTintTernary("ColorTintTernary", Color) = (0.06627893,1,0,0)
		_TimeScale("TimeScale", Float) = 0
		_TimeScaleSecondary("TimeScaleSecondary", Float) = 0
		_Opacity("Opacity", Range( 0 , 1)) = 0
		_OpacitySecondary("OpacitySecondary", Range( 0 , 1)) = 0
		_PosterizePower("PosterizePower", Float) = 0
		_Float1("Float 1", Float) = 0
		_ColorTintSecondary("ColorTintSecondary", Color) = (0.5565186,1,0.4575472,0)
		_ColorTintCuaternary("ColorTintCuaternary", Color) = (0.5565186,1,0.4575472,0)
		_Tiling("Tiling", Float) = 0
		_Offset("Offset", Float) = 0
		_ChangeIntervalScale("ChangeIntervalScale", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 4.6
		#pragma surface surf Unlit keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float4 screenPosition117;
		};

		uniform float _Tiling;
		uniform float _Offset;
		uniform float _ChangeIntervalScale;
		uniform float _Float1;
		uniform float4 _ColorTintTernary;
		uniform float _TimeScaleSecondary;
		uniform float _FrecuencySecondary;
		uniform float4 _ColorTintCuaternary;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _PosterizePower;
		uniform float4 _ColorPrimary;
		uniform float _TimeScale;
		uniform float _Frequency;
		uniform float4 _ColorTintSecondary;
		uniform float _OpacitySecondary;
		uniform float _Opacity;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float2 temp_cast_0 = (_Tiling).xx;
			float2 temp_cast_1 = (_Offset).xx;
			float2 uv_TexCoord114 = v.texcoord.xy * temp_cast_0 + temp_cast_1;
			float mulTime108 = _Time.y * _ChangeIntervalScale;
			float3 temp_cast_2 = (( uv_TexCoord114.y * sin( mulTime108 ) )).xxx;
			v.vertex.xyz += temp_cast_2;
			float4 ase_vertex4Pos = v.vertex;
			float3 vertexPos117 = ase_vertex4Pos.xyz;
			float4 ase_screenPos117 = ComputeScreenPos( UnityObjectToClipPos( vertexPos117 ) );
			o.screenPosition117 = ase_screenPos117;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float temp_output_174_0 = distance( ase_worldViewDir.y , ase_worldPos.y );
			float mulTime183 = _Time.y * _TimeScaleSecondary;
			float temp_output_177_0 = sin( ( ( temp_output_174_0 + mulTime183 ) * _FrecuencySecondary ) );
			float4 temp_output_165_0 = ( _ColorTintCuaternary * ( 1.0 - temp_output_177_0 ) );
			float div169=256.0/float((int)_Float1);
			float4 posterize169 = ( floor( ( ( _ColorTintTernary * temp_output_177_0 ) + temp_output_165_0 ) * div169 ) / div169 );
			float4 ase_screenPos117 = i.screenPosition117;
			float4 ase_screenPosNorm117 = ase_screenPos117 / ase_screenPos117.w;
			ase_screenPosNorm117.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm117.z : ase_screenPosNorm117.z * 0.5 + 0.5;
			float temp_output_11_0 = distance( ase_worldViewDir.y , ase_worldPos.y );
			float screenDepth117 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm117.xy ));
			float distanceDepth117 = saturate( abs( ( screenDepth117 - LinearEyeDepth( ase_screenPosNorm117.z ) ) / ( temp_output_11_0 ) ) );
			float DepthFade119 = distanceDepth117;
			float mulTime3 = _Time.y * _TimeScale;
			float temp_output_2_0 = sin( ( ( temp_output_11_0 + mulTime3 ) * _Frequency ) );
			float4 temp_output_76_0 = ( _ColorTintSecondary * ( 1.0 - temp_output_2_0 ) );
			float div51=256.0/float((int)_PosterizePower);
			float4 posterize51 = ( floor( ( ( _ColorPrimary * temp_output_2_0 ) + temp_output_76_0 ) * div51 ) / div51 );
			float mulTime192 = _Time.y * 2.47;
			float temp_output_193_0 = sin( mulTime192 );
			float4 lerpResult190 = lerp( saturate( ( posterize169 / DepthFade119 ) ) , saturate( ( posterize51 / DepthFade119 ) ) , temp_output_193_0);
			o.Emission = lerpResult190.rgb;
			float4 temp_cast_3 = (_OpacitySecondary).xxxx;
			float4 temp_cast_4 = (_Opacity).xxxx;
			float4 lerpResult194 = lerp( step( temp_output_165_0 , temp_cast_3 ) , step( temp_output_76_0 , temp_cast_4 ) , temp_output_193_0);
			o.Alpha = lerpResult194.r;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
321;499;1137;553;1785.712;1744.097;1;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;173;-2066.753,-1770.76;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;10;-1904,192;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;172;-2066.753,-2010.76;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;184;-1586.753,-1508.76;Inherit;False;Property;_TimeScaleSecondary;TimeScaleSecondary;6;0;Create;True;0;0;False;0;0;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1376,464;Inherit;False;Property;_TimeScale;TimeScale;5;0;Create;True;0;0;False;0;0;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;7;-1904,-48;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DistanceOpNode;11;-1696,16;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;174;-1858.753,-1946.76;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;3;-1200,368;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;183;-1362.753,-1594.76;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-1024,48;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;182;-1138.753,-1594.76;Inherit;False;Property;_FrecuencySecondary;FrecuencySecondary;1;0;Create;True;0;0;False;0;0;25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-976,368;Inherit;False;Property;_Frequency;Frequency;0;0;Create;True;0;0;False;0;0;25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;175;-1186.753,-1914.76;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;176;-946.7532,-1962.76;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-784,0;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;2;-528,-64;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;177;-690.7532,-2026.76;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;179;-418.7531,-1866.76;Inherit;False;Property;_ColorTintCuaternary;ColorTintCuaternary;12;0;Create;True;0;0;False;0;0.5565186,1,0.4575472,0;0.0627451,0.2431373,0.8235295,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;118;-1760,688;Inherit;True;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;74;-224,336;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;178;-1130.727,-2242.765;Inherit;False;Property;_ColorTintTernary;ColorTintTernary;4;0;Create;True;0;0;False;0;0.06627893,1,0,0;0.7215686,0.07450981,0.7725491,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;181;-386.7531,-1626.76;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;-1008,-272;Inherit;False;Property;_ColorPrimary;ColorPrimary;3;0;Create;True;0;0;False;0;0.06627893,1,0,0;0.7607844,0.7921569,0.06666667,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;75;-256,96;Inherit;False;Property;_ColorTintSecondary;ColorTintSecondary;11;0;Create;True;0;0;False;0;0.5565186,1,0.4575472,0;0.1618257,0.9528302,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;165;-162.7531,-1818.76;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;180;-466.7531,-2234.76;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;0,144;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-304,-272;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DepthFade;117;-1360,800;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;395.202,-118.9327;Inherit;False;Property;_PosterizePower;PosterizePower;9;0;Create;True;0;0;False;0;0;86.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;119;-928,848;Inherit;False;DepthFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;167;-34.75314,-2234.76;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;128,-272;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;166;301.2469,-2058.76;Inherit;False;Property;_Float1;Float 1;10;0;Create;True;0;0;False;0;0;86.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;195;662.8574,971.0785;Inherit;False;Property;_ChangeIntervalScale;ChangeIntervalScale;15;0;Create;True;0;0;False;0;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;480,-464;Inherit;False;119;DepthFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;168;317.2469,-2426.76;Inherit;False;119;DepthFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosterizeNode;51;697.7789,-285.1538;Inherit;True;1;2;1;COLOR;0,0,0,0;False;0;INT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosterizeNode;169;573.2468,-2186.76;Inherit;True;1;2;1;COLOR;0,0,0,0;False;0;INT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;192;879.7698,-1778.164;Inherit;False;1;0;FLOAT;2.47;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;108;1040.165,980.6871;Inherit;False;1;0;FLOAT;2.47;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;170;909.2468,-2378.76;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;116;1095.599,735.702;Inherit;False;Property;_Offset;Offset;14;0;Create;True;0;0;False;0;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;189;78.75566,-1287.521;Inherit;False;Property;_OpacitySecondary;OpacitySecondary;8;0;Create;True;0;0;False;0;0;0.274;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;241.5088,675.2394;Inherit;False;Property;_Opacity;Opacity;7;0;Create;True;0;0;False;0;0;0.274;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;1084.23,615.9277;Inherit;False;Property;_Tiling;Tiling;13;0;Create;True;0;0;False;0;0;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;125;987.9136,-553.596;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SinOpNode;109;1322.694,764.9536;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;188;526.4958,-1533.714;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;107;1307.914,-719.6343;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;171;1229.247,-2330.76;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;78;689.249,429.0458;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SinOpNode;193;1174.583,-1975.471;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;114;1282.641,540.8129;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;194;2025.866,-1162.744;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;190;1973.699,-1784.059;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DepthFade;185;-1522.753,-1162.76;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;186;-1090.753,-1114.76;Inherit;False;DepthFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;2000.937,615.7438;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;187;-1922.753,-1274.76;Inherit;True;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3183.84,-197.4184;Float;False;True;-1;6;ASEMaterialInspector;0;0;Unlit;ConstructionUIEffect;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;2;Custom;0.75;True;False;0;True;Transparent;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;150;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;2;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;11;0;7;2
WireConnection;11;1;10;2
WireConnection;174;0;172;2
WireConnection;174;1;173;2
WireConnection;3;0;13;0
WireConnection;183;0;184;0
WireConnection;12;0;11;0
WireConnection;12;1;3;0
WireConnection;175;0;174;0
WireConnection;175;1;183;0
WireConnection;176;0;175;0
WireConnection;176;1;182;0
WireConnection;14;0;12;0
WireConnection;14;1;6;0
WireConnection;2;0;14;0
WireConnection;177;0;176;0
WireConnection;74;0;2;0
WireConnection;181;0;177;0
WireConnection;165;0;179;0
WireConnection;165;1;181;0
WireConnection;180;0;178;0
WireConnection;180;1;177;0
WireConnection;76;0;75;0
WireConnection;76;1;74;0
WireConnection;15;0;1;0
WireConnection;15;1;2;0
WireConnection;117;1;118;0
WireConnection;117;0;11;0
WireConnection;119;0;117;0
WireConnection;167;0;180;0
WireConnection;167;1;165;0
WireConnection;20;0;15;0
WireConnection;20;1;76;0
WireConnection;51;1;20;0
WireConnection;51;0;48;0
WireConnection;169;1;167;0
WireConnection;169;0;166;0
WireConnection;108;0;195;0
WireConnection;170;0;169;0
WireConnection;170;1;168;0
WireConnection;125;0;51;0
WireConnection;125;1;120;0
WireConnection;109;0;108;0
WireConnection;188;0;165;0
WireConnection;188;1;189;0
WireConnection;107;0;125;0
WireConnection;171;0;170;0
WireConnection;78;0;76;0
WireConnection;78;1;21;0
WireConnection;193;0;192;0
WireConnection;114;0;115;0
WireConnection;114;1;116;0
WireConnection;194;0;188;0
WireConnection;194;1;78;0
WireConnection;194;2;193;0
WireConnection;190;0;171;0
WireConnection;190;1;107;0
WireConnection;190;2;193;0
WireConnection;185;1;187;0
WireConnection;185;0;174;0
WireConnection;186;0;185;0
WireConnection;110;0;114;2
WireConnection;110;1;109;0
WireConnection;0;2;190;0
WireConnection;0;9;194;0
WireConnection;0;11;110;0
ASEEND*/
//CHKSM=FE61F684EFFE6E7A818DE7F7A669B89510BF88EE