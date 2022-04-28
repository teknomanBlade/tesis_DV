using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OutLineItem : MonoBehaviour
{
    // Start is called before the first frame update
    public Material OutLineMaterial;
    public Material baseMaterial;

    public Renderer m_Renderer;
    public Texture m_MainTexture;
    public Texture m_Normal;
    public Texture m_Metal;
    public Texture m_AO;

    public bool isFocus;

    void Awake()
    {
        baseMaterial = GetComponent<Renderer>().material;

        m_Renderer = GetComponent<Renderer>();

        //OutLineMaterial.EnableKeyword("_NORMALMAP");
        //OutLineMaterial.EnableKeyword("_METALLICGLOSSMAP");

        
    }

    // Update is called once per frame
    void Update()
    {
        if (isFocus)
        {
            OutLineMaterial.SetFloat("_OutLineAlpha", 1f);
            m_Renderer.material = OutLineMaterial;
        }
        else
        {
            //OutLineMaterial.SetFloat("_OutLineAlpha", 0f);
            m_Renderer.material = baseMaterial;
        }
    }

    public void SetMaterials()
    {
        OutLineMaterial.SetTexture("_Albedo", m_MainTexture);
        OutLineMaterial.SetTexture("_Normal", m_Normal);
        OutLineMaterial.SetTexture("_Metallic", m_Metal);
        OutLineMaterial.SetTexture("_AO", m_AO);
    }
}
