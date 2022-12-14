// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TankHitFistDamagePlayer"
{
	Properties
	{
		_MinX("MinX", Float) = 0
		_TextureFistsRightUpperLeftDown("TextureFistsRightUpperLeftDown", 2D) = "white" {}
		_Intensity("Intensity", Range( 0 , 0.5)) = 1
		_MaxX("MaxX", Float) = 0
		_TilingTex1("TilingTex1", Vector) = (0.25,0.65,0,0)
		_TilingTex2("TilingTex2", Vector) = (0.25,0.65,0,0)
		_TextureFistsLeftUpperRightDown("TextureFistsLeftUpperRightDown", 2D) = "white" {}
		_Rows("Rows", Float) = 0
		_Columns("Columns", Float) = 0
		_SubtractValue("SubtractValue", Float) = 1
		_Value("Value", Float) = 0
		_TimeScale("TimeScale", Float) = 0
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
			
			uniform float _MinX;
			uniform float _MaxX;
			uniform sampler2D _TextureFistsLeftUpperRightDown;
			uniform float2 _TilingTex1;
			uniform float _Columns;
			uniform float _Rows;
			uniform float _TimeScale;
			uniform sampler2D _TextureFistsRightUpperLeftDown;
			uniform float2 _TilingTex2;
			uniform float _SubtractValue;
			uniform float _Value;
			uniform float _Intensity;


			
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
				float4 color18 = IsGammaSpace() ? float4(0.9716981,0.7256492,0,0) : float4(0.9368213,0.4853872,0,0);
				float2 uv04 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float smoothstepResult11 = smoothstep( min( _MinX , _MaxX ) , max( _MinX , _MaxX ) , distance( uv04 , float2( 0.5,0.5 ) ));
				float2 uv029 = i.texcoord.xy * _TilingTex1 + float2( 0,-5 );
				float mulTime22 = _Time.y * _TimeScale;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles36 = _Columns * _Rows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset36 = 1.0f / _Columns;
				float fbrowsoffset36 = 1.0f / _Rows;
				// Speed of animation
				float fbspeed36 = mulTime22 * 0.0;
				// UV Tiling (col and row offset)
				float2 fbtiling36 = float2(fbcolsoffset36, fbrowsoffset36);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex36 = round( fmod( fbspeed36 + 0.0, fbtotaltiles36) );
				fbcurrenttileindex36 += ( fbcurrenttileindex36 < 0) ? fbtotaltiles36 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox36 = round ( fmod ( fbcurrenttileindex36, _Columns ) );
				// Multiply Offset X by coloffset
				float fboffsetx36 = fblinearindextox36 * fbcolsoffset36;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy36 = round( fmod( ( fbcurrenttileindex36 - fblinearindextox36 ) / _Columns, _Rows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy36 = (int)(_Rows-1) - fblinearindextoy36;
				// Multiply Offset Y by rowoffset
				float fboffsety36 = fblinearindextoy36 * fbrowsoffset36;
				// UV Offset
				float2 fboffset36 = float2(fboffsetx36, fboffsety36);
				// Flipbook UV
				half2 fbuv36 = uv029 * fbtiling36 + fboffset36;
				// *** END Flipbook UV Animation vars ***
				float4 tex2DNode40 = tex2D( _TextureFistsLeftUpperRightDown, fbuv36 );
				float2 uv034 = i.texcoord.xy * _TilingTex2 + float2( 0,-5 );
				float fbtotaltiles35 = _Columns * _Rows;
				float fbcolsoffset35 = 1.0f / _Columns;
				float fbrowsoffset35 = 1.0f / _Rows;
				float fbspeed35 = ( mulTime22 - _SubtractValue ) * 0.0;
				float2 fbtiling35 = float2(fbcolsoffset35, fbrowsoffset35);
				float fbcurrenttileindex35 = round( fmod( fbspeed35 + 0.0, fbtotaltiles35) );
				fbcurrenttileindex35 += ( fbcurrenttileindex35 < 0) ? fbtotaltiles35 : 0;
				float fblinearindextox35 = round ( fmod ( fbcurrenttileindex35, _Columns ) );
				float fboffsetx35 = fblinearindextox35 * fbcolsoffset35;
				float fblinearindextoy35 = round( fmod( ( fbcurrenttileindex35 - fblinearindextox35 ) / _Columns, _Rows ) );
				fblinearindextoy35 = (int)(_Rows-1) - fblinearindextoy35;
				float fboffsety35 = fblinearindextoy35 * fbrowsoffset35;
				float2 fboffset35 = float2(fboffsetx35, fboffsety35);
				half2 fbuv35 = uv034 * fbtiling35 + fboffset35;
				float4 tex2DNode38 = tex2D( _TextureFistsRightUpperLeftDown, fbuv35 );
				float temp_output_39_0 = floor( abs( ( ( _Value - sin( mulTime22 ) ) / _Value ) ) );
				float4 lerpResult41 = lerp( tex2DNode40 , tex2DNode38 , temp_output_39_0);
				float lerpResult43 = lerp( tex2DNode40.a , tex2DNode38.a , temp_output_39_0);
				float4 FlipbookFistAnimation47 = ( saturate( lerpResult41 ) * lerpResult43 );
				float4 lerpResult14 = lerp( tex2D( _MainTex, uv_MainTex ) , ( ( color18 * smoothstepResult11 ) + FlipbookFistAnimation47 ) , _Intensity);
				

				float4 color = lerpResult14;
				
				return color;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17800
261;503;1137;546;1689.765;220.4218;1.917301;True;False
Node;AmplifyShaderEditor.RangedFloatNode;42;-4658.594,-1297.044;Inherit;False;Property;_TimeScale;TimeScale;11;0;Create;True;0;0;False;0;0;15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;22;-4391.242,-1267.341;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-3574.127,-705.0873;Inherit;False;Property;_Value;Value;10;0;Create;True;0;0;False;0;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;24;-3974.477,-960.7006;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-4143.643,-1194.576;Inherit;False;Property;_SubtractValue;SubtractValue;9;0;Create;True;0;0;False;0;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;25;-4134.623,-1435.175;Inherit;False;Property;_TilingTex2;TilingTex2;5;0;Create;True;0;0;False;0;0.25,0.65;100,6;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;26;-3345.856,-972.8752;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;27;-4077.855,-1740.651;Inherit;False;Property;_TilingTex1;TilingTex1;4;0;Create;True;0;0;False;0;0.25,0.65;100,6;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;33;-3908.031,-1286.305;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-4172.11,-1626.06;Inherit;False;Property;_Columns;Columns;8;0;Create;True;0;0;False;0;0;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-3821.468,-1732.525;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,-5;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;32;-3204.741,-922.8425;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-4162.228,-1545.354;Inherit;False;Property;_Rows;Rows;7;0;Create;True;0;0;False;0;0;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;34;-3835.808,-1445.931;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,-5;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;36;-3516.912,-1707.882;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;18.44;False;2;FLOAT;-2.8;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.AbsOpNode;37;-2985.046,-990.4384;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;35;-3543.66,-1461.394;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;18.44;False;2;FLOAT;-2.8;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;40;-3177.955,-1658.492;Inherit;True;Property;_TextureFistsLeftUpperRightDown;TextureFistsLeftUpperRightDown;6;0;Create;True;0;0;False;0;-1;None;9bc149d3a4266534b842edd41ee712dc;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;38;-3183.226,-1431.435;Inherit;True;Property;_TextureFistsRightUpperLeftDown;TextureFistsRightUpperLeftDown;1;0;Create;True;0;0;False;0;-1;None;86702c58d6f3b054797df31aa276b11e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FloorOpNode;39;-2809.296,-1021.095;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;41;-2742.474,-1589.904;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;44;-2484.756,-1560.373;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;43;-2531.073,-1285.166;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;7;-1503.23,239.3655;Inherit;False;Constant;_Vector0;Vector 0;2;0;Create;True;0;0;False;0;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-1611.46,39.98421;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;6;-1589.693,498.638;Inherit;False;Property;_MaxX;MaxX;3;0;Create;True;0;0;False;0;0;0.51;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1587.693,428.638;Inherit;False;Property;_MinX;MinX;0;0;Create;True;0;0;False;0;0;0.11;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;8;-1234.696,477.638;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;9;-1236.696,384.638;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;10;-1268.828,92.87124;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-2212.506,-1434.652;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-1890.192,-1367.333;Inherit;False;FlipbookFistAnimation;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;18;-997.7629,-63.21767;Inherit;False;Constant;_Color0;Color 0;3;0;Create;True;0;0;False;0;0.9716981,0.7256492,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;11;-1009.146,139.9981;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-854.7592,388.7516;Inherit;False;47;FlipbookFistAnimation;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-781.4092,74.20393;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;2;-1480.702,-308.1506;Inherit;False;0;0;_MainTex;Pass;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-1096.061,-313.136;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-510.3004,-7.676486;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-925.392,655.4599;Inherit;False;Property;_Intensity;Intensity;2;0;Create;True;0;0;False;0;1;0;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;14;-186.8752,-76.5461;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0.06603771,0.06603771,0.06603771,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;167,-126;Float;False;True;-1;2;ASEMaterialInspector;0;9;TankHitFistDamagePlayer;6ee3f8b6a5b82cb45858d55fcbadce45;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;True;2;False;-1;False;False;True;2;False;-1;True;7;False;-1;False;False;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;0
WireConnection;22;0;42;0
WireConnection;24;0;22;0
WireConnection;26;0;23;0
WireConnection;26;1;24;0
WireConnection;33;0;22;0
WireConnection;33;1;28;0
WireConnection;29;0;27;0
WireConnection;32;0;26;0
WireConnection;32;1;23;0
WireConnection;34;0;25;0
WireConnection;36;0;29;0
WireConnection;36;1;30;0
WireConnection;36;2;31;0
WireConnection;36;5;22;0
WireConnection;37;0;32;0
WireConnection;35;0;34;0
WireConnection;35;1;30;0
WireConnection;35;2;31;0
WireConnection;35;5;33;0
WireConnection;40;1;36;0
WireConnection;38;1;35;0
WireConnection;39;0;37;0
WireConnection;41;0;40;0
WireConnection;41;1;38;0
WireConnection;41;2;39;0
WireConnection;44;0;41;0
WireConnection;43;0;40;4
WireConnection;43;1;38;4
WireConnection;43;2;39;0
WireConnection;8;0;5;0
WireConnection;8;1;6;0
WireConnection;9;0;5;0
WireConnection;9;1;6;0
WireConnection;10;0;4;0
WireConnection;10;1;7;0
WireConnection;45;0;44;0
WireConnection;45;1;43;0
WireConnection;47;0;45;0
WireConnection;11;0;10;0
WireConnection;11;1;9;0
WireConnection;11;2;8;0
WireConnection;19;0;18;0
WireConnection;19;1;11;0
WireConnection;3;0;2;0
WireConnection;50;0;19;0
WireConnection;50;1;48;0
WireConnection;14;0;3;0
WireConnection;14;1;50;0
WireConnection;14;2;15;0
WireConnection;1;0;14;0
ASEEND*/
//CHKSM=E1DD68814C2DCD4769A4C9F290B2A5E3C6882E1C