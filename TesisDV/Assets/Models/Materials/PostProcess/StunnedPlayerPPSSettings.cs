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
	[Tooltip( "Intensity" )]
	public FloatParameter _Intensity = new FloatParameter { value = 1f };
	[Tooltip( "MinX" )]
	public FloatParameter _MinX = new FloatParameter { value = 0f };
	[Tooltip( "MaxX" )]
	public FloatParameter _MaxX = new FloatParameter { value = 0f };
	[Tooltip( "DistortionNormalMap" )]
	public TextureParameter _DistortionNormalMap = new TextureParameter {  };
	[Tooltip( "Texture Sample 1" )]
	public TextureParameter _TextureSample1 = new TextureParameter {  };
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
		if(settings._TextureSample1.value != null) sheet.properties.SetTexture( "_TextureSample1", settings._TextureSample1 );
		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}
#endif
