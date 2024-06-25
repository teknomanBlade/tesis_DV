using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ArrowUIIndicator : MonoBehaviour
{
    public GameObject ArrowObjectAffordance;
    public GameObject ContainerIndicator;

    // Start is called before the first frame update
    void Awake()
    {
        if (this.name.Equals("ArrowBasementIndicator"))
        {
            ArrowObjectAffordance.SetActive(true);
            ContainerIndicator.SetActive(false);
        }
        else 
        {
            ArrowObjectAffordance.SetActive(false);
            ContainerIndicator.SetActive(true);
        }
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
