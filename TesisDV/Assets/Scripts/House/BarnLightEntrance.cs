using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BarnLightEntrance : MonoBehaviour
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
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
