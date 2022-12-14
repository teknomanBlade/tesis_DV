// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "StunnedPlayer"
{
	Properties
	{
		_Intensity("Intensity", Range( 0 , 1)) = 1
		_MinX("MinX", Float) = 0
		_MaxX("MaxX", Float) = 0
		_DistortionNormalMap("DistortionNormalMap", 2D) = "bump" {}
		_BirdsTexture("BirdsTexture", 2D) = "white" {}
		_Tiling("Tiling", Vector) = (0,0,0,0)
		_Offset("Offset", Vector) = (0,0,0,0)
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
			uniform sampler2D _BirdsTexture;
			uniform sampler2D _DistortionNormalMap;
			uniform float2 _Tiling;
			uniform float2 _Offset;
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
				float2 uv02 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float smoothstepResult15 = smoothstep( min( _MinX , _MaxX ) , max( _MinX , _MaxX ) , distance( uv02 , float2( 0.5,0.5 ) ));
				float4 temp_cast_0 = (smoothstepResult15).xxxx;
				float2 uv092 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime90 = _Time.y * 3.0;
				float cos88 = cos( mulTime90 );
				float sin88 = sin( mulTime90 );
				float2 rotator88 = mul( uv092 - float2( 0.5,0.5 ) , float2x2( cos88 , -sin88 , sin88 , cos88 )) + float2( 0.5,0.5 );
				float2 uv093 = i.texcoord.xy * _Tiling + _Offset;
				float mulTime79 = _Time.y * -3.0;
				float cos81 = cos( mulTime79 );
				float sin81 = sin( mulTime79 );
				float2 rotator81 = mul( uv093 - float2( 0.5,0.5 ) , float2x2( cos81 , -sin81 , sin81 , cos81 )) + float2( 0.5,0.5 );
				float grayscale82 = dot(UnpackNormal( tex2D( _DistortionNormalMap, rotator81 ) ), float3(0.299,0.587,0.114));
				float4 TextureMerge87 = ( tex2D( _BirdsTexture, rotator88 ) * grayscale82 );
				float4 lerpResult9 = lerp( tex2D( _MainTex, uv_MainTex ) , temp_cast_0 , saturate( ( TextureMerge87 * _Intensity ) ));
				

				float4 color = lerpResult9;
				
				return color;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17800
328;123;1137;546;1317.887;823.9863;2.225675;True;False
Node;AmplifyShaderEditor.Vector2Node;96;-4515.557,-2003.635;Inherit;False;Property;_Tiling;Tiling;5;0;Create;True;0;0;False;0;0,0;0.7,0.7;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;97;-4470.512,-1857.241;Inherit;False;Property;_Offset;Offset;6;0;Create;True;0;0;False;0;0,0;0.15,0.15;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;79;-3967.415,-1442.905;Inherit;False;1;0;FLOAT;-3;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;80;-4228.992,-1599.099;Inherit;False;Constant;_Vector2;Vector 2;4;0;Create;True;0;0;False;0;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;93;-4020.398,-1779.653;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.7,0.7;False;1;FLOAT2;0.15,0.15;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;92;-4137.065,-1293.914;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;90;-3942.844,-960.5283;Inherit;False;1;0;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;81;-3682.546,-1697.089;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;89;-4139.288,-1093.887;Inherit;False;Constant;_Vector3;Vector 3;4;0;Create;True;0;0;False;0;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;78;-3396.559,-1771.411;Inherit;True;Property;_DistortionNormalMap;DistortionNormalMap;3;0;Create;True;0;0;False;0;-1;None;e98c6a1c109e03849af833a46af5e805;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RotatorNode;88;-3725.176,-1245.526;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;86;-3425.883,-1252.756;Inherit;True;Property;_BirdsTexture;BirdsTexture;4;0;Create;True;0;0;False;0;-1;None;42dd0f3a91fe7bc44b6dd490cf56b914;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCGrayscale;82;-2798.882,-1527.917;Inherit;True;1;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-2490.384,-1403.203;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;-2149.223,-1288.676;Inherit;False;TextureMerge;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;-327.2236,-494.8128;Inherit;False;87;TextureMerge;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-1201.486,76.74921;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;3;-1034.954,223.8604;Inherit;False;Constant;_Vector0;Vector 0;2;0;Create;True;0;0;False;0;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;18;-1179.719,535.403;Inherit;False;Property;_MaxX;MaxX;2;0;Create;True;0;0;False;0;0;0.61;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1177.719,465.403;Inherit;False;Property;_MinX;MinX;1;0;Create;True;0;0;False;0;0;0.17;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-272.4137,224.738;Inherit;False;Property;_Intensity;Intensity;0;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;11;-1120.5,-324.6453;Inherit;False;0;0;_MainTex;Pass;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;4;-852.8223,61.28305;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;20;-824.7215,514.403;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;19;-826.7215,421.403;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;260.4328,-65.40939;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;85;513.9807,-76.32529;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;14;-716.8178,-291.4118;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;15;-556.9535,54.12942;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;9;740.3658,-258.7563;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0.06603771,0.06603771,0.06603771,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;1281.762,8.556167;Float;False;True;-1;2;ASEMaterialInspector;0;9;StunnedPlayer;6ee3f8b6a5b82cb45858d55fcbadce45;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;True;2;False;-1;False;False;True;2;False;-1;True;7;False;-1;False;False;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;0
WireConnection;93;0;96;0
WireConnection;93;1;97;0
WireConnection;81;0;93;0
WireConnection;81;1;80;0
WireConnection;81;2;79;0
WireConnection;78;1;81;0
WireConnection;88;0;92;0
WireConnection;88;1;89;0
WireConnection;88;2;90;0
WireConnection;86;1;88;0
WireConnection;82;0;78;0
WireConnection;83;0;86;0
WireConnection;83;1;82;0
WireConnection;87;0;83;0
WireConnection;4;0;2;0
WireConnection;4;1;3;0
WireConnection;20;0;17;0
WireConnection;20;1;18;0
WireConnection;19;0;17;0
WireConnection;19;1;18;0
WireConnection;26;0;95;0
WireConnection;26;1;5;0
WireConnection;85;0;26;0
WireConnection;14;0;11;0
WireConnection;15;0;4;0
WireConnection;15;1;19;0
WireConnection;15;2;20;0
WireConnection;9;0;14;0
WireConnection;9;1;15;0
WireConnection;9;2;85;0
WireConnection;1;0;9;0
ASEEND*/
//CHKSM=B99735BE651F3C451E685FB2766EBAE1AAC61B21