using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CinematicManagerYouLose : CinematicManager
{
    public GameObject cat;
    public GameObject UFOBeam;
    public GameObject UFO;
    public GameObject TextYouLose;
    // Start is called before the first frame update
    void Awake()
    {
        ActiveFadeInEffect(1f);
        Audio = GetComponent<AudioSource>();
        Audio.Play();
        cat.GetComponent<CatCinematicYouLose>().OnFinishCatAnim += CallFinishShaderFadeOut;
        UFOBeam.GetComponent<UFOBeamCinematicYouLose>().OnFinishUFOBeam += CallFinishAnimUFO;
        UFO.GetComponent<UFOCinematicYouLose>().OnFinishUFOWarpingAway += CallYouLoseAnimation;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void CallYouLoseAnimation()
    {
        TextYouLose.GetComponent<TextCinematicYouLoseAnim>().CallYouLoseTextAnimation();
        Invoke(nameof(ActiveFadeInButtons), 7.0f);
    }
    public void CallFinishAnimUFO()
    {
        UFO.GetComponent<Animator>().SetBool("IsWarpingAway", true);
    }
    public void CallFinishShaderFadeOut()
    {
        UFOBeam.GetComponent<Animator>().SetBool("IsRetracted", true);
        //Invoke(nameof(ActiveFadeOutEffect), 3f);
    }
}
