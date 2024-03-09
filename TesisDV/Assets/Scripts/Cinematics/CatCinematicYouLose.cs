using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CatCinematicYouLose : MonoBehaviour
{
    
    public delegate void OnFinishCatAnimDelegate();
    public event OnFinishCatAnimDelegate OnFinishCatAnim;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    internal void CallFinishAnim()
    {
        OnFinishCatAnim?.Invoke();
    }
}
