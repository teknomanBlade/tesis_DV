// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
#if UNITY_POST_PROCESSING_STACK_V2
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess( typeof( ElectricWaveDamagePlayerPPSRenderer ), PostProcessEvent.AfterStack, "ElectricWaveDamagePlayer", true )]
public sealed class ElectricWaveDamagePlayerPPSSettings : PostProcessEffectSettings
{
	[Tooltip( "MinX" )]
	public FloatParameter _MinX1 = new FloatParameter { value = 0.37f };
	[Tooltip( "ElectricDamageIntensity" ), Range(0,1)]
	public FloatParameter _ElectricDamageIntensity = new FloatParameter { value = 1f };
	[Tooltip( "MaxX" )]
	public FloatParameter _MaxX1 = new FloatParameter { value = 0.96f };
	[Tooltip( "TimeScale" )]
	public FloatParameter _TimeScale = new FloatParameter { value = 2f };
	[Tooltip( "Tiling" )]
	public FloatParameter _Tiling = new FloatParameter { value = 1.5f };
	[Tooltip( "Offset" )]
	public FloatParameter _Offset = new FloatParameter { value = 2f };
	[Tooltip( "ElectricRaysTexture" )]
	public TextureParameter _ElectricRaysTexture = new TextureParameter {  };
}

public sealed class ElectricWaveDamagePlayerPPSRenderer : PostProcessEffectRenderer<ElectricWaveDamagePlayerPPSSettings>
{
	public override void Render( PostProcessRenderContext context )
	{
		var sheet = context.propertySheets.Get( Shader.Find( "ElectricWaveDamagePlayer" ) );
		sheet.properties.SetFloat( "_MinX1", settings._MinX1 );
		sheet.properties.SetFloat( "_ElectricDamageIntensity", settings._ElectricDamageIntensity );
		sheet.properties.SetFloat( "_MaxX1", settings._MaxX1 );
		sheet.properties.SetFloat( "_TimeScale", settings._TimeScale );
		sheet.properties.SetFloat( "_Tiling", settings._Tiling );
		sheet.properties.SetFloat( "_Offset", settings._Offset );
		if(settings._ElectricRaysTexture.value != null) sheet.properties.SetTexture( "_ElectricRaysTexture", settings._ElectricRaysTexture );
		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}
#endif
