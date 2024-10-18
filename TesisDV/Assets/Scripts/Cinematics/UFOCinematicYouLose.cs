using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UFOCinematicYouLose : MonoBehaviour
{
    public delegate void OnFinishUFOWarpingAwayDelegate();
    public event OnFinishUFOWarpingAwayDelegate OnFinishUFOWarpingAway;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    public void CallFinishUFOWarpingAway()
    {
        OnFinishUFOWarpingAway?.Invoke();
    }
}
