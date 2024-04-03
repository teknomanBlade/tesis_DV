using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CinematicManagerYouWin : CinematicManager
{
    public GameObject UFO;
    public GameObject TextYouWin;
    // Start is called before the first frame update
    void Awake()
    {
        ActiveFadeInEffect(1f);
        Audio = GetComponent<AudioSource>();
        Audio.Play();
        UFO.GetComponent<UFOCinematicYouWin>().OnFinishUFOWarpingAway += CallYouWinAnimation;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void CallYouWinAnimation()
    {
        TextYouWin.GetComponent<TextCinematicYouWin>().CallYouWinTextAnimation();
        Invoke(nameof(ActiveFadeInButtons), 12.0f);
    }
}
