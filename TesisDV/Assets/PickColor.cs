using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PickColor : MonoBehaviour
{
    // Start is called before the first frame update
    public Shader toonShader;
    public MeshRenderer[] renderers;

    [ColorUsage(true, true)]
    public Color Color;


    void Start()
    {
        //renderers = GetComponentsInChildren<MeshRenderer>();
        ApplyMaterial(Color);
    }

    void ApplyMaterial(Color colorOne)
    {


        Material generatedMaterial = new Material(toonShader);
        generatedMaterial.SetColor("_Color_Base", colorOne);


        for (int i = 0; i < renderers.Length; i++)
        {
            //renderers[i].material.SetColor("_Color_Base", colorOne);
            //renderers[i].material.SetColor("_Color_Title", colorTwo);
            renderers[i].material = generatedMaterial;
            //renderers[i].material = generatedMaterial;        
        }
    }
}
