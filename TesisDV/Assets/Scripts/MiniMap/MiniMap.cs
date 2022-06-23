using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
public class MiniMap : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        //IA PARCIAL DOS
        var listOfCollider = GetComponentsInChildren<BoxCollider>();

        listOfCollider.Select(x => x.enabled = false).ToList();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
