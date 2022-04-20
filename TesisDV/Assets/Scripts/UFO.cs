using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UFO : MonoBehaviour
{
    // Start is called before the first frame update
    void Awake()
    {
        StartCoroutine(StartBuzzSound());
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    IEnumerator StartBuzzSound()
    {
        yield return new WaitForEndOfFrame();
        GameVars.Values.soundManager.PlaySound("UFOBuzz", 0.4f, true);
    }
}
