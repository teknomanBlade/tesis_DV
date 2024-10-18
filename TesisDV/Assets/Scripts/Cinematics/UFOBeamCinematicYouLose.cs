using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UFOBeamCinematicYouLose : MonoBehaviour
{
    public delegate void OnFinishUFOBeamDelegate();
    public event OnFinishUFOBeamDelegate OnFinishUFOBeam;
   
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void CallFinishUFOBeam() 
    {
        OnFinishUFOBeam?.Invoke();
    }
}
