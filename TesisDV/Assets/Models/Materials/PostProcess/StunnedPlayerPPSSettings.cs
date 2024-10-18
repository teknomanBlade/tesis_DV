// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
#if UNITY_POST_PROCESSING_STACK_V2
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess( typeof( StunnedPlayerPPSRenderer ), PostProcessEvent.AfterStack, "StunnedPlayer", true )]
public sealed class StunnedPlayerPPSSettings : PostProcessEffectSettings
{
	[Tooltip( "Intensity" ), Range(0,1)]
	public FloatParameter _Intensity = new FloatParameter { value = 1f };
	[Tooltip( "MinX" )]
	public FloatParameter _MinX = new FloatParameter { value = 0f };
	[Tooltip( "MaxX" )]
	public FloatParameter _MaxX = new FloatParameter { value = 0f };
	[Tooltip( "DistortionNormalMap" )]
	public TextureParameter _DistortionNormalMap = new TextureParameter {  };
	[Tooltip( "BirdsTexture" )]
	public TextureParameter _BirdsTexture = new TextureParameter {  };
	[Tooltip( "Tiling" )]
	public Vector4Parameter _Tiling = new Vector4Parameter { value = new Vector4(0f,0f,0f,0f) };
	[Tooltip( "Offset" )]
	public Vector4Parameter _Offset = new Vector4Parameter { value = new Vector4(0f,0f,0f,0f) };
}

public sealed class StunnedPlayerPPSRenderer : PostProcessEffectRenderer<StunnedPlayerPPSSettings>
{
	public override void Render( PostProcessRenderContext context )
	{
		var sheet = context.propertySheets.Get( Shader.Find( "StunnedPlayer" ) );
		sheet.properties.SetFloat( "_Intensity", settings._Intensity );
		sheet.properties.SetFloat( "_MinX", settings._MinX );
		sheet.properties.SetFloat( "_MaxX", settings._MaxX );
		if(settings._DistortionNormalMap.value != null) sheet.properties.SetTexture( "_DistortionNormalMap", settings._DistortionNormalMap );
		if(settings._BirdsTexture.value != null) sheet.properties.SetTexture( "_BirdsTexture", settings._BirdsTexture );
		sheet.properties.SetVector( "_Tiling", settings._Tiling );
		sheet.properties.SetVector( "_Offset", settings._Offset );
		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}
#endif
