// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
#if UNITY_POST_PROCESSING_STACK_V2
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess( typeof( DamagePlayerPPSRenderer ), PostProcessEvent.AfterStack, "DamagePlayer", true )]
public sealed class DamagePlayerPPSSettings : PostProcessEffectSettings
{
	[Tooltip( "Intensity" ), Range(0, 1)]
	public FloatParameter _Intensity = new FloatParameter { value = 0f };
	[Tooltip( "NormalDistortion" )]
	public TextureParameter _NormalDistortion = new TextureParameter {  };
	[Tooltip( "Distortion" ), Range(0, 1)]
	public FloatParameter _Distortion = new FloatParameter { value = 0.88f };
	[Tooltip( "DamageTint" )]
	public ColorParameter _DamageTint = new ColorParameter { value = new Color(1f,0.06132078f,0.06132078f,0f) };
	[Tooltip( "DamageTexture" )]
	public TextureParameter _DamageTexture = new TextureParameter {  };
}

public sealed class DamagePlayerPPSRenderer : PostProcessEffectRenderer<DamagePlayerPPSSettings>
{
	public override void Render( PostProcessRenderContext context )
	{
		var sheet = context.propertySheets.Get( Shader.Find( "DamagePlayer" ) );
		sheet.properties.SetFloat( "_Intensity", settings._Intensity );
		if(settings._NormalDistortion.value != null) sheet.properties.SetTexture( "_NormalDistortion", settings._NormalDistortion );
		sheet.properties.SetFloat( "_Distortion", settings._Distortion );
		sheet.properties.SetColor( "_DamageTint", settings._DamageTint );
		if(settings._DamageTexture.value != null) sheet.properties.SetTexture( "_DamageTexture", settings._DamageTexture );
		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}
#endif
