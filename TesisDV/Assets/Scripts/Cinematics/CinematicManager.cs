using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class CinematicManager : MonoBehaviour
{
    public GameObject cat;
    public GameObject UFOBeam;
    public GameObject UFO;
    public GameObject TextYouLose;
    public GameObject BtnRestart, BtnBackToMainMenu;
    public AudioSource Audio;
    public PostProcessVolume volume;
    public FadeInOutScenesPPSSettings postProcessFadeInOutScenes;
    private Coroutine FadeOutSceneCoroutine;
    // Start is called before the first frame update
    void Awake()
    {
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
        Invoke(nameof(ActiveFadeInButtons),7.0f);
    }

    private void ActiveFadeInButtons()
    {
        BtnRestart.GetComponent<Animator>().SetBool("IsFadeIn", true);
        BtnBackToMainMenu.GetComponent<Animator>().SetBool("IsFadeIn", true);
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
    public void BackToMainMenu() 
    {
        ActiveFadeOutEffect("BackToMainMenu");
    }

    public void Restart() 
    {
        ActiveFadeOutEffect("Restart");
    }
    public void ActiveFadeOutEffect(string buttonEffect)
    {
        if (volume.profile.TryGetSettings(out postProcessFadeInOutScenes))
        {
            if (FadeOutSceneCoroutine != null) StopCoroutine(FadeOutSceneCoroutine);
            FadeOutSceneCoroutine = StartCoroutine(LerpFadeOutEffect(1f, buttonEffect));
        }
    }
    IEnumerator LerpFadeOutEffect(float duration, string buttonEffect)
    {
        float time = 0.98f;

        while (time > 0 && time < duration)
        {
            time -= Time.deltaTime;

            postProcessFadeInOutScenes._Intensity.value = Mathf.Clamp01(time / duration);
            yield return null;
        }
        if (time < 0f)
        {
            if (buttonEffect.Equals("BackToMainMenu"))
            {
                Debug.Log("MAIN MENU");
                SceneManager.LoadScene(0);
            }
            else 
            {
                Debug.Log("RESTART");
                SceneManager.LoadScene(1);
            }
            
        }
    }
}
