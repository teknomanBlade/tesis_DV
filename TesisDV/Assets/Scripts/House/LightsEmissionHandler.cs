using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightsEmissionHandler : MonoBehaviour
{
    public GameObject lightModel;
    // Start is called before the first frame update
    void Awake()
    {
        if (gameObject.name.Equals("light_CeilingBarn"))
        {
            lightModel.GetComponent<MeshRenderer>().material.SetFloat("_EmissionLightBarn", 1f);
        }
        if (gameObject.name.Equals("light_CeilingHouseEntrance"))
        {
            lightModel.GetComponent<MeshRenderer>().material.SetFloat("_EmissionLightBarn", 1f);
        }
        if (gameObject.name.Equals("CeilingLightBasement"))
        {
            lightModel.GetComponent<MeshRenderer>().material.SetFloat("_EmissionLightBarn", 1f);
        }
        if (gameObject.name.Equals("CeilingLightKitchen"))
        {
            lightModel.GetComponent<MeshRenderer>().material.SetFloat("_EmissionLightBarn", 1f);
        }
        if (gameObject.name.Equals("LightOne"))
        {
            GetComponent<MeshRenderer>().material.SetFloat("_EmissionLightBarn", 1f);
        }
        if (gameObject.name.Equals("WallLightLiving"))
        {
            GetComponent<MeshRenderer>().material.SetFloat("_EmissionLightLiving", 1f);
        }
        if (gameObject.name.Equals("WallLightLiving_2"))
        {
            GetComponent<MeshRenderer>().material.SetFloat("_EmissionLightLiving", 1f);
        }
        if (gameObject.name.Equals("Lamp"))
        {
            GetComponent<MeshRenderer>().material.SetFloat("_EmissionLightLiving", 1f);
        }
    }
    public void EnableBasementLightEmission() 
    {
        if (gameObject.name.Equals("LampBasement"))
        {
            GetComponent<MeshRenderer>().material.SetFloat("_EmissionLightBarn", 1f);
        }
    }
    // Update is called once per frame
    void Update()
    {
        
    }
}
