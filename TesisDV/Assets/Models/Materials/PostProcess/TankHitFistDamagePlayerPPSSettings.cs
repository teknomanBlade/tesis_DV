// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
#if UNITY_POST_PROCESSING_STACK_V2
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess( typeof( TankHitFistDamagePlayerPPSRenderer ), PostProcessEvent.AfterStack, "TankHitFistDamagePlayer", true )]
public sealed class TankHitFistDamagePlayerPPSSettings : PostProcessEffectSettings
{
	[Tooltip( "MinX" )]
	public FloatParameter _MinX = new FloatParameter { value = 0f };
	[Tooltip( "TextureFistsRightUpperLeftDown" )]
	public TextureParameter _TextureFistsRightUpperLeftDown = new TextureParameter {  };
	[Tooltip( "Intensity" ), Range(0,0.5f)]
	public FloatParameter _Intensity = new FloatParameter { value = 1f };
	[Tooltip( "MaxX" )]
	public FloatParameter _MaxX = new FloatParameter { value = 0f };
	[Tooltip( "TilingTex1" )]
	public Vector4Parameter _TilingTex1 = new Vector4Parameter { value = new Vector4(0.25f,0.65f,0f,0f) };
	[Tooltip( "TilingTex2" )]
	public Vector4Parameter _TilingTex2 = new Vector4Parameter { value = new Vector4(0.25f,0.65f,0f,0f) };
	[Tooltip( "TextureFistsLeftUpperRightDown" )]
	public TextureParameter _TextureFistsLeftUpperRightDown = new TextureParameter {  };
	[Tooltip( "Rows" )]
	public FloatParameter _Rows = new FloatParameter { value = 0f };
	[Tooltip( "Columns" )]
	public FloatParameter _Columns = new FloatParameter { value = 0f };
	[Tooltip( "SubtractValue" )]
	public FloatParameter _SubtractValue = new FloatParameter { value = 1f };
	[Tooltip( "Value" )]
	public FloatParameter _Value = new FloatParameter { value = 0f };
	[Tooltip( "TimeScale" )]
	public FloatParameter _TimeScale = new FloatParameter { value = 0f };
}

public sealed class TankHitFistDamagePlayerPPSRenderer : PostProcessEffectRenderer<TankHitFistDamagePlayerPPSSettings>
{
	public override void Render( PostProcessRenderContext context )
	{
		var sheet = context.propertySheets.Get( Shader.Find( "TankHitFistDamagePlayer" ) );
		sheet.properties.SetFloat( "_MinX", settings._MinX );
		if(settings._TextureFistsRightUpperLeftDown.value != null) sheet.properties.SetTexture( "_TextureFistsRightUpperLeftDown", settings._TextureFistsRightUpperLeftDown );
		sheet.properties.SetFloat( "_Intensity", settings._Intensity );
		sheet.properties.SetFloat( "_MaxX", settings._MaxX );
		sheet.properties.SetVector( "_TilingTex1", settings._TilingTex1 );
		sheet.properties.SetVector( "_TilingTex2", settings._TilingTex2 );
		if(settings._TextureFistsLeftUpperRightDown.value != null) sheet.properties.SetTexture( "_TextureFistsLeftUpperRightDown", settings._TextureFistsLeftUpperRightDown );
		sheet.properties.SetFloat( "_Rows", settings._Rows );
		sheet.properties.SetFloat( "_Columns", settings._Columns );
		sheet.properties.SetFloat( "_SubtractValue", settings._SubtractValue );
		sheet.properties.SetFloat( "_Value", settings._Value );
		sheet.properties.SetFloat( "_TimeScale", settings._TimeScale );
		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}
#endif
