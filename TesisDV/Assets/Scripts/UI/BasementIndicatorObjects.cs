using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class BasementIndicatorObjects : MonoBehaviour
{
    public List<GameObject> toyObjectsIndicators;
    // Start is called before the first frame update
    void Awake()
    {
        var transforms = GetComponentsInChildren<Transform>(true).Where(x => x.CompareTag("Toy")).ToList();
        transforms.ForEach(x => {
            x.gameObject.SetActive(false);
            toyObjectsIndicators.Add(x.gameObject); 
        });
        toyObjectsIndicators[Random.Range(0, toyObjectsIndicators.Count)].SetActive(true);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
