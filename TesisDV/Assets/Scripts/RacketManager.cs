using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RacketManager : MonoBehaviour
{
    public Racket racket;
    // Start is called before the first frame update
    void Awake()
    {
        racket.OnRacketDestroyed += RacketDestroyed;
    }

    private void RacketDestroyed(bool destroyed)
    {
        this.gameObject.SetActive(!destroyed);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
   
}
