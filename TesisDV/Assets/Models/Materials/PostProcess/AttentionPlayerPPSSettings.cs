// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
#if UNITY_POST_PROCESSING_STACK_V2
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess( typeof( AttentionPlayerPPSRenderer ), PostProcessEvent.AfterStack, "AttentionPlayer", true )]
public sealed class AttentionPlayerPPSSettings : PostProcessEffectSettings
{
	[Tooltip( "AttentionTexture" )]
	public TextureParameter _AttentionTexture = new TextureParameter {  };
	[Tooltip( "Interpolator" ), Range(0,1)]
	public FloatParameter _Interpolator = new FloatParameter { value = 0f };
}

public sealed class AttentionPlayerPPSRenderer : PostProcessEffectRenderer<AttentionPlayerPPSSettings>
{
	public override void Render( PostProcessRenderContext context )
	{
		var sheet = context.propertySheets.Get( Shader.Find( "AttentionPlayer" ) );
		if(settings._AttentionTexture.value != null) sheet.properties.SetTexture( "_AttentionTexture", settings._AttentionTexture );
		sheet.properties.SetFloat( "_Interpolator", settings._Interpolator );
		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}
#endif
