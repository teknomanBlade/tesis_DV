using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.GlobalIllumination;

public class LivingLight : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        if (gameObject.name.Equals("WallLightLiving"))
        {
            GetComponent<MeshRenderer>().material.SetFloat("_EmissionLightLiving", 1f);
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
