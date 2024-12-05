using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UFOCinematicYouWin : MonoBehaviour
{
    public delegate void OnFinishUFOWarpingAwayDelegate();
    public event OnFinishUFOWarpingAwayDelegate OnFinishUFOWarpingAway;
    public AudioSource _as;
    // Start is called before the first frame update
    void Start()
    {
        _as = GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update()
    {

    }
    public void CallFinishUFOWarpingAway()
    {
        _as.Stop();
        OnFinishUFOWarpingAway?.Invoke();
    }
}
