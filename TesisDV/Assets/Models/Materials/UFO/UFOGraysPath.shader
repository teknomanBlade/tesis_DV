// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "UFOGraysPath"
{
	Properties
	{
		_TextureArrows("TextureArrows", 2D) = "white" {}
		_MinX("MinX", Float) = 0
		_MinY("MinY", Float) = 0
		_TilingTex1("TilingTex1", Vector) = (0.25,0.65,0,0)
		_TilingTex2("TilingTex2", Vector) = (0.25,0.65,0,0)
		_MaxX("MaxX", Float) = 0
		_MaxY("MaxY", Float) = 0
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_Rows("Rows", Float) = 0
		_Columns("Columns", Float) = 0
		_SubtractValue("SubtractValue", Float) = 1
		_Value("Value", Float) = 0
		_TimeScale("TimeScale", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _TextureSample0;
		uniform float2 _TilingTex1;
		uniform float _Columns;
		uniform float _Rows;
		uniform float _TimeScale;
		uniform sampler2D _TextureArrows;
		uniform float2 _TilingTex2;
		uniform float _SubtractValue;
		uniform float _Value;
		uniform float _MinX;
		uniform float _MaxX;
		uniform float _MinY;
		uniform float _MaxY;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_TexCoord27 = i.uv_texcoord * _TilingTex1 + float2( 0,-5 );
			float mulTime83 = _Time.y * _TimeScale;
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles73 = _Columns * _Rows;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset73 = 1.0f / _Columns;
			float fbrowsoffset73 = 1.0f / _Rows;
			// Speed of animation
			float fbspeed73 = mulTime83 * 0.0;
			// UV Tiling (col and row offset)
			float2 fbtiling73 = float2(fbcolsoffset73, fbrowsoffset73);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex73 = round( fmod( fbspeed73 + 0.0, fbtotaltiles73) );
			fbcurrenttileindex73 += ( fbcurrenttileindex73 < 0) ? fbtotaltiles73 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox73 = round ( fmod ( fbcurrenttileindex73, _Columns ) );
			// Multiply Offset X by coloffset
			float fboffsetx73 = fblinearindextox73 * fbcolsoffset73;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy73 = round( fmod( ( fbcurrenttileindex73 - fblinearindextox73 ) / _Columns, _Rows ) );
			// Reverse Y to get tiles from Top to Bottom
			fblinearindextoy73 = (int)(_Rows-1) - fblinearindextoy73;
			// Multiply Offset Y by rowoffset
			float fboffsety73 = fblinearindextoy73 * fbrowsoffset73;
			// UV Offset
			float2 fboffset73 = float2(fboffsetx73, fboffsety73);
			// Flipbook UV
			half2 fbuv73 = uv_TexCoord27 * fbtiling73 + fboffset73;
			// *** END Flipbook UV Animation vars ***
			float4 tex2DNode74 = tex2D( _TextureSample0, fbuv73 );
			float2 uv_TexCoord77 = i.uv_texcoord * _TilingTex2 + float2( 0,-5 );
			float fbtotaltiles78 = _Columns * _Rows;
			float fbcolsoffset78 = 1.0f / _Columns;
			float fbrowsoffset78 = 1.0f / _Rows;
			float fbspeed78 = ( mulTime83 - _SubtractValue ) * 0.0;
			float2 fbtiling78 = float2(fbcolsoffset78, fbrowsoffset78);
			float fbcurrenttileindex78 = round( fmod( fbspeed78 + 0.0, fbtotaltiles78) );
			fbcurrenttileindex78 += ( fbcurrenttileindex78 < 0) ? fbtotaltiles78 : 0;
			float fblinearindextox78 = round ( fmod ( fbcurrenttileindex78, _Columns ) );
			float fboffsetx78 = fblinearindextox78 * fbcolsoffset78;
			float fblinearindextoy78 = round( fmod( ( fbcurrenttileindex78 - fblinearindextox78 ) / _Columns, _Rows ) );
			fblinearindextoy78 = (int)(_Rows-1) - fblinearindextoy78;
			float fboffsety78 = fblinearindextoy78 * fbrowsoffset78;
			float2 fboffset78 = float2(fboffsetx78, fboffsety78);
			half2 fbuv78 = uv_TexCoord77 * fbtiling78 + fboffset78;
			float4 tex2DNode22 = tex2D( _TextureArrows, fbuv78 );
			float temp_output_105_0 = floor( abs( ( ( _Value - sin( mulTime83 ) ) / _Value ) ) );
			float4 lerpResult85 = lerp( tex2DNode74 , tex2DNode22 , temp_output_105_0);
			float4 temp_output_46_0 = saturate( lerpResult85 );
			o.Albedo = temp_output_46_0.rgb;
			o.Emission = temp_output_46_0.rgb;
			float temp_output_51_0 = min( _MinX , _MaxX );
			float temp_output_52_0 = max( _MinX , _MaxX );
			float smoothstepResult55 = smoothstep( temp_output_51_0 , temp_output_52_0 , ( 1.0 - i.uv_texcoord.x ));
			float smoothstepResult54 = smoothstep( temp_output_51_0 , temp_output_52_0 , i.uv_texcoord.x);
			float temp_output_66_0 = min( _MinY , _MaxY );
			float temp_output_64_0 = max( _MinY , _MaxY );
			float smoothstepResult68 = smoothstep( temp_output_66_0 , temp_output_64_0 , ( 1.0 - i.uv_texcoord.y ));
			float smoothstepResult67 = smoothstep( temp_output_66_0 , temp_output_64_0 , i.uv_texcoord.y);
			float Smoothstep88 = ( ( saturate( smoothstepResult55 ) * saturate( smoothstepResult54 ) ) * ( saturate( smoothstepResult68 ) * saturate( smoothstepResult67 ) ) );
			float lerpResult104 = lerp( tex2DNode74.a , tex2DNode22.a , temp_output_105_0);
			float lerpResult60 = lerp( 0.0 , Smoothstep88 , lerpResult104);
			o.Alpha = lerpResult60;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

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
262;228;1137;375;3058.767;-1105.638;1.866892;True;False
Node;AmplifyShaderEditor.CommentaryNode;91;-2525.256,958.9995;Inherit;False;1926.44;1310.931;Smoothstep;24;88;72;58;71;56;57;70;69;55;68;54;67;52;53;66;51;65;64;50;61;62;48;49;63;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;50;-2475.822,1137.488;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;61;-2459.573,1702.369;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;63;-2435.249,2094.396;Inherit;False;Property;_MaxY;MaxY;6;0;Create;True;0;0;False;0;0;0.36;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-892.5587,29.62512;Inherit;False;Property;_TimeScale;TimeScale;12;0;Create;True;0;0;False;0;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2433.249,2023.396;Inherit;False;Property;_MinY;MinY;2;0;Create;True;0;0;False;0;0;0.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-2451.497,1526.515;Inherit;False;Property;_MaxX;MaxX;5;0;Create;True;0;0;False;0;0;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-2449.497,1456.515;Inherit;False;Property;_MinX;MinX;1;0;Create;True;0;0;False;0;0;0.23;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;51;-2098.499,1412.515;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;64;-2080.25,2072.396;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;52;-2096.499,1505.515;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;66;-2082.25,1979.396;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;65;-2138.317,1689.834;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;83;-625.2065,59.3279;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;53;-2154.566,1122.953;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;191.9088,621.5818;Inherit;False;Property;_Value;Value;11;0;Create;True;0;0;False;0;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;106;-208.4416,365.9686;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;54;-1743.451,1411.034;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;67;-1727.202,1977.915;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;55;-1720.08,1150.403;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;68;-1703.831,1717.284;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;76;-368.5877,-108.5056;Inherit;False;Property;_TilingTex2;TilingTex2;4;0;Create;True;0;0;False;0;0.25,0.65;100,8;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SaturateNode;70;-1445.372,1694.685;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;97;420.1792,353.7939;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;69;-1471.939,1959.771;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;57;-1488.187,1392.89;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;47;-311.8198,-413.9824;Inherit;False;Property;_TilingTex1;TilingTex1;3;0;Create;True;0;0;False;0;0.25,0.65;100,8;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;87;-377.6075,132.0932;Inherit;False;Property;_SubtractValue;SubtractValue;10;0;Create;True;0;0;False;0;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;56;-1429.173,1132.796;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-1250.386,1311.838;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;27;-55.43261,-405.8558;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,-5;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;81;-406.0748,-299.3912;Inherit;False;Property;_Columns;Columns;9;0;Create;True;0;0;False;0;0;17;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-396.1923,-218.6852;Inherit;False;Property;_Rows;Rows;8;0;Create;True;0;0;False;0;0;4.51;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;98;561.2944,403.8266;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;86;-141.9958,40.36354;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;77;-69.77249,-119.2622;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,-5;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-1271.577,1731.454;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-1093.276,1529.632;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;78;222.3752,-134.7246;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;18.44;False;2;FLOAT;-2.8;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;73;249.1234,-381.2127;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;18.44;False;2;FLOAT;-2.8;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.AbsOpNode;101;778.174,440.3988;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;-824.9154,1542.015;Inherit;False;Smoothstep;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;22;582.8101,-104.7658;Inherit;True;Property;_TextureArrows;TextureArrows;0;0;Create;True;0;0;False;0;-1;None;b037511df8ebb9d4c8674870da7bb0c3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FloorOpNode;105;953.9244,435.0808;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;74;588.0811,-331.8235;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;False;0;-1;None;3c59bd6c3762484489689482eae5483d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;89;1160.477,198.0327;Inherit;False;88;Smoothstep;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;85;1060.281,-271.395;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;104;1138.185,-96.76421;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;46;1385.318,-270.4226;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;60;1429.016,71.0338;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1731.892,-258.2746;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;UFOGraysPath;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;51;0;48;0
WireConnection;51;1;49;0
WireConnection;64;0;62;0
WireConnection;64;1;63;0
WireConnection;52;0;48;0
WireConnection;52;1;49;0
WireConnection;66;0;62;0
WireConnection;66;1;63;0
WireConnection;65;0;61;2
WireConnection;83;0;107;0
WireConnection;53;0;50;1
WireConnection;106;0;83;0
WireConnection;54;0;50;1
WireConnection;54;1;51;0
WireConnection;54;2;52;0
WireConnection;67;0;61;2
WireConnection;67;1;66;0
WireConnection;67;2;64;0
WireConnection;55;0;53;0
WireConnection;55;1;51;0
WireConnection;55;2;52;0
WireConnection;68;0;65;0
WireConnection;68;1;66;0
WireConnection;68;2;64;0
WireConnection;70;0;68;0
WireConnection;97;0;100;0
WireConnection;97;1;106;0
WireConnection;69;0;67;0
WireConnection;57;0;54;0
WireConnection;56;0;55;0
WireConnection;58;0;56;0
WireConnection;58;1;57;0
WireConnection;27;0;47;0
WireConnection;98;0;97;0
WireConnection;98;1;100;0
WireConnection;86;0;83;0
WireConnection;86;1;87;0
WireConnection;77;0;76;0
WireConnection;71;0;70;0
WireConnection;71;1;69;0
WireConnection;72;0;58;0
WireConnection;72;1;71;0
WireConnection;78;0;77;0
WireConnection;78;1;81;0
WireConnection;78;2;80;0
WireConnection;78;5;86;0
WireConnection;73;0;27;0
WireConnection;73;1;81;0
WireConnection;73;2;80;0
WireConnection;73;5;83;0
WireConnection;101;0;98;0
WireConnection;88;0;72;0
WireConnection;22;1;78;0
WireConnection;105;0;101;0
WireConnection;74;1;73;0
WireConnection;85;0;74;0
WireConnection;85;1;22;0
WireConnection;85;2;105;0
WireConnection;104;0;74;4
WireConnection;104;1;22;4
WireConnection;104;2;105;0
WireConnection;46;0;85;0
WireConnection;60;1;89;0
WireConnection;60;2;104;0
WireConnection;0;0;46;0
WireConnection;0;2;46;0
WireConnection;0;9;60;0
ASEEND*/
//CHKSM=DB25983FEF22C24D361924B830EE0CC42ABA1DFE