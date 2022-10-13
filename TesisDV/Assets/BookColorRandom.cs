using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BookColorRandom : MonoBehaviour
{
    // Start is called before the first frame update
    public MeshRenderer[] renderers;
    public Shader toonShader;
    void Start()
    {
        //Color newColor = Random.ColorHSV();
        //Color newColor = Random.ColorHSV(0f, .5f);
        renderers = GetComponentsInChildren<MeshRenderer>();

        Color newColorOne = Random.ColorHSV(0f, .25f, 0.4f, 1f);
        Color newColorTwo = Random.ColorHSV(0f, .25f, 0.4f, 1f);
        ApplyMaterial(newColorOne, newColorTwo, 0);
    }

    void ApplyMaterial(Color colorOne, Color colorTwo, int targetMaterialIndex)
    {


        Material generatedMaterial = new Material(toonShader);

        generatedMaterial.SetColor("_AmbientColor", Color.white);
        generatedMaterial.SetColor("_Color_Base", colorOne);
        generatedMaterial.SetColor("_Color_Title", colorTwo);

        for (int i = 0; i < renderers.Length; i++)
        {
            //renderers[i].material.SetColor("_Color_Base", colorOne);
            //renderers[i].material.SetColor("_Color_Title", colorTwo);
            renderers[i].material = generatedMaterial;
            //renderers[i].material = generatedMaterial;        
        }
    }
}
