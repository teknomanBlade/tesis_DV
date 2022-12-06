using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BasementIndicatorObjects : MonoBehaviour
{
    public List<GameObject> toyObjectsIndicators;
    // Start is called before the first frame update
    void Awake()
    {
        toyObjectsIndicators.ForEach(x => x.SetActive(false));
        toyObjectsIndicators[Random.Range(0, toyObjectsIndicators.Count)].SetActive(true);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
